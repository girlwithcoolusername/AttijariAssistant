import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';
import 'package:provider/provider.dart';


class AuthController extends StatelessWidget {
  final Widget child;

  const AuthController({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: child,
    );
  }

  static AuthProvider of(BuildContext context, {bool listen = true}) {
    return Provider.of<AuthProvider>(context, listen: listen);
  }
}
