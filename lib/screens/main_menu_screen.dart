import 'package:flutter/material.dart';
import '../routes/fade_route.dart';
import 'game_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade400, Colors.orange.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.beach_access, size: 96, color: Colors.white),
              const SizedBox(height: 12),
              const Text(
                'SummerDay',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'A VISUAL NOVEL',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  letterSpacing: 6,
                ),
              ),
              const SizedBox(height: 64),
              _MenuButton(
                label: 'New Game',
                icon: Icons.play_arrow,
                onTap: () {
                  Navigator.of(context).push(
                    FadeRoute(page: const GameScreen()),
                  );
                },
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'Continue',
                icon: Icons.restore,
                enabled: false,
                onTap: () {},
              ),
              const SizedBox(height: 16),
              _MenuButton(
                label: 'About',
                icon: Icons.info_outline,
                onTap: () => _showAbout(context),
              ),
              const SizedBox(height: 48),
              Text('v0.1.0',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.35), fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('SummerDay'),
        content: const Text(
            'An offline visual novel built with Flutter, Python, and C++.\n\nVersion 0.1.0'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _MenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 58,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: enabled ? Colors.white : Colors.white24,
          foregroundColor: enabled ? Colors.orange.shade900 : Colors.white54,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(29)),
          elevation: enabled ? 6 : 0,
        ),
        onPressed: enabled ? onTap : null,
        icon: Icon(icon),
        label: Text(label,
            style: const TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
