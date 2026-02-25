import 'package:flutter/material.dart';

class NavigationFooter extends StatelessWidget {
  final VoidCallback onMapTap;
  final VoidCallback onForestTap;
  final VoidCallback onMeadowTap;
  final VoidCallback onCastleTap;

  const NavigationFooter({
    super.key,
    required this.onMapTap,
    required this.onForestTap,
    required this.onMeadowTap,
    required this.onCastleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _navIcon(Icons.map, '월드맵', Colors.amber, onMapTap),
        _navIcon(Icons.forest, '단어숲', Colors.green, onForestTap),
        _navIcon(Icons.music_note, '소리들판', Colors.blue, onMeadowTap),
        _navIcon(Icons.castle, '훈장성', Colors.purple, onCastleTap),
      ],
    );
  }

  Widget _navIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2), // Changed withOpacity to withValues
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
