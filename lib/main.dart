import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:serious_python/serious_python.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SeriousPython.run("app/app.zip");
  runApp(const SummerDayApp());
}

class SummerDayApp extends StatelessWidget {
  const SummerDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SummerDay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  Map<String, dynamic>? _state;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<Map<String, dynamic>> _call(String path, {String? body}) async {
    final client = HttpClient();
    try {
      final uri = Uri.parse('http://127.0.0.1:8000$path');
      final req = body == null
          ? await client.getUrl(uri)
          : await client.postUrl(uri);
      if (body != null) {
        req.headers.contentType = ContentType.json;
        req.write(body);
      }
      final res = await req.close();
      final text = await res.transform(utf8.decoder).join();
      return jsonDecode(text) as Map<String, dynamic>;
    } finally {
      client.close();
    }
  }

  Future<void> _refresh() async {
    try {
      final s = await _call('/state');
      setState(() {
        _state = s;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _choose(String action) async {
    try {
      final s = await _call('/choice', body: jsonEncode({'action': action}));
      setState(() {
        _state = s;
        _error = null;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SummerDay'),
        backgroundColor: Colors.orange.shade100,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_error != null)
                Text('Error: $_error',
                    style: const TextStyle(color: Colors.red))
              else if (_state == null)
                const CircularProgressIndicator()
              else ...[
                Text('Day ${_state!["day"]}',
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Text('Affection: ${_state!["affection"]}'),
                Text('Money: \$${_state!["money"]}'),
                const SizedBox(height: 32),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () => _choose('study'),
                        child: const Text('Study')),
                    ElevatedButton(
                        onPressed: () => _choose('work'),
                        child: const Text('Work')),
                    ElevatedButton(
                        onPressed: () => _choose('sleep'),
                        child: const Text('Sleep')),
                    OutlinedButton(
                        onPressed: () => _choose('reset'),
                        child: const Text('Reset')),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
