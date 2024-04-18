import 'package:flutter/cupertino.dart';
import 'package:test_rv/screens/biometrics_screen.dart';
import 'package:test_rv/screens/sign_in_screen.dart';
import 'package:test_rv/screens/speech_screen.dart';
import 'package:test_rv/screens/test_screen.dart';

final Map<String, WidgetBuilder> routes = {
  SpeechScreen.routeName: (context) => SpeechScreen(),
  BiometricsScreen.routeName: (context) => BiometricsScreen(),
  SignInScreen.routeName : (context) => SignInScreen(),
  TestScreen.routeName: (context) => TestScreen()


};