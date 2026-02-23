import 'dart:async';

import 'package:flutter/foundation.dart';

import 'data/discovery_service.dart';
import 'data/ws_client.dart';
import 'models/deck_models.dart';
import 'models/protocol_models.dart';

enum DeckConnectionState { idle, reconnecting, reconnectFailed }

class MobileAppState extends ChangeNotifier {
  MobileAppState({
    required DiscoveryService discoveryService,
    required WsClient wsClient,
  }) : _discoveryService = discoveryService,
       _wsClient = wsClient;

  final DiscoveryService _discoveryService;
  final WsClient _wsClient;
  StreamSubscription<ProtocolMessage>? _messagesSub;

  DeckProfile profile = DeckProfile.defaultProfile();
  List<DiscoveredHost> hosts = <DiscoveredHost>[];
  String status = 'Disconnected';
  bool loading = false;
  String? connectedEndpoint;

  DeckConnectionState deckConnectionState = DeckConnectionState.idle;
  int deckStateVersion = 0;
  int reconnectAttempts = 0;
  String? lastHost;
  int? lastPort;
  String? lastPairCode;

  bool get isHostLinkConnected =>
      connectedEndpoint != null &&
      deckConnectionState == DeckConnectionState.idle;

  Future<void> init() async {
    notifyListeners();
  }

  Future<void> scanHosts() async {
    loading = true;
    notifyListeners();
    hosts = await _discoveryService.discover();
    loading = false;
    notifyListeners();
  }

  Future<void> connectAndPair({
    required String host,
    required int port,
    required String pairCode,
  }) async {
    status = 'Connecting...';
    notifyListeners();
    await _messagesSub?.cancel();
    await _wsClient.connect(host: host, port: port);
    await _wsClient.pair(pairCode);
    _listenToSocket();
    connectedEndpoint = '$host:$port';
    lastHost = host;
    lastPort = port;
    lastPairCode = pairCode;
    status = 'Paired';
    deckConnectionState = DeckConnectionState.idle;
    reconnectAttempts = 0;
    notifyListeners();
  }

  Future<void> unpair() async {
    await _messagesSub?.cancel();
    _messagesSub = null;
    await _wsClient.disconnect();
    connectedEndpoint = null;
    status = 'Disconnected';
    deckConnectionState = DeckConnectionState.idle;
    notifyListeners();
  }

  Future<void> trigger(DeckButton button) async {
    if (deckConnectionState != DeckConnectionState.idle) {
      return;
    }
    status = 'Sending ${button.label}...';
    notifyListeners();
    try {
      final message = await _wsClient.trigger(buttonId: button.id);
      status = 'OK: $message';
    } catch (e) {
      status = 'Error: $e';
    }
    notifyListeners();
  }

  Future<String> sendHealthPing() async {
    status = 'Sending health ping...';
    notifyListeners();
    try {
      final message = await _wsClient.healthPing();
      status = 'OK: $message';
      notifyListeners();
      return message;
    } catch (e) {
      status = 'Error: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> reconnectNow() async {
    await _reconnectWithBackoff(forceSingleAttempt: true);
  }

  void _listenToSocket() {
    _messagesSub = _wsClient.messages.listen(
      _handleServerMessage,
      onError: (_) {
        _markConnectionLost();
      },
      onDone: () {
        _markConnectionLost();
      },
    );
  }

  void _markConnectionLost() {
    if (connectedEndpoint == null) {
      return;
    }
    deckConnectionState = DeckConnectionState.reconnectFailed;
    status = 'Connection lost';
    notifyListeners();
  }

  void _handleServerMessage(ProtocolMessage message) {
    if (message.type != 'deck_state') {
      return;
    }
    applyDeckStatePayload(message.payload);
  }

  void applyDeckStatePayload(Map<String, dynamic> payload) {
    final versionValue = payload['version'];
    final nextVersion = versionValue is num ? versionValue.toInt() : 0;
    if (nextVersion <= deckStateVersion) {
      return;
    }
    final rawProfile = payload['profile'];
    if (rawProfile is! Map<String, dynamic>) {
      return;
    }
    profile = DeckProfile.fromJson(rawProfile).normalized();
    deckStateVersion = nextVersion;
    deckConnectionState = DeckConnectionState.idle;
    reconnectAttempts = 0;
    notifyListeners();
  }

  Future<void> _reconnectWithBackoff({bool forceSingleAttempt = false}) async {
    if (connectedEndpoint == null ||
        lastHost == null ||
        lastPort == null ||
        lastPairCode == null) {
      return;
    }
    if (deckConnectionState == DeckConnectionState.reconnecting &&
        !forceSingleAttempt) {
      return;
    }

    deckConnectionState = DeckConnectionState.reconnecting;
    notifyListeners();

    final maxAttempts = forceSingleAttempt ? 1 : 3;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      reconnectAttempts = attempt;
      notifyListeners();
      try {
        await _messagesSub?.cancel();
        _messagesSub = null;
        await _wsClient.connect(host: lastHost!, port: lastPort!);
        await _wsClient.pair(lastPairCode!);
        _listenToSocket();
        status = 'Reconnected';
        deckConnectionState = DeckConnectionState.idle;
        reconnectAttempts = 0;
        notifyListeners();
        return;
      } catch (_) {
        if (attempt < maxAttempts) {
          await Future<void>.delayed(
            Duration(milliseconds: 400 * (1 << (attempt - 1))),
          );
        }
      }
    }
    status = 'Reconnect failed';
    deckConnectionState = DeckConnectionState.reconnectFailed;
    notifyListeners();
  }
}
