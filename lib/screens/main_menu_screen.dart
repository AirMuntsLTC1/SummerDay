import 'package:flutter/material.dart';
import '../routes/fade_route.dart';
import 'stat_selection_screen.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Colors.orange.shade400, Colors.orange.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.beach_access, size: 96, color: Colors.white),
              const Text('SummerDay', style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 64),
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(280, 58)),
                onPressed: () => Navigator.push(context, FadeRoute(page: const StatSelectionScreen())),
                child: const Text('New Game', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
