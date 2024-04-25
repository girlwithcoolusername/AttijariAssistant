import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:test_rv/components/size_config.dart';
import 'package:test_rv/constants.dart';

import '../services/dialog_service.dart';
import '../theme.dart';
import '../utils/text_to_voice.dart';

class DialogScreen extends StatefulWidget {
  const DialogScreen({Key? key});

  static String routeName = "/DialogScreen";

  @override
  State<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  double _confidenceLevel = 0;
  String lastWords = '';
  final DialogService dialogService = DialogService();
  String? generatedContent;
  int start = 200;
  int delay = 200;

  @override
  void initState() {
    super.initState();
    initSpeechToText();
    initTextToSpeech();
  }

  Future<void> initTextToSpeech() async {
    await flutterTts.setSharedInstance(true);
    setState(() {});
  }

  Future<void> initSpeechToText() async {
    await speechToText.initialize();
    setState(() {});
  }

  Future<void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  Future<void> stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      _confidenceLevel = result.confidence;
    });

    if (_confidenceLevel > 0.5) {
      dialogService.getDialog(lastWords).then((response) {
        setState(() {
          generatedContent = response;
          TextToVoice.speak(generatedContent ??
              "Désolé, veuillez reformuler s'il vous plaît.");
        });
      });
    }
  }

  Future<void> systemSpeak(String content) async {
    await flutterTts.speak(content);
  }

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: speechToText.isListening ? stopListening : startListening,
      child: Scaffold(
        appBar: buildCustomAppBar(context, "Page des commandes"),
        body: Container(
          // decoration: const BoxDecoration(gradient: kPrimaryGradientColor),
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    speechToText.isListening
                        ? "écoute..."
                        : speechToText.isAvailable
                            ? "Appuyez sur le microphone pour commencer à écouter..."
                            : "Speech non disponible",
                    style: const TextStyle(fontSize: 20.0),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      lastWords,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ),
                if (!speechToText.isListening && _confidenceLevel > 0)
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
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(120.0),
              vertical: getProportionateScreenHeight(150.0)),
          child: AvatarGlow(
            startDelay: const Duration(milliseconds: 1000),
            glowColor: Colors.blueGrey,
            glowShape: BoxShape.circle,
            animate: speechToText.isListening,
            curve: Curves.fastOutSlowIn,
            child: SizedBox(
              width: getProportionateScreenWidth(110),
              height: getProportionateScreenHeight(110),
              child: FloatingActionButton(
                shape: CircleBorder(),
                onPressed:
                    speechToText.isListening ? stopListening : startListening,
                tooltip: 'Ecouter',
                backgroundColor: kPrimaryColor,
                child: Icon(
                    speechToText.isNotListening ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    size: 35),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
