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

class _IntroStoryScreenState extends State<IntroStoryScreen> {
  final _client = GameClient();
  
  String _fullText = "";
  String _displayText = "";
  String _bg = "bus";
  bool _isTyping = false;
  bool _loading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchNext();
  }

  @override
  void dispose() {
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
        // Story is over, fade into the room!
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
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
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
      // Skip typing animation
      _timer?.cancel();
      setState(() {
        _displayText = _fullText;
        _isTyping = false;
      });
    } else {
      // Next scene
      _fetchNext();
    }
  }

  Widget _buildBackground() {
    // Fallback gradients based on the scene
    List<Color> colors;
    if (_bg == "bus") {
      colors = [Colors.blue.shade900, Colors.blueGrey.shade900];
    } else if (_bg == "house") {
      colors = [Colors.brown.shade800, Colors.brown.shade900];
    } else {
      colors = [Colors.indigo.shade900, Colors.black];
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1500),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      // IF you have real images later, uncomment this:
      // child: Image.asset('assets/backgrounds/$_bg.png', fit: BoxFit.cover, errorBuilder: (c,e,s) => Container()),
    );
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
            // Animated Background
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 1500),
              child: SizedBox(
                key: ValueKey(_bg),
                child: _buildBackground(),
              ),
            ),

            // Content
            if (!_loading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(
                    _displayText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      height: 1.5,
                      fontWeight: FontWeight.w300,
                      shadows: [
                        Shadow(blurRadius: 10, color: Colors.black, offset: Offset(0, 2))
                      ]
                    ),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: Colors.orange)),

            // Cinematic Letterbox Bars (Top and Bottom)
            Positioned(
              top: 0, left: 0, right: 0,
              child: Container(height: 60, color: Colors.black),
            ),
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: Container(height: 60, color: Colors.black),
            ),

            // Hint text at the bottom
            Positioned(
              bottom: 20, right: 20,
              child: Text(
                _isTyping ? "Tap to skip..." : "Tap to continue...",
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }
}
