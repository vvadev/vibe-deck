import 'dart:async';
import 'dart:convert';
import 'dart:io';

class DiscoveryResponder {
  DiscoveryResponder({
    required this.port,
    required this.wsPort,
    required this.deviceName,
  });

  final int port;
  final int wsPort;
  final String deviceName;
  RawDatagramSocket? _socket;

  Future<void> start() async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, port);
    _socket = socket;
    socket.listen((event) {
      if (event != RawSocketEvent.read) return;
      final datagram = socket.receive();
      if (datagram == null) return;
      final text = utf8.decode(datagram.data, allowMalformed: true);
      if (text.trim() != 'vibedeck_discover') return;
      final payload = jsonEncode({
        'type': 'vibedeck_discovery',
        'name': deviceName,
        'wsPort': wsPort,
      });
      socket.send(utf8.encode(payload), datagram.address, datagram.port);
    });
  }

  Future<void> stop() async {
    _socket?.close();
    _socket = null;
  }
}
