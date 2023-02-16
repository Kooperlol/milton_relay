import 'package:flutter/material.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({Key? key}) : super(key: key);

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController();
    _controller.setNavigationDelegate(NavigationDelegate(
        onPageFinished: (progress) => setState(() {
              if (mounted) _loading = false;
            }),
        onNavigationRequest: (request) => NavigationDecision.prevent));
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.loadRequest(Uri.parse('https://widget.taggbox.com/122304'));
    _controller.enableZoom(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : WebViewWidget(controller: _controller),
      ),
    );
  }
}
