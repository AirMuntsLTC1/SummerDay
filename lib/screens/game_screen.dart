import 'package:flutter/material.dart';
import '../services/game_client.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _client = GameClient();
  Map<String, dynamic>? _state;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final s = await _client.send('{"action": "state"}');
      if (mounted) setState(() => _state = s);
    } catch (_) {}
  }

  Future<void> _interact(String target) async {
    try {
      final s = await _client.send('{"action": "interact", "target": "$target"}');
      if (mounted) setState(() => _state = s);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_state == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final s = _state!;
    final hotspots = (s['hotspots'] as List).cast<Map<String, dynamic>>();
    final characters = (s['characters'] as List).cast<Map<String, dynamic>>();
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Background (Fallback to gradient if no image)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2c3e50), Color(0xFF000000)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(s['location'].toString().toUpperCase(), style: const TextStyle(color: Colors.white24, fontSize: 48, fontWeight: FontWeight.bold)),
              ),
            ),
          ),

          // Hotspots (Doors, Beds, etc.)
          ...hotspots.map((h) {
            return Positioned(
              left: screenSize.width * h['x'],
              top: screenSize.height * h['y'],
              width: screenSize.width * h['w'],
              height: screenSize.height * h['h'],
              child: GestureDetector(
                onTap: () => _interact(h['id']),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orange.withOpacity(0.3), width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.orange.withOpacity(0.1),
                  ),
                  child: Center(child: Icon(Icons.touch_app, color: Colors.orange.withOpacity(0.5))),
                ),
              ),
            );
          }),

          // Characters
          ...characters.map((c) {
            return Positioned(
              left: screenSize.width * c['x'],
              top: screenSize.height * c['y'],
              width: screenSize.width * c['w'],
              height: screenSize.height * c['h'],
              child: GestureDetector(
                onTap: () => _interact(c['id']),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.blue.withOpacity(0.1),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 64, color: Colors.blue),
                        Text(c['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Dialogue Box / UI
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.9),
                border: const Border(top: BorderSide(color: Colors.orange, width: 3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Day ${s['day']} - ${s['time']}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                      Text('$${s['money']}', style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(s['message'], style: const TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 12),
                  if ((s['quests'] as List).isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.orange.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: (s['quests'] as List).map((q) => Text('• $q', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
