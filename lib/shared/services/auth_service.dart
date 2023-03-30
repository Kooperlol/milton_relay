import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/services/user_service.dart';

import '../models/user_model.dart';
import '../routing/routes.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get firebaseUser => _auth.currentUser;
  String getUID() => _auth.currentUser!.uid;

  Future<UserModel> get userModel async =>
      UserService().getUserFromID(getUID());

  bool isAdmin() => _auth.currentUser!.email == 'admin@milton.k12.wi.us';

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

  Future<void> logout(BuildContext context) async {
    GoRouter.of(context).go(Routes.login.toPath);
    await _auth.signOut();
  }
}
