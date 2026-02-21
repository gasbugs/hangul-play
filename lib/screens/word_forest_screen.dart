import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../widgets/handwriting_canvas.dart';
import '../utils/speech_service.dart';

class WordForestScreen extends StatefulWidget {
  const WordForestScreen({super.key});

  @override
  State<WordForestScreen> createState() => _WordForestScreenState();
}

class _WordForestScreenState extends State<WordForestScreen> {
  final List<Map<String, String>> _words = [
    {'word': '사과', 'image': '🍎', 'meaning': 'Apple'},
    {'word': '나비', 'image': '🦋', 'meaning': 'Butterfly'},
    {'word': '우유', 'image': '🥛', 'meaning': 'Milk'},
    {'word': '포도', 'image': '🍇', 'meaning': 'Grape'},
    {'word': '오이', 'image': '🥒', 'meaning': 'Cucumber'},
  ];

  int _currentIndex = 0;
  bool _showSuccess = false;
  double _lastScorePercentage = 0.0;
  int _lastStars = 0;
  late ConfettiController _confettiController;
  final SpeechService _speechService = SpeechService();
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _speechService.speak(_words[_currentIndex]['word']!);
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _onComplete() async {
    await _canvasKey.currentState?.submit();
  }

  void _handleScore(int score, double percentage) {
    if (percentage < 70.0) {
      _canvasKey.currentState?.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(' 조금 더 정성껏 채워볼까요? 70%를 넘겨보세요!'),
          backgroundColor: Colors.orangeAccent,
          duration: Duration(seconds: 2),
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

    // Auto-advance
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _showSuccess) {
        _goToNextWord();
      }
    });
  }

  void _goToNextWord() {
    if (mounted) {
      setState(() {
        _showSuccess = false;
        _currentIndex = (_currentIndex + 1) % _words.length;
        _canvasKey.currentState?.clear();
      });
      _speechService.speak(_words[_currentIndex]['word']!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        title: const Text('🌳 단어 숲'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _speechService.speak(_words[_currentIndex]['word']!),
            icon: const Icon(Icons.volume_up, color: Colors.green),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_words[_currentIndex]['image']} ${_words[_currentIndex]['word']}',
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                  ),
                  const SizedBox(height: 20),
                  HandwritingCanvas(
                    key: _canvasKey,
                    targetChar: _words[_currentIndex]['word']!,
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
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: const BorderSide(color: Colors.green),
                        ),
                        child: const Text('지우기'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _onComplete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text('채점하기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_showSuccess) _buildSuccessOverlay(),
        ],
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return GestureDetector(
      onTap: _goToNextWord,
      child: Container(
        color: Colors.white.withOpacity(0.9),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🌟 참 잘했어요! 🌟', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green)),
                  const SizedBox(height: 10),
                  Text('${_lastScorePercentage.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 24, color: Colors.blueGrey)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) => Icon(
                      Icons.star,
                      color: index < _lastStars ? Colors.amber : Colors.grey.shade300,
                      size: index == 1 ? 60 : 40,
                    )),
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
