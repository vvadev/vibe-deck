import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/protocol_models.dart';

class WsClient {
  static const Duration _responseTimeout = Duration(seconds: 8);
  static const Duration _connectTimeout = Duration(seconds: 5);
  static const int _maxIncomingChars = 8192;

  WebSocket? _socket;
  StreamSubscription<dynamic>? _socketSubscription;
  StreamController<ProtocolMessage>? _incomingController;
  String? _sessionToken;
  Future<void> _opChain = Future<void>.value();

  bool get isConnected => _socket != null;
  String? get sessionToken => _sessionToken;

  Stream<ProtocolMessage> get messages {
    final incoming = _incomingController;
    if (incoming == null) {
      return const Stream<ProtocolMessage>.empty();
    }
    return incoming.stream;
  }

  Future<void> connect({required String host, required int port}) async {
    await _runSerialized<void>(() async {
      await _closeConnection();
      final socket = await WebSocket.connect(
        'ws://$host:$port/ws',
      ).timeout(_connectTimeout);
      socket.pingInterval = const Duration(seconds: 10);
      _socket = socket;
      _sessionToken = null;
      final incoming = StreamController<ProtocolMessage>.broadcast();
      _incomingController = incoming;
      _socketSubscription = socket.listen(
        (raw) {
          if (raw is! String) return;
          if (raw.length > _maxIncomingChars) {
            incoming.addError(
              StateError('Incoming message exceeds safe limit'),
            );
            return;
          }
          try {
            final decoded = jsonDecode(raw);
            if (decoded is! Map<String, dynamic>) {
              return;
            }
            incoming.add(ProtocolMessage.fromJson(decoded));
          } catch (_) {}
        },
        onError: (Object error, StackTrace stackTrace) {
          incoming.addError(error, stackTrace);
        },
        onDone: () async {
          await incoming.close();
        },
      );
    });
  }

  Future<String> pair(String pairCode) async {
    return _runSerialized<String>(() async {
      final socket = _socket;
      if (socket == null) {
        throw StateError('Not connected');
      }
      final challenge = await _performHelloHandshake();
      socket.add(
        jsonEncode(
          ProtocolMessage(
            type: 'pair_request',
            payload: {'pairCode': pairCode, 'challenge': challenge},
          ).toJson(),
        ),
      );

      final parsed = await _awaitResponse(
        expected: <String>{'pair_ok'},
        errorTypes: <String>{'pair_error', 'event_error'},
      );
      if (parsed.type == 'pair_ok') {
        final token = (parsed.payload['sessionToken'] ?? '').toString();
        if (token.isEmpty) {
          throw StateError('Server returned an empty session token');
        }
        _sessionToken = token;
        return token;
      }
      throw StateError(
        (parsed.payload['message'] ?? 'Pairing failed').toString(),
      );
    });
  }

  Future<String> _performHelloHandshake() async {
    final socket = _socket;
    if (socket == null) {
      throw StateError('Not connected');
    }
    socket.add(
      jsonEncode(
        ProtocolMessage(
          type: 'hello',
          payload: {
            'protocolVersion': 1,
            'clientId': 'mobile-${DateTime.now().millisecondsSinceEpoch}',
          },
        ).toJson(),
      ),
    );
    final helloAck = await _awaitResponse(
      expected: <String>{'ack'},
      errorTypes: <String>{'event_error'},
    );
    if (helloAck.type != 'ack' ||
        (helloAck.payload['message'] ?? '').toString() != 'hello_ack') {
      throw StateError('Invalid hello response');
    }
    final challenge = (helloAck.payload['challenge'] ?? '').toString();
    if (challenge.isEmpty) {
      throw StateError('Server did not provide hello challenge');
    }
    return challenge;
  }

  Future<String> trigger({required String buttonId}) async {
    return _runSerialized<String>(() async {
      final socket = _socket;
      final token = _sessionToken;
      if (socket == null || token == null) {
        throw StateError('Not paired');
      }

      socket.add(
        jsonEncode(
          ProtocolMessage(
            type: 'trigger',
            payload: {'sessionToken': token, 'buttonId': buttonId},
          ).toJson(),
        ),
      );

      final parsed = await _awaitResponse(
        expected: <String>{'ack'},
        errorTypes: <String>{'event_error'},
      );
      if (parsed.type == 'ack') {
        return (parsed.payload['message'] ?? 'ok').toString();
      }
      throw StateError((parsed.payload['message'] ?? 'Failed').toString());
    });
  }

  Future<String> healthPing() async {
    return _runSerialized<String>(() async {
      final socket = _socket;
      final token = _sessionToken;
      if (socket == null || token == null) {
        throw StateError('Not paired');
      }

      socket.add(
        jsonEncode(
          ProtocolMessage(
            type: 'health_ping',
            payload: {'sessionToken': token},
          ).toJson(),
        ),
      );

      final parsed = await _awaitResponse(
        expected: <String>{'ack'},
        errorTypes: <String>{'event_error'},
      );
      if (parsed.type == 'ack') {
        return (parsed.payload['message'] ?? 'ok').toString();
      }
      throw StateError((parsed.payload['message'] ?? 'Failed').toString());
    });
  }

  Future<void> disconnect() async {
    await _runSerialized<void>(() async {
      await _closeConnection();
    });
  }

  Future<T> _runSerialized<T>(Future<T> Function() operation) {
    final completer = Completer<T>();
    _opChain = _opChain.catchError((_) {}).then((_) async {
      try {
        completer.complete(await operation());
      } catch (e, st) {
        completer.completeError(e, st);
      }
    });
    return completer.future;
  }

  Future<ProtocolMessage> _awaitResponse({
    required Set<String> expected,
    required Set<String> errorTypes,
  }) async {
    final incoming = _incomingController;
    if (incoming == null) {
      throw StateError('Not connected');
    }
    try {
      await for (final parsed in incoming.stream.timeout(_responseTimeout)) {
        if (expected.contains(parsed.type) ||
            errorTypes.contains(parsed.type)) {
          return parsed;
        }
      }
    } on TimeoutException {
      throw TimeoutException(
        'Timed out waiting for server response',
        _responseTimeout,
      );
    }
    throw StateError('Connection closed before server response');
  }

  Future<void> _closeConnection() async {
    await _socketSubscription?.cancel();
    _socketSubscription = null;
    await _socket?.close();
    _socket = null;
    _sessionToken = null;
    final incoming = _incomingController;
    _incomingController = null;
    if (incoming != null && !incoming.isClosed) {
      await incoming.close();
    }
  }
}
