import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';

import 'deck_models.dart';
import 'discovery.dart';
import 'executor.dart';
import 'models.dart';
import 'security.dart';
import 'server.dart';
import 'storage.dart';

class _HelloChallenge {
  _HelloChallenge({required this.value, required this.expiresAt});

  final String value;
  final DateTime expiresAt;
}

class DesktopAppState extends ChangeNotifier {
  DesktopAppState({
    required DesktopStorage storage,
    required PairingManager pairingManager,
    required DesktopExecutor executor,
    required HostServer hostServer,
  }) : _storage = storage,
       _pairingManager = pairingManager,
       _executor = executor,
       _hostServer = hostServer;

  final DesktopStorage _storage;
  final PairingManager _pairingManager;
  final DesktopExecutor _executor;
  final HostServer _hostServer;

  DiscoveryResponder? _discoveryResponder;
  final Map<WebSocket, String> _clientIds = <WebSocket, String>{};
  final Map<WebSocket, _HelloChallenge> _helloChallenges =
      <WebSocket, _HelloChallenge>{};
  DesktopSettings settings = DesktopSettings.defaults();
  List<DesktopAction> actions = <DesktopAction>[];
  DeckProfile deckProfile = DeckProfile.defaultProfile();
  List<String> logs = <String>[];
  int deckVersion = 1;

  bool running = false;
  int wsPort = 4040;
  int discoveryPort = 45454;
  String _cachedIp = '127.0.0.1';
  String? _pendingNotification;
  int _notificationNonce = 0;

  String get pairCode => _pairingManager.pairCode;
  String get endpoint => '$_cachedIp:$wsPort';
  int get clientCount => _hostServer.clientCount;
  String? get pendingNotification => _pendingNotification;
  int get notificationNonce => _notificationNonce;

  String? consumePendingNotification() {
    final message = _pendingNotification;
    _pendingNotification = null;
    return message;
  }

  Future<void> init() async {
    try {
      final results = await Future.wait<dynamic>([
        _storage.loadSettings(),
        _storage.loadActions(),
        _storage.loadDeckProfile(),
        _resolveLocalIp(),
      ]);
      settings = results[0] as DesktopSettings;
      actions = results[1] as List<DesktopAction>;
      deckProfile = (results[2] as DeckProfile).normalized();
      _cachedIp = results[3] as String;
      await start();
    } catch (e) {
      _log('Startup failed: ${_startupErrorMessage(e)}');
    }
    notifyListeners();
  }

  Future<void> start() async {
    if (running) return;

    try {
      await _hostServer.start(
        onMessage: _onMessage,
        onConnect: (_) async {
          _log('Client connected');
          notifyListeners();
        },
        onDisconnect: (ws) async {
          _clientIds.remove(ws);
          _helloChallenges.remove(ws);
          _log('Client disconnected');
          notifyListeners();
        },
      );
      _discoveryResponder = DiscoveryResponder(
        port: discoveryPort,
        wsPort: wsPort,
        deviceName: _deviceName(),
      );
      await _discoveryResponder!.start();
      running = true;
      _log('Server running on ws://$endpoint/ws');
      notifyListeners();
    } catch (e) {
      await _discoveryResponder?.stop();
      _discoveryResponder = null;
      await _hostServer.stop();
      running = false;
      rethrow;
    }
  }

  Future<void> stop() async {
    await _discoveryResponder?.stop();
    _discoveryResponder = null;
    await _hostServer.stop();
    running = false;
    _log('Server stopped');
    notifyListeners();
  }

  Future<void> updateSettings(DesktopSettings value) async {
    settings = value;
    await _storage.saveSettings(value);
    _log('Settings updated');
    notifyListeners();
  }

  Future<void> addAction() async {
    final id =
        'action-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
    actions = List<DesktopAction>.from(actions)
      ..add(
        DesktopAction(
          id: id,
          name: 'New Action',
          command: 'echo',
          args: <String>['hello'],
          enabled: true,
          runInShell: false,
        ),
      );
    await _storage.saveActions(actions);
    notifyListeners();
  }

  Future<void> updateAction(DesktopAction value) async {
    actions = actions.map((a) => a.id == value.id ? value : a).toList();
    await _storage.saveActions(actions);
    _log('Action "${value.name}" updated');
    notifyListeners();
  }

