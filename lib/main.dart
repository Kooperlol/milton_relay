import 'package:flutter/material.dart';
import 'package:milton_relay/shared/routing/router.dart';
import 'package:milton_relay/shared/utils/color_util.dart';

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
      routerConfig: router,
      theme: ThemeData(
          colorScheme: ColorScheme(
              primary: ColorUtil.red,
              secondary: ColorUtil.darkRed,
              brightness: Brightness.light,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              error: ColorUtil.gray,
              onError: Colors.white,
              background: ColorUtil.gray,
              onBackground: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black),
          scaffoldBackgroundColor: ColorUtil.gray,
          fontFamily: 'Lato'),
    );
  }
}
