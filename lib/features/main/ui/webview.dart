import 'package:flutter/material.dart';
import 'package:mobile/utils/interactive_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InternalWebView extends StatefulWidget {
  const InternalWebView({Key? key}) : super(key: key);

  @override
  State<InternalWebView> createState() => _InternalWebViewState();
}

class _InternalWebViewState extends State<InternalWebView> {
  WebViewController? wController;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: 1,
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) async {
          wController = controller;

          await wController!.loadFlutterAsset('assets/quill/index.html');

          InteractiveWebView.attach(wController!);
        },
        javascriptChannels: {
          JavascriptChannel(
            name: 'Log',
            onMessageReceived: (JavascriptMessage message) {
              print(message.message);
            },
          ),
          JavascriptChannel(name: "Load", onMessageReceived: (JavascriptMessage message) async {}),
        },
      ),
    );
  }
}
