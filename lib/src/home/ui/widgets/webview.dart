import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InternalWebView extends StatefulWidget {
  const InternalWebView({Key? key}) : super(key: key);

  @override
  State<InternalWebView> createState() => _InternalWebViewState();
}

class _InternalWebViewState extends State<InternalWebView> {
  final WebViewController controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted);

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
