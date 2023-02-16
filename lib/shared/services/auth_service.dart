import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/roles.dart';
import '../models/user.dart';
import '../utils/collections.dart';

class AuthService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get firebaseUser => _auth.currentUser;
  String getUID() => _auth.currentUser!.uid;

  Future<UserModel?> get userModel async {
    QuerySnapshot snapshot = await _db
        .collection(Collections.users.toPath)
        .where('id', isEqualTo: getUID())
        .get();
    if (snapshot.docs.isNotEmpty) {
      QueryDocumentSnapshot document = snapshot.docs.first;
      return UserModel(
          getUID(),
          (document.get('firstName') as String),
          (document.get('lastName') as String),
          (document.get('avatarURL') as String),
          Roles.values
              .where((element) =>
                  element.toName == (document.get('role') as String))
              .first);
    }
    return null;
  }

  bool isAdmin() {
    return _auth.currentUser!.email == 'admin@milton.k12.wi.us';
  }

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

  Future<void> logout() async => await _auth.signOut();
}
