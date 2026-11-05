import 'dart:convert';
import 'dart:io';

class GameClient {
  static const _host = '127.0.0.1';
  static const _port = 8000;

  Future<Map<String, dynamic>> send(String command) async {
    return sendRaw('{"action": "$command"}');
  }

  Future<Map<String, dynamic>> sendRaw(String jsonString) async {
    final socket = await Socket.connect(_host, _port, timeout: const Duration(seconds: 3));
    try {
      socket.add(utf8.encode(jsonString));
      await socket.flush();
      final bytes = <int>[];
      await for (final chunk in socket) { bytes.addAll(chunk); }
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } finally {
      socket.destroy();
    }
  }

  Future<Map<String, dynamic>> waitForServer({int attempts = 20}) async {
    for (var i = 0; i < attempts; i++) {
      try { return await send('state'); } catch (_) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    throw Exception('Python server did not start.');
  }
}
