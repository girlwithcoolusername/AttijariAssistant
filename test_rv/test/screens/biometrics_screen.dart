// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:test_rv/screens/biometrics_screen.dart';
// import 'package:test_rv/screens/dialog_screen.dart';
// import 'package:test_rv/screens/sign_in_screen.dart';
// import 'package:test_rv/utils/authentication.dart';
// import 'package:test_rv/utils/text_to_voice.dart';
//
// class MockNavigatorObserver extends Mock implements NavigatorObserver {}
// class MockTextToVoice extends Mock implements TextToVoice {}
// class MockAuthentication extends Mock implements Authentication {}
// class MockSharedPreferences extends Mock implements SharedPreferences {}
//
// void main() {
//   late MockNavigatorObserver mockObserver;
//   late MockTextToVoice mockTextToVoice;
//   late MockAuthentication mockAuthentication;
//   late MockSharedPreferences mockSharedPreferences;
//
//   setUp(() {
//     mockObserver = MockNavigatorObserver();
//     mockTextToVoice = MockTextToVoice();
//     mockAuthentication = MockAuthentication();
//     mockSharedPreferences = MockSharedPreferences();
//   });
//
//   testWidgets('BiometricsScreen navigates to DialogScreen when authenticated and userId exists',
//           (WidgetTester tester) async {
//         when(() => mockAuthentication.authenticate(any())).thenAnswer((_) async => true);
//         when(() => mockSharedPreferences.getInt('userId')).thenReturn(1);
//
//         await tester.pumpWidget(
//           MaterialApp(
//             home: BiometricsScreen(),
//             navigatorObservers: [mockObserver],
//           ),
//         );
//
//         verify(() => mockObserver.didPush(any(that: isRoute(DialogScreen.routeName)), any()));
//       });
//
//   testWidgets('BiometricsScreen navigates to SignInScreen when authenticated and userId does not exist',
//           (WidgetTester tester) async {
//         when(() => mockAuthentication.authenticate(any())).thenAnswer((_) async => true);
//         when(() => mockSharedPreferences.getInt('userId')).thenReturn(null);
//
//         await tester.pumpWidget(
//           MaterialApp(
//             home: BiometricsScreen(),
//             navigatorObservers: [mockObserver],
//           ),
//         );
//
//         verify(() => mockObserver.didPush(any(that: isRoute(SignInScreen.routeName)), any()));
//       });
//
//   testWidgets('BiometricsScreen speaks instructions on initState', (WidgetTester tester) async {
//     when(() => mockTextToVoice.speak(any())).thenAnswer((_) async => {});
//
//     await tester.pumpWidget(
//       MaterialApp(
//         home: BiometricsScreen(),
//       ),
//     );
//
//     verify(() => mockTextToVoice.speak("Appuyer trois fois sur l'écran pour vous authentifier")).called(1);
//   });
//
// }