  Future<void> removeAction(String id) async {
    actions = actions.where((a) => a.id != id).toList();
    await _storage.saveActions(actions);
    _log('Action removed: $id');
    notifyListeners();
  }

  Future<void> updateDeckLayout({
    required int rows,
    required int cols,
    required double cellSpacing,
    required bool autoAspectRatio,
    double? buttonAspectRatio,
  }) async {
    deckProfile = deckProfile
        .copyWith(
          rows: rows.clamp(1, maxButtons).toInt(),
          cols: cols.clamp(1, maxButtons).toInt(),
          cellSpacing: cellSpacing.clamp(0.0, 48.0).toDouble(),
          autoAspectRatio: autoAspectRatio,
          buttonAspectRatio: autoAspectRatio
              ? null
              : buttonAspectRatio?.clamp(0.2, 5.0).toDouble(),
          clearButtonAspectRatio: autoAspectRatio,
        )
        .normalized();
    await _persistAndBroadcastDeck();
  }

  Future<void> updateDeckOrientation(DeckOrientation orientation) async {
    deckProfile = deckProfile.copyWith(orientation: orientation).normalized();
    await _persistAndBroadcastDeck();
  }

  Future<void> addDeckButton() async {
    final normalized = deckProfile.normalized();
    if (normalized.buttons.length >= normalized.capacity ||
        normalized.buttons.length >= maxButtons) {
      return;
    }
    final usedCells = normalized.buttons
        .map((b) => b.cellIndex)
        .where((index) => index >= 0 && index < normalized.capacity)
        .toSet();
    int? targetCell;
    for (var i = 0; i < normalized.capacity; i++) {
      if (!usedCells.contains(i)) {
        targetCell = i;
        break;
      }
    }
    if (targetCell == null) return;
    final id =
        'btn-${DateTime.now().microsecondsSinceEpoch}-${Random().nextInt(9999)}';
    final next = List<DeckButton>.from(normalized.buttons)
      ..add(
        DeckButton(
          id: id,
          label: 'Button ${normalized.buttons.length}',
          iconKey: 'smart_button',
          bgStyle: 'blue',
          action: ButtonAction(type: ActionType.insertText, data: ''),
          cellIndex: targetCell,
        ),
      );
    deckProfile = normalized.copyWith(buttons: next).normalized();
    await _persistAndBroadcastDeck();
  }

  Future<void> removeDeckButton(String buttonId) async {
    DeckButton? button;
    for (final candidate in deckProfile.buttons) {
      if (candidate.id == buttonId) {
        button = candidate;
        break;
      }
    }
    if (button == null || button.locked) {
      return;
    }
    deckProfile = deckProfile
        .copyWith(
          buttons: deckProfile.buttons.where((b) => b.id != buttonId).toList(),
        )
        .normalized();
    await _persistAndBroadcastDeck();
  }

  Future<void> updateDeckButton(DeckButton button) async {
    final updated = deckProfile.buttons
        .map((current) => current.id == button.id ? button : current)
        .toList();
    deckProfile = deckProfile.copyWith(buttons: updated).normalized();
    await _persistAndBroadcastDeck();
  }

  Future<void> moveDeckButtonToCell({
    required String buttonId,
    required int targetCell,
  }) async {
    if (targetCell < 0 || targetCell >= deckProfile.capacity) {
      return;
    }

    DeckButton? source;
    DeckButton? occupied;
    for (final button in deckProfile.buttons) {
      if (button.id == buttonId) {
        source = button;
      }
      if (button.cellIndex == targetCell && button.id != buttonId) {
        occupied = button;
      }
    }
    if (source == null || source.cellIndex == targetCell) {
      return;
    }

    final sourceCell = source.cellIndex;
    final moved = deckProfile.buttons.map((button) {
      if (button.id == buttonId) {
        return button.copyWith(cellIndex: targetCell);
      }
      if (occupied != null && button.id == occupied.id) {
        return button.copyWith(cellIndex: sourceCell);
      }
      return button;
    }).toList();
    deckProfile = deckProfile.copyWith(buttons: moved).normalized();
    await _persistAndBroadcastDeck();
  }

  Future<void> _persistAndBroadcastDeck() async {
    await _storage.saveDeckProfile(deckProfile);
    deckVersion++;
    _broadcastDeckState();
    notifyListeners();
  }

