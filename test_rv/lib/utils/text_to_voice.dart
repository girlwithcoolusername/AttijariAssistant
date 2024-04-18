import 'package:flutter_tts/flutter_tts.dart';

class TextToVoice {
  static final FlutterTts flutterTts = FlutterTts();

  static Future<void> speak(String message) async {
    await flutterTts.setLanguage("fr-FR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);

    await flutterTts.speak(message);
  }
}