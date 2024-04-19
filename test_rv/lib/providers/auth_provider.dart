import 'dart:async';

import 'package:flutter/material.dart';

import '../models/utilisateur.dart';
import '../services/auth_service.dart';

import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  Utilisateur? _currentUser;

  Utilisateur? get currentUser => _currentUser;

  Future<Utilisateur?> login(String username, String password) async {
    final userInfo = await _authService.getUserInfo(username, password);
    if (userInfo != null) {
      _currentUser = Utilisateur.fromMap(userInfo);
      notifyListeners();
      return _currentUser;
    } else {
      return null;
    }
  }

  Future<void> saveCredentials(String username, String password,int userid) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setInt('userId', userid);
    await prefs.setString('password', password);
  }

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
    await clearCredentials();
  }

  Future<void> clearCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('username');
    await prefs.remove('password');
  }

  Future<void> tryAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username');
    final savedPassword = prefs.getString('password');
    if (savedUsername != null && savedPassword != null) {
      await login(savedUsername, savedPassword);
    }
  }
}