  void _broadcastDeckState() {
    _hostServer.broadcast(
      ProtocolMessage(type: 'deck_state', payload: _deckStatePayload()).toRaw(),
    );
  }

  Map<String, dynamic> _deckStatePayload() => <String, dynamic>{
    'version': deckVersion,
    'profile': deckProfile.toJson(),
  };

  Future<void> _onMessage(
    WebSocket ws,
    String raw,
    ClientContext context,
  ) async {
    ProtocolMessage request;
    try {
      request = ProtocolMessage.fromRaw(raw);
    } catch (e) {
      ws.add(
        ProtocolMessage(
          type: 'event_error',
          payload: {'message': 'Invalid JSON: $e'},
        ).toRaw(),
      );
      return;
    }

    _log('Request received: ${request.type}');
    switch (request.type) {
      case 'hello':
        final protocolVersion = request.payload['protocolVersion'];
        if (protocolVersion != null && protocolVersion != 1) {
          ws.add(
            ProtocolMessage(
              type: 'event_error',
              payload: {'message': 'Unsupported protocol version'},
            ).toRaw(),
          );
          return;
        }
        final claimedClientId = (request.payload['clientId'] ?? '')
            .toString()
            .trim();
        if (claimedClientId.isNotEmpty) {
          _clientIds[ws] = claimedClientId.length > 64
              ? claimedClientId.substring(0, 64)
              : claimedClientId;
        }
        final challenge = _randomToken(24);
        final challengeTtl = const Duration(seconds: 30);
        _helloChallenges[ws] = _HelloChallenge(
          value: challenge,
          expiresAt: DateTime.now().add(challengeTtl),
        );
        ws.add(
          ProtocolMessage(
            type: 'ack',
            payload: {
              'message': 'hello_ack',
              'challenge': challenge,
              'challengeExpiresInSec': challengeTtl.inSeconds,
            },
          ).toRaw(),
        );
        _log('Client hello received');
        return;
      case 'pair_request':
        final serverChallenge = _helloChallenges[ws];
        if (serverChallenge == null) {
          ws.add(
            ProtocolMessage(
              type: 'pair_error',
              payload: {'message': 'hello is required before pairing'},
            ).toRaw(),
          );
          _log('Pair failed: hello required');
          return;
        }
        if (serverChallenge.expiresAt.isBefore(DateTime.now())) {
          _helloChallenges.remove(ws);
          ws.add(
            ProtocolMessage(
              type: 'pair_error',
              payload: {'message': 'hello challenge expired'},
            ).toRaw(),
          );
          _log('Pair failed: challenge expired');
          return;
        }
        final clientChallenge = (request.payload['challenge'] ?? '')
            .toString()
            .trim();
        if (clientChallenge != serverChallenge.value) {
          ws.add(
            ProtocolMessage(
              type: 'pair_error',
              payload: {'message': 'Invalid hello challenge'},
            ).toRaw(),
          );
          _log('Pair failed: invalid challenge');
          return;
        }
        final binding = _bindingFor(ws, context);
        final code = (request.payload['pairCode'] ?? '').toString();
        final result = _pairingManager.attemptPair(
          candidate: code,
          remoteIp: context.remoteAddress,
          clientBinding: binding,
        );
        if (result.ok && result.sessionToken != null) {
          _helloChallenges.remove(ws);
          ws.add(
            ProtocolMessage(
              type: 'pair_ok',
              payload: {
                'sessionToken': result.sessionToken!,
                'expiresInSec': 1800,
              },
            ).toRaw(),
          );
          ws.add(
            ProtocolMessage(
              type: 'deck_state',
              payload: _deckStatePayload(),
            ).toRaw(),
          );
          _log('Pair success');
        } else {
          final payload = <String, dynamic>{'message': result.message};
          if (result.retryAfter != null) {
            payload['retryAfterSec'] = result.retryAfter!.inSeconds;
          }
          ws.add(ProtocolMessage(type: 'pair_error', payload: payload).toRaw());
          _log('Pair failed: ${result.message}');
        }
        return;
      case 'trigger':
        await _handleTrigger(ws, request, context);
        return;
      case 'health_ping':
        await _handleHealthPing(ws, request, context);
        return;
      default:
        ws.add(
          ProtocolMessage(
            type: 'event_error',
            payload: {'message': 'Unsupported type'},
          ).toRaw(),
        );
        return;
    }
  }

