import 'dart:async';
import 'package:flutter/material.dart';
import 'package:serious_python/serious_python.dart';
import 'screens/age_verification_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fire-and-forget: Python's main.py runs serve() and blocks forever.
  // Awaiting here would freeze the UI thread.
  unawaited(SeriousPython.run());
  runApp(const SummerDayApp());
}

class SummerDayApp extends StatelessWidget {
  const SummerDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SummerDay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const AgeVerificationScreen(),
    );
  }
}
