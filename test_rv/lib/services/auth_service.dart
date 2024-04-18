import 'package:http/http.dart' as http;

class AuthService {
  static const String apiUrl = 'https://votre-api.com/login';

  Future<bool> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {'username': username, 'password': password},
      );

      if (response.statusCode == 200) {
        // Authentification réussie
        return true;
      } else {
        // Authentification échouée
        return false;
      }
    } catch (e) {
      print('Erreur lors de l\'authentification: $e');
      return false;
    }
  }
}