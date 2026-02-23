import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/protocol_models.dart';

class DiscoveryService {
  static const int discoveryPort = 45454;
  static const int wsPort = 4040;
  static const String discoverRequest = 'vibedeck_discover';

  Future<List<DiscoveredHost>> discover({
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    socket.broadcastEnabled = true;
    final seen = <String, DiscoveredHost>{};

    final sub = socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      final text = utf8.decode(datagram.data, allowMalformed: true);
      try {
        final json = jsonDecode(text) as Map<String, dynamic>;
        if ((json['type'] ?? '') != 'vibedeck_discovery') return;
        final host = DiscoveredHost(
          name: (json['name'] ?? 'Desktop Host').toString(),
          address: datagram.address.address,
          wsPort: (json['wsPort'] ?? 4040) as int,
        );
        seen[host.endpoint] = host;
      } catch (_) {}
    });

    final probe = utf8.encode(discoverRequest);
    for (final target in await _targets()) {
      socket.send(probe, target, discoveryPort);
    }

    await Future<void>.delayed(timeout);
    await sub.cancel();
    socket.close();

    if (seen.isEmpty) {
      seen.addAll(await _discoverViaWebSocketProbe(timeout: timeout));
    }

    return seen.values.toList()..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<List<InternetAddress>> _targets() async {
    final targets = <String>{'255.255.255.255'};

    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final octets = addr.address.split('.');
          if (octets.length != 4) continue;

          // Directed broadcast for common /24 LANs.
          targets.add('${octets[0]}.${octets[1]}.${octets[2]}.255');

          // Fallback /24 sweep when broadcast is filtered by AP/router.
          for (var i = 1; i <= 254; i++) {
            if (i.toString() == octets[3]) continue;
            targets.add('${octets[0]}.${octets[1]}.${octets[2]}.$i');
          }
        }
      }
    } catch (_) {
      // Keep global broadcast target only.
    }

    return targets.map(InternetAddress.new).toList(growable: false);
  }

  Future<Map<String, DiscoveredHost>> _discoverViaWebSocketProbe({
    required Duration timeout,
  }) async {
    final hosts = <String, DiscoveredHost>{};
    final candidates = await _candidateHosts();
    if (candidates.isEmpty) return hosts;

    final batchSize = 48;
    final connectTimeout = Duration(
      milliseconds: timeout.inMilliseconds <= 2000 ? 170 : 220,
    );

    for (var i = 0; i < candidates.length; i += batchSize) {
      final chunk = candidates.sublist(
        i,
        i + batchSize > candidates.length ? candidates.length : i + batchSize,
      );
      final results = await Future.wait(
        chunk.map((host) => _probeHost(host, connectTimeout)),
      );
      for (final found in results) {
        if (found == null) continue;
        hosts[found.endpoint] = found;
      }
    }

    return hosts;
  }

  Future<DiscoveredHost?> _probeHost(
    String host,
    Duration connectTimeout,
  ) async {
    WebSocket? socket;
    try {
      socket = await WebSocket.connect(
        'ws://$host:$wsPort/ws',
      ).timeout(connectTimeout);
      socket.add(
        jsonEncode({
          'type': 'hello',
          'payload': {'clientId': 'lan-scan'},
        }),
      );
      final response = await socket.first.timeout(connectTimeout);
      if (response is! String) return null;
      final json = jsonDecode(response);
      if (json is! Map<String, dynamic>) return null;
      if ((json['type'] ?? '') != 'ack') return null;
      final payload = json['payload'];
      if (payload is! Map<String, dynamic>) return null;
      if ((payload['message'] ?? '') != 'hello_ack') return null;
      return DiscoveredHost(
        name: 'Vibe Deck Host',
        address: host,
        wsPort: wsPort,
      );
    } catch (_) {
      return null;
    } finally {
      await socket?.close();
    }
  }

  Future<List<String>> _candidateHosts() async {
    final candidates = <String>{};
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final octets = addr.address.split('.');
          if (octets.length != 4) continue;
          for (var i = 1; i <= 254; i++) {
            final candidate = '${octets[0]}.${octets[1]}.${octets[2]}.$i';
            if (candidate == addr.address) continue;
            candidates.add(candidate);
          }
        }
      }
    } catch (_) {}
    return candidates.toList(growable: false);
  }
}
