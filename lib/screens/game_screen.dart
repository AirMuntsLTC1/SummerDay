import 'package:flutter/material.dart';
import '../services/game_client.dart';
import 'map_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _client = GameClient();
  Map<String, dynamic>? _state;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      final s = await _client.waitForServer();
      if (!mounted) return;
      setState(() { _state = s; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send(String command) async {
    try {
      final s = await _client.send(command);
      if (mounted) setState(() => _state = s);
    } catch (_) {}
  }

  // Helper to safely load images with a visual fallback
  Widget _assetImage(String path, {BoxFit fit = BoxFit.cover, Widget? fallback}) {
    return Image.asset(
      'assets/$path.png',
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        return fallback ?? Container(color: Colors.grey.shade800);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_state == null) return const Scaffold(body: Center(child: Text('Error connecting to game.')));

    final s = _state!;
    final sprites = (s['sprites'] as List).cast<Map<String, dynamic>>();

    return Scaffold(
      body: Stack(
        children: [
          // 1. BACKGROUND
          Positioned.fill(
            child: _assetImage(
              'backgrounds/${s['background']}',
              fallback: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade200, Colors.blue.shade600],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Center(child: Text(s['location_name'], style: const TextStyle(fontSize: 40, color: Colors.white))),
              ),
            ),
          ),

          // 2. CHARACTER SPRITES
          ...sprites.asMap().entries.map((entry) {
            final i = entry.key;
            final sprite = entry.value;
            // Simple layout: spread characters evenly
            final leftOffset = (MediaQuery.of(context).size.width / (sprites.length + 1)) * (i + 1) - 60;
            return Positioned(
              bottom: 160, // just above dialogue box
              left: leftOffset,
              child: GestureDetector(
                onTap: () => _send('talk:${sprite['id']}'),
                child: SizedBox(
                  width: 120,
                  height: 240,
                  child: _assetImage(
                    'characters/${sprite['sprite']}',
                    fit: BoxFit.contain,
                    fallback: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CircleAvatar(radius: 40, backgroundColor: Colors.orange, child: Text(sprite['name'][0], style: const TextStyle(fontSize: 30, color: Colors.white))),
                        const SizedBox(height: 4),
                        Text(sprite['name'], style: const TextStyle(fontWeight: FontWeight.bold, backgroundColor: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // 3. HUD (Top)
          Positioned(
            top: 40, left: 16, right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _hudChip(Icons.calendar_today, 'Day ${s['day']}'),
                _hudChip(Icons.wb_sunny, s['time'].toString().toUpperCase()),
                _hudChip(Icons.attach_money, '${s['money']}'),
                _hudChip(Icons.bolt, '${s['energy']}'),
              ],
            ),
          ),

          // 4. MAP BUTTON (Top Right, below HUD)
          Positioned(
            top: 90, right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () async {
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen(exits: (s['exits'] as List).cast<String>())));
                if (result != null) _send('move:$result');
              },
              child: const Icon(Icons.map, color: Colors.orange),
            ),
          ),

          // 5. DIALOGUE BOX & ACTIONS (Bottom)
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.85),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: Colors.orange.shade400, width: 3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    s['message'],
                    style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  // Actions
                  if ((s['actions'] as List).isNotEmpty)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: (s['actions'] as List).map((a) {
                        return ActionChip(
                          backgroundColor: Colors.orange.shade800,
                          label: Text(a.toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12)),
                          onPressed: () => _send('action:$a'),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange.shade300, size: 16),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
