import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:mobile/features/main/ui/chrono_model.dart';

class ChronoNodeJs {
  static final JavascriptRuntime _javascriptRuntime = getJavascriptRuntime();

  static Future<void> init() async {
    _javascriptRuntime.evaluate("""var window = global = globalThis;""");

    await loadJs("assets/js/chrono-node-2.3.8.js");
  }

  static Future<void> loadJs(String file) async {
    String ajvJS = await rootBundle.loadString(file);
    _javascriptRuntime.evaluate(ajvJS);
    print("loaded js package $file");
  }

  static Future<List<ChronoModel>?> parse(String value) async {
    try {
      value = value.replaceAll("\n", "");

      JsEvalResult jsResult = _javascriptRuntime.evaluate("""JSON.stringify(globalThis.parse('$value'));""");
      String result = jsResult.stringResult;

      List<dynamic> objects = jsonDecode(result);

      return objects.map((e) => ChronoModel.fromMap(e)).toList();
    } catch (e, s) {
      print(s);
      return null;
    }
  }

  static Future<DateTime?> parseDate(String value) async {
    try {
      value = value.replaceAll("\n", "");

      JsEvalResult jsResult = _javascriptRuntime.evaluate("""JSON.stringify(globalThis.parseDate('$value'));""");
      String result = jsResult.stringResult;

      return DateTime.parse(result.substring(1, result.length - 1));
    } catch (e, s) {
      print(s);
      return null;
    }
  }
}
