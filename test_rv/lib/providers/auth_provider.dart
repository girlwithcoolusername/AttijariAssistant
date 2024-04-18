import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';


class AuthProvider extends ChangeNotifier {
  late User _user;
  Timer? _logoutTimer;
  Duration _inactiveDuration = const Duration(minutes: 5); // Temps d'inactivité défini à 5 minutes
  final SharedPreferences _prefs;

  AuthProvider(this._prefs) {
    _user = User();
    // Charger les informations d'identification enregistrées lors de la construction du fournisseur
    _loadCredentials();
  }

  // Méthode pour charger les informations d'identification depuis SharedPreferences
  void _loadCredentials() {
    final username = _prefs.getString('username');
    final password = _prefs.getString('password');
    if (username != null && password != null) {
      _user = User(username: username, isLoggedIn: true);
    }
  }

  // Méthode pour enregistrer les informations d'identification dans SharedPreferences
  Future<void> saveCredentials(String username, String password) async {
    _user = User(username: username, isLoggedIn: true);
    notifyListeners();
    await _prefs.setString('username', username);
    await _prefs.setString('password', password);
  }

  User get user => _user;

  Future<bool> login(String username, String password) async {
    final AuthController _authController = AuthController(AuthService());
    final isAuthenticated = await _authController.login(username, password);

    if (isAuthenticated) {
      _user = User(username: username, isLoggedIn: true);
      notifyListeners();

      // Démarrer le minuteur après la connexion réussie
      _startLogoutTimer();

      return true; // Authentification réussie
    } else {
      _user = User(isLoggedIn: false);
      notifyListeners();
      return false; // Authentification échouée
    }
  }

  void logout() {
    _user = User();
    _stopLogoutTimer(); // Arrêter le minuteur lorsque l'utilisateur se déconnecte
    notifyListeners();
  }

  void _startLogoutTimer() {
    _logoutTimer = Timer(_inactiveDuration, () {
      // Déconnectez automatiquement l'utilisateur lorsque le minuteur expire
      logout();
    });
  }

  void _stopLogoutTimer() {
    _logoutTimer?.cancel(); // Arrêter le minuteur s'il est en cours
  }

  // Réinitialiser le minuteur à chaque interaction de l'utilisateur
  void resetLogoutTimer() {
    _stopLogoutTimer();
    _startLogoutTimer();
  }
}
