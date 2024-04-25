import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:test_rv/components/size_config.dart';
import 'package:test_rv/constants.dart';
import 'package:test_rv/screens/biometrics_screen.dart';
import 'package:test_rv/utils/text_to_voice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import 'dialog_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  static String routeName = "/SignInScreen";

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SpeechToText _speechToText = SpeechToText();

  bool _speechEnabled = false;
  bool _firstopen = true;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  int _currentQuestionIndex = 0;
  List<String> _questions = [
    "Merci de donner votre nom d'utilisateur.",
    "Merci de donner votre mot de passe.",
    "Voulez-vous enregistrer le login et mot de passe pour les prochaines connexions?"
  ];
  List<String> _answers = [];

  int _failedAttempts = 0;
  int _maxAttempts = 3;

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
      if (_firstopen) {
        await TextToVoice.speak(
            "Authentification réussie. Appuyer sur le bouton au milieu de l'écran pour activer ou désactiver le micro");
        _firstopen = false;
        await Future.delayed(Duration(seconds: 8));
      }
      if(_currentQuestionIndex !=_questions.length -1 ){
        TextToVoice.speak(_questions[_currentQuestionIndex]);
      }
    } else {
      TextToVoice.speak(
          "Authentification réussie. Vous n'avez pas encore autorisé l'accès au microphone. Veuillez autoriser l'accès au microphone en appuyant sur Autoriser au milieu de l'écran pour intéragir avec moi!");
    }
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
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
      if (_wordsSpoken == result.recognizedWords) {
        if (_wordsSpoken.isNotEmpty) {
          _answers.add(_wordsSpoken);
        }
        _currentQuestionIndex++;
        if (_currentQuestionIndex < _questions.length -1) {
          TextToVoice.speak(_questions[_currentQuestionIndex]);
        } else {
          _verifyCredentials();
        }
      }
    }
  }

  void _verifyCredentials() async {
    if (_answers.length >= _questions.length -1) {
      final username = _answers[0].toLowerCase();
      final password = _answers[1].toLowerCase();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      final currentUser = await authProvider.login(username, password);
      print(currentUser!.userId);

      if (currentUser !=null) {
        await TextToVoice.speak(_questions[2]);
        await Future.delayed(const Duration(seconds: 3));

        if (_answers.length > _questions.length - 1) {
          if (_answers[_questions.length - 1].toLowerCase().contains("oui")) {
            await authProvider.saveCredentials(username, password,currentUser.userId);
          }
          await TextToVoice.speak(
            "Authentification réussie. Redirection vers l'écran suivant",
          );
          await Future.delayed(Duration(seconds: 3));
          Navigator.pushNamed(context, DialogScreen.routeName);
          _resetState();
        }
      } else {
        _failedAttempts++;
        if (_failedAttempts >= _maxAttempts) {
          await TextToVoice.speak(
            "Nombre maximal de tentatives échouées atteint.",
          );
          await Future.delayed(Duration(seconds: 3));
          Navigator.pushNamed(context, BiometricsScreen.routeName);
        } else {
          await TextToVoice.speak(
            "Identifiants incorrects. Tentative ${_failedAttempts} sur ${_maxAttempts}.Réessayez!",
          );
          _resetState();
        }
      }
    }
  }



  void _resetState() {
    _currentQuestionIndex = 0;
    _answers.clear();
    _wordsSpoken = "";
    _confidenceLevel = 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _speechToText.isListening ? _stopListening : _startListening,
      child: Scaffold(
        appBar: buildCustomAppBar(context, "Page d'authentification"),
        body: Container(
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _speechToText.isListening
                        ? "écoute..."
                        : _speechEnabled
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
        ),
        floatingActionButton: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: getProportionateScreenWidth(120.0),
              vertical: getProportionateScreenHeight(150.0)),
          child: AvatarGlow(
            startDelay: const Duration(milliseconds: 1000),
            glowColor: Colors.grey,
            glowShape: BoxShape.circle,
            animate: _speechToText.isListening,
            curve: Curves.fastOutSlowIn,
            child: SizedBox(
              width: getProportionateScreenWidth(110),
              height: getProportionateScreenHeight(110),
              child: FloatingActionButton(
                shape: CircleBorder(),
                onPressed:
                _speechToText.isListening ? _stopListening : _startListening,
                tooltip: 'Ecouter',
                backgroundColor: kPrimaryColor,
                child: Icon(
                    _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
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
