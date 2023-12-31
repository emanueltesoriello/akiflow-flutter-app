import 'dart:convert';
import 'dart:io';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/src/base/models/chrono_model.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class InteractiveWebView {
  static WebViewController? _wController;

  static void attach(WebViewController controller) {
    _wController = controller;
  }

  

  static Future<Document> htmlToDelta(String html) async {
    html = html.replaceAll('\n', '</br>');

    if (html.isEmpty) {
      return Document();
    }

    try {
      String deltaJson = await _wController!.runJavascriptReturningResult("""htmlToDelta(`$html`);""");

      if (deltaJson == "null") {
        locator<SentryService>().captureException(Exception("can't parse html: $html"));
        return Document();
      }

      List<dynamic> delta;

      // JS interface on Android platform comes as quoted string
      if (Platform.isAndroid) {
        delta = jsonDecode(jsonDecode(deltaJson));
      } else {
        delta = jsonDecode(deltaJson);
      }

      return Document.fromJson(delta);
    } catch (e) {
      locator<SentryService>().addBreadcrumb(message: "html data: $html", category: "debug");
      locator<SentryService>().captureException(e);
      return Document();
    }
  }

  static Future<String> deltaToHtml(List delta) async {
    try {
      String deltaJson = jsonEncode(delta).replaceAll("\\", "\\\\");

      String html = await _wController!.runJavascriptReturningResult("deltaToHtml(`$deltaJson`);");

      // JS interface on Android platform comes as quoted string
      if (Platform.isAndroid) {
        html = jsonDecode(html);
      }

      return html;
    } catch (e) {
      locator<SentryService>().addBreadcrumb(message: "delta to html: ${jsonEncode(delta)}", category: "debug");
      locator<SentryService>().captureException(e);
      rethrow;
    }
  }

  static Future<List<ChronoModel>?> chronoParse(String value) async {
    try {
      value = value.replaceAll("\n", "");

      String result = await _wController!.runJavascriptReturningResult("chronoParse(`$value`);");

      List<dynamic> objects;

      // JS interface on Android platform comes as quoted string
      if (Platform.isAndroid) {
        objects = jsonDecode(jsonDecode(result));
      } else {
        objects = jsonDecode(result);
      }

      return objects.map((e) => ChronoModel.fromMap(e)).toList();
    } catch (_) {
      return null;
    }
  }
}
