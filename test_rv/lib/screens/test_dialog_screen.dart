import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:test_rv/components/description.dart';
import 'package:test_rv/components/logo_and_user_prompt.dart';
import 'package:test_rv/components/mic_button.dart';
import 'package:test_rv/constants.dart';

import '../services/dialog_service.dart';
import '../utils/text_to_voice.dart';

class TestNewDesignedScreen extends StatefulWidget {
  const TestNewDesignedScreen({super.key});

  static String routeName = "/TestDetailsScreen";

  @override
  State<TestNewDesignedScreen> createState() => _TestNewDesignedScreenState();
}

class _TestNewDesignedScreenState extends State<TestNewDesignedScreen> {
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

  @override
  void dispose() {
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: speechToText.isListening ? stopListening : startListening,
      child: Scaffold(
        // each product have a color
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: SvgPicture.asset(
              'assets/icons/Back Icon.svg',
              colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Page des commandes",
            textAlign: TextAlign.end,
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: size.height,
                child: Stack(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.3),
                      padding: EdgeInsets.only(
                        top: size.height * 0.12,
                        left: kDefaultPaddin,
                        right: kDefaultPaddin,
                      ),
                      // height: 500,
                      decoration: const BoxDecoration(
                        gradient: kPrimaryGradientColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: <Widget>[
                          Description(generatedContent: generatedContent,),
                          const SizedBox(height: kDefaultPaddin / 2),
                          const SizedBox(height: kDefaultPaddin / 2),
                          MicButton(isListening: speechToText.isListening, isNotListening: speechToText.isNotListening, startListening: startListening, stopListening: stopListening),
                          if (!speechToText.isListening && _confidenceLevel > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 100,
                              ),
                              child: Text(
                                "Confidence: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            )
                        ],
                      ),
                    ),
                    LogoAndUserPrompt(isListening: speechToText.isListening, isAvailable: speechToText.isAvailable, lastWords: lastWords)
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
