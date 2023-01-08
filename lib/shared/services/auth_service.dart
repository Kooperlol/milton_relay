import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // state persistence
  Stream<User?> get authState => _auth.authStateChanges();

  // logging in user
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'An internal error occurred.';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // logging in user with email and password
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'success';
      } else {
        res = 'Please do not leave any fields blank.';
      }
    } catch (err) {
      List<String> split = err.toString().split('/')[1].split("]");
      switch (split[0]) {
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'invalid-credential':
        case 'invalid-password':
        case 'user-not-found':
          return 'The credentials entered are invalid.';
      }
      return err.toString();
    }
    return res;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
