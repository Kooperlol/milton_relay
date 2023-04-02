import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../routing/routes.dart';
import '../utils/color_util.dart';
import '../utils/display_util.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  /// Initializes the Firebase connection.
  Future<FirebaseApp> _initializeFirebase() async =>
      await Firebase.initializeApp();

  @override
  void initState() {
    super.initState();
    // Once the Firebase connection is established, the user is redirected to the dashboard or to login.
    _initializeFirebase().then((value) =>
        FirebaseAuth.instance.currentUser != null
            ? redirectToDashboard(context)
            : context.go(Routes.login.toPath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.gray,
      body: Center(
        // Loading status.
        child: CircularProgressIndicator(
          color: ColorUtil.red,
        ),
      ),
    );
  }
}
