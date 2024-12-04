import 'package:pocketbase/pocketbase.dart';

class AuthService {
  final PocketBase pb = PocketBase('https://zmartrest-pb.cloud.spetsen.net/');

  // Login user
  Future<bool> login(String email, String password) async {
    try {
      await pb.collection('users').authWithPassword(email, password);
      return true;
    } catch (e) {
      print('Login failed: $e');
      return false;
    }
  }

  // Register user
  Future<bool> register(String email, String password) async {
    try {
      await pb.collection('users').create(body: {
        'email': email,
        'password': password,
        'passwordConfirm': password
      });
      return true;
    } catch (e) {
      print('Registration failed: $e');
      return false;
    }
  }

  // Logout
  void logout() {
    pb.authStore.clear();
  }

  // Check if user is authenticated
  bool get isAuthenticated => pb.authStore.isValid;
}