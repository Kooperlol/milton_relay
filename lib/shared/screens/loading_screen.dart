import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/services/auth_service.dart';

import '../routing/routes.dart';
import '../utils/color_util.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Future<FirebaseApp> _initalizeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  @override
  void initState() {
    super.initState();
    _initalizeFirebase().then((value) {
      AuthService().authState.first.then((user) async {
        if (user == null) {
          GoRouter.of(context).goNamed(Routes.login.toName);
        } else {
          GoRouter.of(context).goNamed(Routes.news.toName);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.gray,
      body: Center(
        child: CircularProgressIndicator(
          color: ColorUtil.red,
        ),
      ),
    );
  }
}
