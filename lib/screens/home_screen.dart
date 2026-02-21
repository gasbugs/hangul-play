import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/hangul_data.dart';
import '../widgets/handwriting_canvas.dart';
import '../utils/speech_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user_progress.dart';

import 'stats_screen.dart';
import 'word_forest_screen.dart';
import 'sound_meadow_screen.dart';
import 'profile_screen.dart';

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
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();
  User? _user = FirebaseAuth.instance.currentUser;
  double _lastScorePercentage = 0.0;
  int _lastStars = 0;

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
    // Trigger scoring from canvas
    await _canvasKey.currentState?.submit();
  }

  void _handleScore(int score, double percentage) async {
    if (percentage < 70.0) {
      _canvasKey.currentState?.clear(); // Clear canvas on failure
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

    // Save progress and score to Firestore
    if (_user != null) {
      await _dbService.saveProgress(UserProgress(
        userId: _user!.uid,
        lastIndex: (_currentIndex + 1) % hangulList.length,
        completedChars: [hangulList[_currentIndex].char],
      ));
      
      await FirebaseFirestore.instance.collection('daily_scores').add({
        'userId': _user!.uid,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'score': score,
        'char': hangulList[_currentIndex].char,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }

    // Auto-dismiss after 2.5 seconds
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
                            shape: StadiumBorder(),
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
                    _buildNavigationFooter(),
                  ],
                ),
              ),
            ),
          ),
          if (_showSuccess)
            _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildNavigationFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _navIcon(Icons.map, '월드맵', Colors.amber, () {}),
        _navIcon(Icons.forest, '단어숲', Colors.green, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const WordForestScreen()));
        }),
        _navIcon(Icons.music_note, '소리들판', Colors.blue, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SoundMeadowScreen()));
        }),
        _navIcon(Icons.castle, '훈장성', Colors.purple, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const BadgeCastleScreen()));
        }),
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
            decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return GestureDetector(
      onTap: _goToNextCharacter,
      child: Container(
        color: Colors.white.withOpacity(0.95),
        child: Stack(
          children: [
            // Close button (X)
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                icon: const Icon(Icons.close, size: 40, color: Colors.grey),
                onPressed: _goToNextCharacter,
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉 우와!\n최고예요! 🌈',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFFFF85A1)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_lastScorePercentage.toStringAsFixed(1)}% 맞춰보았어요!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => Icon(
                      Icons.star, 
                      color: index < _lastStars ? Colors.amber : Colors.grey.shade300, 
                      size: index == 1 ? 70 : 50,
                    )),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    '화면을 터작하면\n다음 글자로 넘어가요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                  ),
                  ConfettiWidget(
                    confettiController: _confettiController,
                    blastDirectionality: BlastDirectionality.explosive,
                    shouldLoop: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
