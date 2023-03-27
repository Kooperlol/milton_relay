import 'package:drop_shadow/drop_shadow.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/widgets/text_field_widget.dart';
import '../utils/color_util.dart';
import '../utils/display_util.dart';
import '../widgets/app_bar_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController(),
      _passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  void login() async {
    context.loaderOverlay.show();
    String res = await AuthService().loginUser(
        email: _emailController.text, password: _passwordController.text);
    if (!mounted) return;
    if (res == 'success') {
      GoRouter.of(context).goNamed(Routes.adminNews.toName);
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
            SvgPicture.asset('assets/welcome-vector.svg',
                width: 200, height: 200),
            const SizedBox.square(
              dimension: 32,
            ),
            const Text(
              'Welcome Back!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontFamily: 'Lato',
              ),
            ),
            const SizedBox.square(
              dimension: 32,
            ),
            TextFieldInput(
              textEditingController: _emailController,
              textInputType: TextInputType.emailAddress,
              hintText: 'Enter your school email',
            ),
            const SizedBox.square(
              dimension: 16,
            ),
            TextFieldInput(
              textEditingController: _passwordController,
              textInputType: TextInputType.text,
              hintText: 'Enter your school password',
              isPass: true,
            ),
            const SizedBox.square(
              dimension: 32,
            ),
            DropShadow(
              blurRadius: 5,
              opacity: 0.5,
              child: InkWell(
                onTap: login,
                customBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  color: ColorUtil.red,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: const Text(
                    'Login',
                    style: TextStyle(
                        fontFamily: 'Lato', fontSize: 25, color: Colors.white),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
