import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import '../utils/color_util.dart';
import '../utils/display_util.dart';
import '../widgets/app_bar_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text field widgets for login information.
  final TextEditingController _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  /// Disposes text field widgets.
  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  /// Logs the user in and redirects them to the dashboard.
  Future<void> _login() async {
    context.loaderOverlay.show();
    String res = await AuthService()
        .loginUser(_emailController.text, _passwordController.text);
    if (!mounted) return;
    if (res == 'success') {
      redirectToDashboard(context);
    } else {
      showSnackBar(context, res);
    }
    context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorUtil.gray,
      appBar: const AppBarWidget(title: 'Milton Relay'),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox.square(
              dimension: 32,
            ),
            // Login Vector.
            SvgPicture.asset('assets/welcome-vector.svg',
                width: 200, height: 200),
            const SizedBox.square(
              dimension: 32,
            ),
            // Welcome back text.
            const Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
              ),
            ),
            const SizedBox.square(
              dimension: 32,
            ),
            // Email input field.
            LoginInputField(
              textEditingController: _emailController,
              textInputType: TextInputType.emailAddress,
              hintText: 'Enter your school email',
            ),
            const SizedBox.square(
              dimension: 16,
            ),
            // Password input field.
            LoginInputField(
              textEditingController: _passwordController,
              textInputType: TextInputType.text,
              hintText: 'Enter your school password',
              isPass: true,
            ),
            const SizedBox.square(
              dimension: 32,
            ),
            // Login button which calls [_login].
            InkWell(
              onTap: _login,
              customBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                color: ColorUtil.red,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

/// Custom Text Input field to decorate the login fields.
class LoginInputField extends StatelessWidget {
  final TextEditingController textEditingController;
  final bool isPass;
  final String hintText;
  final TextInputType textInputType;

  const LoginInputField({
    Key? key,
    required this.textEditingController,
    this.isPass = false,
    required this.hintText,
    required this.textInputType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.0),
    );

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
        hintText: hintText,
        border: border,
        fillColor: Colors.white,
        focusedBorder: border,
        enabledBorder: border,
        filled: true,
        contentPadding: const EdgeInsets.all(8),
      ),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
