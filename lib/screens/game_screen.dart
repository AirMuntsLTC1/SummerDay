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
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    setState(() => _loading = true);
    try {
      final s = await _client.waitForServer();
      if (!mounted) return;
      setState(() {
        _state = s;
        _error = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _send(String command) async {
    try {
      final s = await _client.send(command);
      if (!mounted) return;
      setState(() {
        _state = s;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6EC),
      appBar: AppBar(
        title: const Text('SummerDay'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildGame(_state!),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
                onPressed: _bootstrap, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }

  Widget _buildGame(Map<String, dynamic> s) {
    final characters = (s['characters_here'] as List).cast<Map<String, dynamic>>();
    final actions = (s['actions'] as List).cast<String>();
    final moves = (s['moves'] as List).cast<String>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHud(s),
          const SizedBox(height: 16),
          _buildLocationCard(s),
          const SizedBox(height: 16),
          _buildMessage(s),
          const SizedBox(height: 24),
          if (characters.isNotEmpty) ...[
            const Text('Characters',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...characters.map(_buildCharacterCard),
            const SizedBox(height: 16),
          ],
          if (actions.isNotEmpty) ...[
            const Text('Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: actions
                  .map((a) => ElevatedButton.icon(
                        onPressed: () => _send('action:$a'),
                        icon: Icon(_actionIcon(a)),
                        label: Text(_cap(a)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
          ],
          if (moves.isNotEmpty) ...[
            const Text('Go to',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: moves
                  .map((m) => OutlinedButton.icon(
                        onPressed: () => _send('move:$m'),
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(_cap(m)),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 24),
          ],
          Center(
            child: TextButton.icon(
              onPressed: () => _send('reset'),
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Game'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHud(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [Colors.orange.shade400, Colors.orange.shade700]),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.orange.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _hudItem(Icons.calendar_today, 'Day ${s['day']}'),
          _hudItem(Icons.wb_sunny, _cap(s['time'] as String)),
          _hudItem(Icons.attach_money, '${s['money']}'),
          _hudItem(Icons.bolt, '${s['energy']}'),
        ],
      ),
    );
  }

  Widget _hudItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06), blurRadius: 8)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s['location_name'] as String,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(s['location_description'] as String,
              style: TextStyle(color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Text(s['message'] as String,
          style: const TextStyle(fontSize: 15, height: 1.5)),
    );
  }

  Widget _buildCharacterCard(Map<String, dynamic> c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange,
          child: Text(c['name'][0],
              style: const TextStyle(color: Colors.white)),
        ),
        title: Text(c['name']),
        subtitle: Text('Affection: ${c['affection']}'),
        trailing: ElevatedButton(
          onPressed: () => _send('talk:${c['id']}'),
          child: const Text('Talk'),
        ),
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  IconData _actionIcon(String a) {
    switch (a) {
      case 'study': return Icons.menu_book;
      case 'work': return Icons.work;
      case 'sleep': return Icons.bedtime;
      case 'relax': return Icons.self_improvement;
      case 'shop': return Icons.shopping_bag;
      default: return Icons.star;
    }
  }
}
