import 'package:flutter/material.dart';

class MapScreen extends StatelessWidget {
  final List<String> exits;
  const MapScreen({super.key, required this.exits});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Map'), backgroundColor: Colors.orange),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange.shade100, Colors.orange.shade300],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // A visual map layout. In the future, you replace this with an Image.asset
            Positioned.fill(
              child: Opacity(
                opacity: 0.2,
                child: Image.network(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/3/30/Map_icon_black.svg/1024px-Map_icon_black.svg.png',
                  fit: BoxFit.contain,
                  errorBuilder: (c, e, s) => const Icon(Icons.map, size: 200, color: Colors.black26),
                ),
              ),
            ),
            Center(
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: exits.map((loc) {
                  return InkWell(
                    onTap: () => Navigator.pop(context, loc),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                        ],
                        border: Border.all(color: Colors.orange, width: 4),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(_getIcon(loc), color: Colors.orange.shade800, size: 32),
                            const SizedBox(height: 4),
                            Text(
                              loc.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String loc) {
    switch (loc) {
      case 'home': return Icons.house;
      case 'school': return Icons.school;
      case 'mall': return Icons.shopping_bag;
      case 'park': return Icons.park;
      default: return Icons.place;
    }
  }
}
