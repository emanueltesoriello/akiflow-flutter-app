import 'package:flutter/material.dart';
import 'package:mobile/src/base/ui/widgets/interactive_webview.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InternalWebView extends StatefulWidget {
  const InternalWebView({Key? key}) : super(key: key);

  @override
  State<InternalWebView> createState() => _InternalWebViewState();
}

class _InternalWebViewState extends State<InternalWebView> {
  final WebViewController controller = WebViewController()..setJavaScriptMode(JavaScriptMode.unrestricted)

      /* ..setNavigationDelegate(
      NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {},
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (NavigationRequest request) {
          if (request.url.startsWith('https://www.youtube.com/')) {
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        },
      ),
    )*/
      ;

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
    /* return SizedBox(
      height: 1,
      width: 1,
      child: WebView(
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (controller) async {
          await controller.loadFlutterAsset('assets/html/index.html');

          InteractiveWebView.attach(controller);
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
    );*/
  }
}
