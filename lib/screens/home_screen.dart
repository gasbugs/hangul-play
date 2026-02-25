import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hangul_data.dart';
import '../widgets/handwriting_canvas.dart';
import '../utils/speech_service.dart';
import '../services/database_service.dart';
import '../models/user_progress.dart';
import '../services/sticker_service.dart';
import 'sticker_book_screen.dart';
import 'word_forest_screen.dart';
import 'sound_meadow_screen.dart';
import 'profile_screen.dart';
import '../widgets/navigation_footer.dart';
import '../widgets/success_overlay.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _showSuccess = false;
  late ConfettiController _confettiController;
  final SpeechService _speechService = SpeechService();
  final DatabaseService _dbService = DatabaseService();
  final StickerService _stickerService = StickerService(); // Add StickerService
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();
  final User? _user = FirebaseAuth.instance.currentUser;
  double _lastScorePercentage = 0.0;
  int _lastStars = 0;
  int _currentStreak = 0; // Add this

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _loadUserProgress();
  }

  Future<void> _loadUserProgress() async {
    if (_user != null) {
      final progress = await _dbService.getProgress(_user!.uid);
      if (progress != null) {
        setState(() {
          _currentIndex = progress.lastIndex;
        });
      }
    }
    _speechService.speak(hangulList[_currentIndex].char);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onComplete() async {
    await _canvasKey.currentState?.submit();
  }

  void _handleScore(int score, double percentage) async {
    if (percentage < 70.0) {
      _canvasKey.currentState?.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' 조금 더 정성껏 채워야 해요! 70%를 못 넘었어요. 다시 해볼까요?'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    _confettiController.play();
    setState(() {
      _showSuccess = true;
      _lastScorePercentage = percentage;
      _lastStars = score;
    });

    if (_user != null) {
      final char = hangulList[_currentIndex].char;
      
      // Save progress (this also updates streak)
      await _dbService.saveProgress(UserProgress(
        userId: _user!.uid,
        lastIndex: (_currentIndex + 1) % hangulList.length,
        completedChars: [char],
      ));
      
      // Award sticker
      await _stickerService.awardSticker(_user!.uid, char);
      
      // Get updated streak for the overlay
      final progress = await _dbService.getProgress(_user!.uid);
      final currentStreak = (progress != null) ? (progress.toMap()['streak'] ?? 0) : 0;

      setState(() {
        _showSuccess = true;
        _lastScorePercentage = percentage;
        _lastStars = score;
        _currentStreak = currentStreak; // Store in local state
      });

      await FirebaseFirestore.instance.collection('daily_scores').add({
        'userId': _user!.uid,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'score': score,
        'char': char,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _showSuccess) {
        _goToNextCharacter();
      }
    });
  }

  void _goToNextCharacter() {
    if (mounted && _showSuccess) {
      setState(() {
        _showSuccess = false;
        _currentIndex = (_currentIndex + 1) % hangulList.length;
        _canvasKey.currentState?.clear();
      });
      _speechService.speak(hangulList[_currentIndex].char);
    }
  }

  void _playSound() {
    _speechService.speak(hangulList[_currentIndex].char);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            if (_user?.photoURL != null)
              CircleAvatar(
                backgroundImage: NetworkImage(_user!.photoURL!),
                radius: 18,
              ),
            const SizedBox(width: 10),
            Text(
              '${_user?.displayName ?? "아이"}의 공부방',
              style: const TextStyle(fontSize: 16, color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StickerBookScreen())),
            icon: const Icon(Icons.auto_awesome, color: Color(0xFFFF85A1)),
            tooltip: '나의 스티커 북',
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
            icon: const Icon(Icons.account_circle, color: Color(0xFFFF85A1)),
            tooltip: '프로필',
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '✨ 한글 놀이 ✨',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF85A1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      '글자를 예쁘게 따라 써봐요!',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD93D),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            '${_currentIndex + 1} / ${hangulList.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          onPressed: _playSound,
                          icon: const Icon(Icons.volume_up),
                          label: const Text('소리 듣기'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF2C3E50),
                            side: const BorderSide(color: Color(0xFF77E4D4), width: 2),
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    HandwritingCanvas(
                      key: _canvasKey,
                      targetChar: hangulList[_currentIndex].char,
                      onClear: () {},
                      onComplete: _handleScore,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _canvasKey.currentState?.clear(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB7B2),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('다시 그리기', style: TextStyle(color: Colors.white, fontSize: 18)),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: _onComplete,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFB2E2F2),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          ),
                          child: const Text('채점해줘요!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    NavigationFooter(
                      onMapTap: () {},
                      onForestTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const WordForestScreen())),
                      onMeadowTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SoundMeadowScreen())),
                      onCastleTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StickerBookScreen())),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showSuccess)
            SuccessOverlay(
              scorePercentage: _lastScorePercentage,
              stars: _lastStars,
              streak: _currentStreak, // Add this
              confettiController: _confettiController,
              onDismiss: _goToNextCharacter,
            ),
        ],
      ),
    );
  }
}
