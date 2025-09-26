import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = const FlutterSecureStorage();

  Future<bool> isLoggedIn() async {
    final token = await storage.read(key: "jwt");
    return token != null;
  }

  Future<void> logout() async {
    await storage.delete(key: "jwt");
  }
}
