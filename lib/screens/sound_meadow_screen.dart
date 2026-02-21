import 'package:flutter/material.dart';
import '../utils/speech_service.dart';

class SoundMeadowScreen extends StatefulWidget {
  const SoundMeadowScreen({super.key});

  @override
  State<SoundMeadowScreen> createState() => _SoundMeadowScreenState();
}

class _SoundMeadowScreenState extends State<SoundMeadowScreen> {
  final SpeechService _speechService = SpeechService();
  final List<String> _letters = ['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ', 'ㅈ', 'ㅊ'];
  late String _targetLetter;
  late List<String> _options;

  @override
  void initState() {
    super.initState();
    _generateQuiz();
  }

  void _generateQuiz() {
    setState(() {
      _targetLetter = (_letters..shuffle()).first;
      _options = [_targetLetter];
      
      // Select 3 random distractors
      List<String> distractors = _letters.where((l) => l != _targetLetter).toList()..shuffle();
      _options.addAll(distractors.take(3));
      _options.shuffle();
    });
    _speechService.speak(_targetLetter);
  }

  void _checkAnswer(String letter) {
    if (letter == _targetLetter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('🎉 정답이에요! 최고!'), backgroundColor: Colors.green),
      );
      Future.delayed(const Duration(seconds: 1), _generateQuiz);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('😢 다른 꽃을 눌러볼까요?'), backgroundColor: Colors.orange),
      );
      _speechService.speak(_targetLetter);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9C4), // Light Yellow
      appBar: AppBar(
        title: const Text('🌷 소리 들판'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '들리는 소리의 꽃을 찾아주세요!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 20),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 60, color: Colors.orange),
              onPressed: () => _speechService.speak(_targetLetter),
            ),
            const SizedBox(height: 40),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: _options.map((letter) => _buildFlower(letter)).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlower(String letter) {
    return GestureDetector(
      onTap: () => _checkAnswer(letter),
      child: Column(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://cdn-icons-png.flaticon.com/512/2927/2927236.png'), // Flower icon
                fit: BoxFit.contain,
              ),
            ),
            child: Center(
              child: Text(
                letter,
                style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text('눌러보세요!', style: TextStyle(fontSize: 12, color: Colors.brown)),
        ],
      ),
    );
  }
}
