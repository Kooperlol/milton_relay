import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../services/auth_service.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  // Webview controller which stores data about the website.
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    // Displays loading overlay.
    context.loaderOverlay.show();

    _controller = WebViewController();
    // Listens for the page to be loaded and then hides the loading overlay.
    _controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (finished) {
          setState(() {
            context.loaderOverlay.hide();
          });
        },
        // Blocks any request to leave the TagBox website.
        onNavigationRequest: (request) => NavigationDecision.prevent));
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.loadRequest(Uri.parse('https://widget.taggbox.com/122304'));
    _controller.enableZoom(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
        title: 'News',
        // Shows a logout button as an Icon for Admins.
        icons: AuthService().isAdmin()
            ? [
                IconButton(
                    tooltip: 'Logout',
                    onPressed: () => AuthService().logout(context),
                    icon: const Icon(Icons.exit_to_app))
              ]
            : [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        // Shows the webview only if the content is not loading.
        child: context.loaderOverlay.visible
            ? Container()
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
