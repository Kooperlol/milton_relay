import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/services/user_service.dart';

import '../models/user_model.dart';
import '../routing/routes.dart';

class AuthService {
  // Firebase Authentication instance.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Returns the current Firebase user.
  User? get firebaseUser => _auth.currentUser;

  /// Returns the UID of the current Firebase user.
  String getUID() => _auth.currentUser!.uid;

  /// Returns the User Model of the current Firebase User.
  Future<UserModel> get userModel async =>
      UserService().getUserFromID(getUID());

  /// Whether the current Firebase user is an admin.
  bool isAdmin() => _auth.currentUser!.email == 'admin@milton.k12.wi.us';

  /// Logs in a user and returns the result.
  Future<String> loginUser(
    String email,
    String password,
  ) async {
    String res = 'An internal error occurred.';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        // Logging in user with email and password.
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        res = 'success';
      } else {
        res = 'Please do not leave any fields blank.';
      }
    } catch (err) {
      // Gets the error and compares it to common error codes.
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

  /// Logs the current Firebase user out and redirects them to the login screen.
  Future<void> logout(BuildContext context) async {
    GoRouter.of(context).go(Routes.login.toPath);
    await _auth.signOut();
  }
}
