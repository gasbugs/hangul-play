import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/sticker_service.dart';
import '../models/hangul_data.dart';

class StickerBookScreen extends StatefulWidget {
  const StickerBookScreen({super.key});

  @override
  State<StickerBookScreen> createState() => _StickerBookScreenState();
}

class _StickerBookScreenState extends State<StickerBookScreen> {
  final StickerService _stickerService = StickerService();
  final User? _user = FirebaseAuth.instance.currentUser;
  List<String> _earnedStickers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    if (_user != null) {
      final stickers = await _stickerService.getEarnedStickers(_user!.uid);
      setState(() {
        _earnedStickers = stickers;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        title: const Text('✨ 나의 스티커 북 ✨', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF85A1),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: hangulList.length,
                itemBuilder: (context, index) {
                  final char = hangulList[index].char;
                  final isEarned = _earnedStickers.contains(char);

                  return Container(
                    decoration: BoxDecoration(
                      color: isEarned ? Colors.white : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isEarned
                          ? [const BoxShadow(color: Colors.black12, blurRadius: 5)]
                          : [],
                    ),
                    child: Center(
                      child: Text(
                        char,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: isEarned ? const Color(0xFFFF85A1) : Colors.black12,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
