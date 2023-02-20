import 'package:flutter/material.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    context.loaderOverlay.show();

    _controller = WebViewController();
    _controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (finished) {
          if (mounted) {
            setState(() => context.loaderOverlay.hide());
          }
        },
        onNavigationRequest: (request) => NavigationDecision.prevent));
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.loadRequest(Uri.parse('https://widget.taggbox.com/122304'));
    _controller.enableZoom(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar('News'),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: context.loaderOverlay.visible
            ? Container()
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
