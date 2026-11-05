import 'package:flutter/material.dart';
import '../routes/fade_route.dart';
import 'profile_setup_screen.dart';

class StatSelectionScreen extends StatelessWidget {
  const StatSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(title: const Text('Choose Your Start'), backgroundColor: Colors.orange),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCard(context, 'Start with Zero', 'Hardcore experience.\nStats: 1\nMoney: $0', 'zero'),
              const SizedBox(height: 16),
              _buildCard(context, 'Start with Mod', 'Balanced experience.\nStats: 5\nMoney: $100', 'mod'),
              const SizedBox(height: 16),
              _buildCard(context, 'Start with Full Stats', 'Story focus.\nStats: 10\nMoney: $500', 'full'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String subtitle, String preset) {
    return InkWell(
      onTap: () {
        Navigator.push(context, FadeRoute(page: ProfileSetupScreen(preset: preset)));
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 8),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
