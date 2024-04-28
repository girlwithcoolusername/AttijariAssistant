import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:test_rv/providers/auth_provider.dart';
import 'package:test_rv/routes.dart';
import 'package:test_rv/screens/splash_screen.dart';
import 'package:provider/provider.dart';
// import 'package:test_rv/services/disable_accessibility_services.dart';
import 'package:test_rv/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // disableAccessibilityServices();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: ((context) => AuthProvider()),
        ),
      ],
      child:ExcludeSemantics(
        excluding: true, // Set to false to include the button in the semantics tree
        child: MaterialApp(
          home: const SplashScreen(),
          debugShowCheckedModeBanner: false,
          theme: theme(),
          routes: routes,
        ),
      )
    );
  }
}



