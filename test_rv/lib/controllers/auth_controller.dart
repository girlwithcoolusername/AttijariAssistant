import '../services/auth_service.dart';

class AuthController {
  final AuthService _authService;

  AuthController(this._authService);

  Future<bool> login(String username, String password) async {
    return await _authService.login(username, password);
  }
}




