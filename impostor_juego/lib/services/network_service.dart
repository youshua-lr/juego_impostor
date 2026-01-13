import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class NetworkService {
  HttpServer? _server;
  final List<WebSocket> _clients = [];
  WebSocketChannel? _clientChannel;

  Function(Map<String, dynamic>)? onDataReceived;

  // --- HOST LOGIC ---
  Future<String> startHost() async {
    try {
      // Listen on any interface
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 4321);
      _server!.listen((HttpRequest request) {
        if (WebSocketTransformer.isUpgradeRequest(request)) {
          WebSocketTransformer.upgrade(request).then((WebSocket socket) {
            _clients.add(socket);
            print("Client connected");
            socket.listen(
              (data) {
                _handleHostData(data, socket);
              },
              onDone: () {
                _clients.remove(socket);
              },
            );
          });
        }
      });

      // Get IP to display
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            return addr.address;
          }
        }
      }
      return "UNKNOWN_IP";
    } catch (e) {
      debugPrint("Error starting host: $e");
      return "ERROR";
    }
  }

  void _handleHostData(dynamic data, WebSocket sender) {
    // Process data from client (e.g. "I joined", "My name is X")
    // For now, assume client just sends basic info.
    // In a full game, we'd decode JSON, update state, and broadcast.
    if (onDataReceived != null) {
      try {
        final decoded = jsonDecode(data);
        onDataReceived!(decoded);
      } catch (e) {
        print("Error decoding: $e");
      }
    }
  }

  void broadcast(Map<String, dynamic> data) {
    final encoded = jsonEncode(data);
    for (var client in _clients) {
      client.add(encoded);
    }
  }

  // --- CLIENT LOGIC ---
  Future<void> connectToHost(String ip) async {
    try {
      final uri = Uri.parse('ws://$ip:4321');
      _clientChannel = IOWebSocketChannel.connect(uri);
      _clientChannel!.stream.listen((data) {
        if (onDataReceived != null) {
          try {
            final decoded = jsonDecode(data);
            onDataReceived!(decoded);
          } catch (e) {
            print("Error decoding client: $e");
          }
        }
      });
    } catch (e) {
      debugPrint("Error connecting: $e");
      rethrow;
    }
  }

  void sendToHost(Map<String, dynamic> data) {
    _clientChannel?.sink.add(jsonEncode(data));
  }

  void dispose() {
    _server?.close();
    for (var client in _clients) client.close();
    _clientChannel?.sink.close();
  }
}
