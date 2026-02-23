import 'dart:async';
import 'dart:io';

class ClientContext {
  ClientContext({required this.remoteAddress});

  final String remoteAddress;
}

class HostServer {
  HostServer({required this.port});

  static const int maxIncomingChars = 8192;

  final int port;
  HttpServer? _httpServer;
  final Set<WebSocket> _clients = <WebSocket>{};

  int get clientCount => _clients.length;

  Future<void> start({
    required Future<void> Function(
      WebSocket socket,
      String message,
      ClientContext context,
    )
    onMessage,
    Future<void> Function(WebSocket socket)? onConnect,
    Future<void> Function(WebSocket socket)? onDisconnect,
  }) async {
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);
    _httpServer = server;
    server.listen((request) async {
      if (request.uri.path == '/ws' &&
          WebSocketTransformer.isUpgradeRequest(request)) {
        final ws = await WebSocketTransformer.upgrade(request);
        ws.pingInterval = const Duration(seconds: 10);
        _clients.add(ws);
        if (onConnect != null) {
          await onConnect(ws);
        }
        final context = ClientContext(
          remoteAddress:
              request.connectionInfo?.remoteAddress.address ?? 'unknown',
        );
        ws.listen(
              (event) async {
                if (event is String) {
                  if (event.length > maxIncomingChars) {
                    await ws.close(
                      WebSocketStatus.messageTooBig,
                      'Message exceeds limit',
                    );
                    return;
                  }
                  await onMessage(ws, event, context);
                } else {
                  await ws.close(
                    WebSocketStatus.unsupportedData,
                    'Only text messages are supported',
                  );
                }
              },
              onDone: () async {
                _clients.remove(ws);
                if (onDisconnect != null) {
                  await onDisconnect(ws);
                }
              },
              onError: (_, __) async {
                _clients.remove(ws);
                if (onDisconnect != null) {
                  await onDisconnect(ws);
                }
              },
            );
      } else {
        request.response.statusCode = HttpStatus.notFound;
        request.response.write('Not found');
        await request.response.close();
      }
    });
  }

  Future<void> stop() async {
    for (final ws in _clients) {
      await ws.close();
    }
    _clients.clear();
    await _httpServer?.close(force: true);
    _httpServer = null;
  }

  void broadcast(String message) {
    for (final ws in _clients) {
      ws.add(message);
    }
  }
}
