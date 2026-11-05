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
  String _text = "";
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchNext();
  }

  Future<void> _fetchNext() async {
    try {
      final res = await _client.send('{"action": "next_dialogue"}');
      if (!mounted) return;
      if (res['phase'] == 'room') {
        Navigator.pushReplacement(context, FadeRoute(page: const GameScreen()));
        return;
      }
      setState(() {
        _text = res['message'];
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() => _loading = true);
          _fetchNext();
        },
        child: Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(32),
          alignment: Alignment.center,
          child: _loading
              ? const CircularProgressIndicator()
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    _text,
                    key: ValueKey(_text),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24, height: 1.5, fontStyle: FontStyle.italic),
                  ),
                ),
        ),
      ),
    );
  }
}
