import 'package:flutter/material.dart';
import 'package:test_rv/providers/auth_provider.dart';
import 'package:test_rv/routes.dart';
import 'package:test_rv/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:test_rv/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();
  runApp(MyApp(sharedPreferences: sharedPreferences));
}


class MyApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const MyApp({Key? key, required this.sharedPreferences}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => AuthProvider(sharedPreferences)),
        ),
      ],
      child: MaterialApp(
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
        theme: theme(),
        routes: routes,
      ),
    );
  }
}



