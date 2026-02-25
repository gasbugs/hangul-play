import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playPop() async {
    try {
      await _player.play(AssetSource('sounds/pop.mp3'));
    } catch (e) {
      print('Sound play error: $e');
    }
  }

  Future<void> playSuccess() async {
    try {
      await _player.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      print('Sound play error: $e');
    }
  }
}
