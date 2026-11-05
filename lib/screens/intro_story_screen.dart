import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_client.dart';
import '../routes/fade_route.dart';
import 'game_screen.dart';

class IntroStoryScreen extends StatefulWidget {
  const IntroStoryScreen({super.key});

  @override
  State<IntroStoryScreen> createState() => _IntroStoryScreenState();
}

class _IntroStoryScreenState extends State<IntroStoryScreen> with SingleTickerProviderStateMixin {
  final _client = GameClient();
  late AnimationController _animController;

  String _fullText = "";
  String _displayText = "";
  String _bg = "bus";
  bool _isTyping = false;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Controller for the procedural background animations
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _fetchNext();
  }

  @override
  void dispose() {
    _animController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchNext() async {
    _timer?.cancel();
    setState(() => _loading = true);
    
    try {
      final res = await _client.send('{"action": "next_dialogue"}');
      if (!mounted) return;
      
      if (res['phase'] == 'room') {
        Navigator.pushReplacement(context, FadeRoute(page: const GameScreen()));
        return;
      }

      setState(() {
        _fullText = res['text'];
        _bg = res['bg'];
        _displayText = "";
        _isTyping = true;
        _loading = false;
      });
      
      _startTyping();

    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _startTyping() {
    _timer = Timer.periodic(const Duration(milliseconds: 35), (timer) {
      if (_displayText.length < _fullText.length) {
        setState(() {
          _displayText = _fullText.substring(0, _displayText.length + 1);
        });
      } else {
        _isTyping = false;
        _timer?.cancel();
      }
    });
  }

  void _handleTap() {
    if (_isTyping) {
      _timer?.cancel();
      setState(() {
        _displayText = _fullText;
        _isTyping = false;
      });
    } else {
      _fetchNext();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // 1. PROCEDURAL ANIMATED BACKGROUND
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1500),
              child: SizedBox(
                key: ValueKey(_bg),
                child: AnimatedBuilder(
                  animation: _animController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ScenePainter(_bg, _animController.value),
                      size: MediaQuery.of(context).size,
                    );
                  },
                ),
              ),
            ),

            // 2. DIALOGUE BOX (Summertime Saga Style)
            if (!_loading)
              Positioned(
                bottom: 30, left: 20, right: 20,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade400, width: 2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _displayText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          _isTyping ? "Tap to skip..." : "▼ Tap to continue",
                          style: TextStyle(color: Colors.orange.shade300, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                ),
              ),

            if (_loading)
              const Center(child: CircularProgressIndicator(color: Colors.orange)),
          ],
        ),
      ),
    );
  }
}

// 3. CUSTOM PAINTER FOR PROCEDURAL BACKGROUNDS
class ScenePainter extends CustomPainter {
  final String scene;
  final double animValue;

  ScenePainter(this.scene, this.animValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    if (scene == "bus") {
      // Night sky
      paint.shader = LinearGradient(
        colors: [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Moving Road Lines
      paint.color = Colors.white.withOpacity(0.3);
      final roadY = size.height * 0.75;
      final offset = animValue * 200;
      for (double i = -200; i < size.width + 200; i += 100) {
        canvas.drawRect(Rect.fromLTWH(i + offset, roadY, 50, 8), paint);
        canvas.drawRect(Rect.fromLTWH(i + offset, roadY + 40, 50, 8), paint);
      }

      // Passing Streetlights
      paint.color = Colors.orangeAccent.withOpacity(0.6);
      final lightOffset = (animValue * 400) % (size.width + 200) - 200;
      canvas.drawCircle(Offset(lightOffset, size.height * 0.3), 15, paint);
      canvas.drawCircle(Offset(lightOffset - 150, size.height * 0.35), 10, paint);
      
    } else if (scene == "house") {
      // Sunset Sky
      paint.shader = LinearGradient(
        colors: [const Color(0xFF1A0B2E), const Color(0xFF4A1942), const Color(0xFF893168)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // House Silhouette
      paint.color = Colors.black.withOpacity(0.8);
      final housePath = Path();
      housePath.moveTo(size.width * 0.2, size.height);
      housePath.lineTo(size.width * 0.2, size.height * 0.6);
      housePath.lineTo(size.width * 0.5, size.height * 0.4);
      housePath.lineTo(size.width * 0.8, size.height * 0.6);
      housePath.lineTo(size.width * 0.8, size.height);
      housePath.close();
      canvas.drawPath(housePath, paint);

      // Glowing Porch Light
      paint.color = Colors.amber.withOpacity(0.5 + (animValue * 0.5));
      canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.75), 20, paint);

    } else {
      // Bedroom Morning Sun
      paint.shader = LinearGradient(
        colors: [const Color(0xFFFFD194), const Color(0xFFF37335)],
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Rising Sun
      paint.color = Colors.white.withOpacity(0.8);
      final sunY = size.height * 0.8 - (animValue * size.height * 0.2);
      canvas.drawCircle(Offset(size.width * 0.5, sunY), 100, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
