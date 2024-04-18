import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:test_rv/utils/text_to_voice.dart';
import 'package:http/http.dart' as http;

class SpeechScreen extends StatefulWidget {
  const SpeechScreen({super.key});

  static String routeName = "/SpeechScreen";

  @override
  State<SpeechScreen> createState() => _SpeechScreenState();
}

class _SpeechScreenState extends State<SpeechScreen> {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  DateTime? _lastTap;
  int _tapCount = 0;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  Future<void> _initSpeech() async {
    bool hasPermission = await _speechToText.hasPermission;
    initSpeech();
    if (hasPermission) {
      TextToVoice.speak(
          "Authentification réussie. Accès autorisé à l'application. Appuyer sur le bouton au milieu de l'écran pour activer ou désactiver le micro");
    } else {
      TextToVoice.speak(
          "Vous n'avez pas encore autorisé l'accès au microphone. Veuillez autoriser l'accès au microphone en appuyant sur trois fois sur l'écran");
    }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }
  void _handleTap() {
    var now = DateTime.now();
    if (_lastTap != null && now.difference(_lastTap!) < Duration(seconds: 1)) {
      _tapCount++;
      if (_tapCount == 3) {
        _requestMicrophonePermission();
        _tapCount = 0;
      }
    } else {
      _tapCount = 1;
    }
    _lastTap = now;
  }

  void _requestMicrophonePermission() async {
    // Demandez la permission d'accéder au microphone
    bool hasPermission = await _speechToText.hasPermission;
    if (hasPermission) {
      TextToVoice.speak(
          "Permission d'accès au microphone accordée avec succès.");
    } else {
      TextToVoice.speak("Échec de l'autorisation d'accès au microphone.");
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) async {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
    if (_speechToText.isNotListening) {
      // Vérifiez si la dernière mise à jour est toujours la même que celle stockée dans _wordsSpoken
      if (_wordsSpoken == result.recognizedWords) {
        // Si oui, envoyez la prédiction au serveur
        var headers = {'Content-Type': 'application/json'};
        var request = http.Request(
            'POST', Uri.parse('http://192.168.116.145:8000/predict_sentiment'));
        request.body = json.encode({"text": _wordsSpoken});
        request.headers.addAll(headers);

        http.StreamedResponse response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          TextToVoice.speak(responseBody);
        } else {
          final reasonPhrase = await response.reasonPhrase.toString();
          TextToVoice.speak(reasonPhrase);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Speech Demo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "listening..."
                    : _speechEnabled
                    ? "Tap the microphone to start listening..."
                    : "Speech not available",
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            if (_speechToText.isNotListening && _confidenceLevel > 0)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ),
                child: Text(
                  "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: 100.0,vertical: 250.0),
        child: AvatarGlow(
          startDelay: const Duration(milliseconds: 1000),
          glowColor: Colors.blueGrey,
          glowShape: BoxShape.circle,
          animate: _speechToText.isListening,
          curve: Curves.fastOutSlowIn,
          child: SizedBox(
            width: 110,
            height: 110,
            child: FloatingActionButton(
              shape: CircleBorder(),
              onPressed:
              _speechToText.isListening ? _stopListening : _startListening,
              tooltip: 'Listen',
              backgroundColor: Colors.blueAccent,
              child: Icon(
                  _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                  size: 35),
            ),
          ),
        ),
      ),
    );
  }
}
