import 'dart:convert';
import 'package:http/http.dart' as http;

class VoiceBiometricService {
  static const String apiUrl = 'http://192.168.100.35:8080';
  static const String authenticateEndpoint = '/users/authenticate-voice-print';
  static const String loginEndpoint = '/login';
  static const String apiUser = "username";
  static const String apiUserPassword = "password";
  static const String apiUserRole = "ADMIN";

  Future<Map<String, dynamic>?> authenticateUserByVoicePrint(List<double> features) async {
    try {
      // Authenticate user to get token
      final loginResponse = await http.post(
        Uri.parse(apiUrl + loginEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': apiUser,
          'password': apiUserPassword,
          'role': apiUserRole,
        }),
      );

      if (loginResponse.statusCode == 200) {
        final loginData = jsonDecode(loginResponse.body);
        final token = loginData['token'];
        print('Token: $token');


        final userInfoResponse = await http.post(
          Uri.parse(apiUrl + authenticateEndpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'features': features,
          }),
        );

        if (userInfoResponse.statusCode == 200) {
          return jsonDecode(userInfoResponse.body);
        } else {
          print('Failed to retrieve user info: ${userInfoResponse.body}');
          print('Status Code: ${userInfoResponse.statusCode}');
          return null;
        }
      } else {
        print('Authentication failed: ${loginResponse.body}');
        print('Status Code: ${loginResponse.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error during authentication: $e');
      return null;
    }
  }
}
