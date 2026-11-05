import 'package:flutter/material.dart';
import '../routes/fade_route.dart';
import 'main_menu_screen.dart';

class AgeVerificationScreen extends StatelessWidget {
  const AgeVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Card(
              elevation: 16,
              color: const Color(0xFF232323),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.beach_access,
                        size: 64, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'SummerDay',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'AGE VERIFICATION',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 4,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: Colors.white24, height: 1),
                    const SizedBox(height: 24),
                    const Text(
                      'This game contains mature content intended for adults only. '
                      'Please confirm your age to continue.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.white70),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          elevation: 4,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            FadeRoute(page: const MainMenuScreen()),
                          );
                        },
                        child: const Text(
                          'I am 18 or older',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => _deny(context),
                      child: Text(
                        'I am under 18',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deny(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Access Denied'),
        content: const Text(
            'You must be 18 years or older to play SummerDay.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
