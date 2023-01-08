import 'package:flutter/material.dart';
import 'package:milton_relay/shared/routing/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiltonRelayApp());
}

class MiltonRelayApp extends StatelessWidget {
  const MiltonRelayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Milton Relay',
      routerConfig: AppRouter().router,
    );
  }
}