  Future<void> _handleTrigger(
    WebSocket ws,
    ProtocolMessage request,
    ClientContext context,
  ) async {
    final token = (request.payload['sessionToken'] ?? '').toString();
    if (!_pairingManager.validateSession(
      token: token,
      clientBinding: _bindingFor(ws, context),
    )) {
      ws.add(
        ProtocolMessage(
          type: 'event_error',
          payload: {'message': 'Invalid or expired session'},
        ).toRaw(),
      );
      return;
    }

    final buttonId = (request.payload['buttonId'] ?? '').toString();
    DeckButton? button;
    for (final candidate in deckProfile.buttons) {
      if (candidate.id == buttonId) {
        button = candidate;
        break;
      }
    }
    if (button == null) {
      ws.add(
        ProtocolMessage(
          type: 'event_error',
          payload: {'message': 'Unknown button id'},
        ).toRaw(),
      );
      return;
    }

    final actionType = button.action.type;
    final payloadRef = button.action.data;

    ExecutionResult result;
    switch (actionType) {
      case ActionType.insertText:
        result = await _executor.handleInsertText(
          allowed: settings.allowTextInsert,
          text: payloadRef,
        );
        break;
      case ActionType.hotkey:
        result = await _executor.handleHotkey(
          allowed: settings.allowHotkeys,
          chord: payloadRef,
        );
        break;
      case ActionType.runAction:
        result = await _executor.handleRunAction(
          allowed: settings.allowActions,
          allowShellCommands: settings.allowShellCommands,
          actionId: payloadRef,
          actions: actions,
        );
        break;
    }

    if (result.ok) {
      ws.add(
        ProtocolMessage(
          type: 'ack',
          payload: {'message': result.message},
        ).toRaw(),
      );
      _log('Action ok: ${actionTypeToWire(actionType)} (${result.message})');
    } else {
      ws.add(
        ProtocolMessage(
          type: 'event_error',
          payload: {'message': result.message},
        ).toRaw(),
      );
      _log(
        'Action failed: ${actionTypeToWire(actionType)} (${result.message})',
      );
    }
  }

  Future<void> _handleHealthPing(
    WebSocket ws,
    ProtocolMessage request,
    ClientContext context,
  ) async {
    final token = (request.payload['sessionToken'] ?? '').toString();
    if (!_pairingManager.validateSession(
      token: token,
      clientBinding: _bindingFor(ws, context),
    )) {
      ws.add(
        ProtocolMessage(
          type: 'event_error',
          payload: {'message': 'Invalid or expired session'},
        ).toRaw(),
      );
      return;
    }

    ws.add(
      ProtocolMessage(type: 'ack', payload: {'message': 'health_ok'}).toRaw(),
    );
    _log('Health ping received');
    _notifyDesktop('Все работает');
    notifyListeners();
  }

  void _notifyDesktop(String message) {
    _pendingNotification = message;
    _notificationNonce++;
  }

  void _log(String line) {
    final timestamp = DateTime.now().toIso8601String();
    logs = <String>['[$timestamp] $line', ...logs].take(120).toList();
    notifyListeners();
  }

  String _bindingFor(WebSocket socket, ClientContext context) {
    final clientId = _clientIds[socket] ?? 'unknown-client';
    return '${context.remoteAddress}|$clientId';
  }

  String _randomToken(int length) {
    const alphabet =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random.secure();
    return List<String>.generate(
      length,
      (_) => alphabet[rnd.nextInt(alphabet.length)],
    ).join();
  }

  String _deviceName() {
    if (Platform.isMacOS) return 'Vibe Deck Host (macOS)';
    if (Platform.isWindows) return 'Vibe Deck Host (Windows)';
    if (Platform.isLinux) return 'Vibe Deck Host (Linux)';
    return 'Vibe Deck Host';
  }

  Future<String> _resolveLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          if (!address.isLoopback) {
            return address.address;
          }
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  String _startupErrorMessage(Object error) {
    final message = error.toString();
    if (error is SocketException &&
        message.toLowerCase().contains('address already in use')) {
      return 'Port $wsPort or $discoveryPort is already in use. Stop previous Vibe Deck instance and restart.';
    }
    return message;
  }
}
