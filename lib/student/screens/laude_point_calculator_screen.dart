import 'package:flutter/material.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';

class LaudePointCalculatorScreen extends StatefulWidget {
  const LaudePointCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LaudePointCalculatorScreen> createState() =>
      _LaudePointCalculatorScreenState();
}

class _LaudePointCalculatorScreenState
    extends State<LaudePointCalculatorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('Laude Point Calculator'),
      body: Container(),
    );
  }
}
