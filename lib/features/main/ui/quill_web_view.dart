import 'package:flutter/material.dart';
import 'package:mobile/utils/quill_converter.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QuillWebView extends StatefulWidget {
  const QuillWebView({Key? key}) : super(key: key);

  @override
  State<QuillWebView> createState() => _QuillWebViewState();
}

class _QuillWebViewState extends State<QuillWebView> {
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

          QuillConverter.attach(wController!);
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
