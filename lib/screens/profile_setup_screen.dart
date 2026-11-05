import 'package:flutter/material.dart';
import '../routes/fade_route.dart';
import '../services/game_client.dart';
import 'intro_story_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String preset;
  const ProfileSetupScreen({super.key, required this.preset});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  String _selectedAvatar = 'default';
  bool _loading = false;

  final List<String> _avatars = ['default', 'male1', 'female1', 'cool'];

  Future<void> _finishSetup() async {
    final name = _nameController.text.trim().isEmpty ? 'Player' : _nameController.text.trim();
    setState(() => _loading = true);
    try {
      final client = GameClient();
      // Send setup to Python
      await client.sendRaw('{"action": "setup", "name": "$name", "avatar": "$_selectedAvatar", "preset": "${widget.preset}"}');
      if (!mounted) return;
      Navigator.pushReplacement(context, FadeRoute(page: const IntroStoryScreen()));
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(title: const Text('Your Profile'), backgroundColor: Colors.orange),
      body: _loading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Text('Select Avatar', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                children: _avatars.map((a) => GestureDetector(
                  onTap: () => setState(() => _selectedAvatar = a),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: _selectedAvatar == a ? Colors.orange : Colors.grey.shade800,
                    child: Icon(Icons.person, size: 40, color: _selectedAvatar == a ? Colors.white : Colors.grey),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Character Name',
                  labelStyle: TextStyle(color: Colors.orange),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.orange, width: 2)),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  onPressed: _finishSetup,
                  child: const Text('Begin Story', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
    );
  }
}
