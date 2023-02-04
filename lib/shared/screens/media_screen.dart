import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({Key? key}) : super(key: key);

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final WebViewController controller = WebViewController();
    controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    controller.loadRequest(
        Uri.parse('https://www.instagram.com/milton_school_district/'));
    controller.enableZoom(false);

    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Container(
        margin: const EdgeInsets.all(20),
        child: Column(
          children: [
            getNavBar(),
            Expanded(
              child: WebViewWidget(controller: _controller),
            )
          ],
        ),
      ),
    );
  }

  GNav getNavBar() {
    return GNav(
        backgroundColor: Colors.white,
        color: Colors.black,
        activeColor: Colors.black45,
        gap: 5,
        tabs: [
          GButton(
            icon: const FaIcon(FontAwesomeIcons.instagram).icon!,
            text: "Instagram",
            onPressed: () => _controller.loadRequest(
                Uri.parse('https://www.instagram.com/milton_school_district/')),
          ),
          GButton(
            icon: Icons.facebook,
            text: "Facebook",
            onPressed: () => _controller.loadRequest(
                Uri.parse('https://www.facebook.com/SchDistofMilton')),
          ),
          GButton(
            icon: const FaIcon(FontAwesomeIcons.twitter).icon!,
            text: "Twitter",
            onPressed: () => _controller
                .loadRequest(Uri.parse('https://twitter.com/SchDistofMilton')),
          )
        ]);
  }
}
