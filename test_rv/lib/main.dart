import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test_rv/providers/auth_provider.dart';
import 'package:test_rv/providers/dialog_provider.dart';
import 'package:test_rv/routes.dart';
import 'package:test_rv/screens/splash_screen.dart';
import 'package:test_rv/services/auth_service.dart';
import 'package:test_rv/services/dialog_service.dart';
// import 'package:test_rv/services/disable_accessibility_services.dart';
import 'package:test_rv/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // disableAccessibilityServices();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AuthService authService = AuthService();
  final DialogService dialogService = DialogService(prefs);
  runApp(MyApp(prefs: prefs, authService: authService, dialogService: dialogService,));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final AuthService authService;
  final DialogService dialogService;

  MyApp(
      {Key? key,
      required this.prefs,
      required this.authService,
      required this.dialogService})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: ((context) => AuthProvider(authService, prefs)),
          ),
          ChangeNotifierProvider(
            create: ((context) => DialogProvider(dialogService)),
          )
        ],
        child: ExcludeSemantics(
          excluding: true,
          // Set to false to include the button in the semantics tree
          child: MaterialApp(
            home: const SplashScreen(),
            debugShowCheckedModeBanner: false,
            theme: theme(),
            routes: routes,
          ),
        ));
  }
}
