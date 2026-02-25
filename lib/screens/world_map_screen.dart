import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'word_forest_screen.dart';
import 'sound_meadow_screen.dart';
import 'profile_screen.dart';
import 'sticker_book_screen.dart';

class WorldMapScreen extends StatelessWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            icon: const Icon(Icons.account_circle, color: Colors.indigo, size: 35),
          ),
          const SizedBox(width: 10),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFB2E2F2), Color(0xFFE8F5E9)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '어디로 모험을 떠날까요?',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    // A simple representation of islands on a map
                    _buildIsland(context, '마법 캔버스', Icons.edit, Colors.amber, 0.2, 0.2, const HomeScreen()),
                    _buildIsland(context, '단어 숲', Icons.forest, Colors.green, 0.6, 0.1, const WordForestScreen()),
                    _buildIsland(context, '소리 들판', Icons.music_note, Colors.orange, 0.4, 0.4, const SoundMeadowScreen()),
                    _buildIsland(context, '훈장 성', Icons.castle, Colors.purple, 0.1, 0.6, const StickerBookScreen()),
                    _buildIsland(context, '문장 놀이터', Icons.videogame_asset, Colors.blue, 0.7, 0.7, null), // TODO
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIsland(BuildContext context, String label, IconData icon, Color color, double top, double left, Widget? target) {
    return Positioned(
      top: MediaQuery.of(context).size.height * top,
      left: MediaQuery.of(context).size.width * left,
      child: GestureDetector(
        onTap: () {
          if (target != null) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => target));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('🚧 아직 준비 중이에요! 곧 만나요!')),
            );
          }
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 15, spreadRadius: 5)],
                border: Border.all(color: color, width: 3),
              ),
              child: Icon(icon, color: color, size: 50),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.8), borderRadius: BorderRadius.circular(15)),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
