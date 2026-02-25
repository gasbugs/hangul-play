import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../models/stage_model.dart';
import '../widgets/handwriting_canvas.dart';
import '../utils/speech_service.dart';
import '../widgets/success_overlay.dart';

class MagicCanvasScreen extends StatefulWidget {
  const MagicCanvasScreen({super.key});

  @override
  State<MagicCanvasScreen> createState() => _MagicCanvasScreenState();
}

class _MagicCanvasScreenState extends State<MagicCanvasScreen> {
  Stage _currentStage = hangulStages[0];
  int _currentLevelIndex = 0;
  int _currentCharIndex = 0;
  bool _showSuccess = false;
  late ConfettiController _confettiController;
  final SpeechService _speechService = SpeechService();
  final GlobalKey<HandwritingCanvasState> _canvasKey = GlobalKey<HandwritingCanvasState>();

  double _lastScorePercentage = 0.0;
  int _lastStars = 0;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 1));
    _speechService.speak(_currentTargetChar);
  }

  String get _currentTargetChar => 
      _currentStage.levels[_currentLevelIndex].targetChars[_currentCharIndex];

  Level get _currentLevel => _currentStage.levels[_currentLevelIndex];

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _handleScore(int score, double percentage) {
    _confettiController.play();
    setState(() {
      _showSuccess = true;
      _lastScorePercentage = percentage;
      _lastStars = score;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _showSuccess) {
        _next();
      }
    });
  }

  void _next() {
    setState(() {
      _showSuccess = false;
      if (_currentCharIndex < _currentLevel.targetChars.length - 1) {
        _currentCharIndex++;
      } else if (_currentLevelIndex < _currentStage.levels.length - 1) {
        _currentLevelIndex++;
        _currentCharIndex = 0;
      } else {
        // Stage completed! Show celebration and go back to map or next stage
        Navigator.pop(context);
        return;
      }
      _canvasKey.currentState?.clear();
    });
    _speechService.speak(_currentTargetChar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF6E3),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${_currentStage.name} - ${_currentLevel.title}',
          style: const TextStyle(color: Color(0xFF2C3E50), fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text(
                    _currentLevel.type == StageType.puzzle ? '🧩 조각을 맞춰봐요!' : '✍️ 예쁘게 써봐요!',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 20),
                  HandwritingCanvas(
                    key: _canvasKey,
                    targetChar: _currentTargetChar,
                    isPuzzleMode: _currentLevel.type == StageType.puzzle,
                    onClear: () {},
                    onComplete: _handleScore,
                  ),
                  const SizedBox(height: 30),
                  if (_currentLevel.type == StageType.drawing)
                    ElevatedButton(
                      onPressed: () => _canvasKey.currentState?.submit(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB2E2F2),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: const Text('다 썼어요!', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ),
          if (_showSuccess)
            SuccessOverlay(
              scorePercentage: _lastScorePercentage,
              stars: _lastStars,
              streak: 0, // Simplified for now
              confettiController: _confettiController,
              onDismiss: _next,
            ),
        ],
      ),
    );
  }
}
