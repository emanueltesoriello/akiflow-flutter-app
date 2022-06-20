import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:webview_flutter/webview_flutter.dart';

class QuillConverter {
  static WebViewController? wController;

  static void attach(WebViewController controller) {
    wController = controller;
  }

  static Future<Document> htmlToDelta(String html) async {
    html = html.replaceAll('\n', '');

    String deltaJson = await wController!.runJavascriptReturningResult("""htmlToDelta('$html');""");

    List<dynamic> delta;

    // JS interface on Android platform comes as quoted string
    if (Platform.isAndroid) {
      delta = jsonDecode(jsonDecode(deltaJson));
    } else {
      delta = jsonDecode(deltaJson);
    }

    return Document.fromJson(delta);
  }

  static Future<String> deltaToHtml(List delta) async {
    String deltaJson = jsonEncode(delta).replaceAll("\\", "\\\\");

    String html = await wController!.runJavascriptReturningResult("deltaToHtml(`$deltaJson`);");

    // JS interface on Android platform comes as quoted string
    if (Platform.isAndroid) {
      html = jsonDecode(html);
    }

    return html;
  }
}
