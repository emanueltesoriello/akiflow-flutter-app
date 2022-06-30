import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';

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

  static Future<String> parse(String value) async {
    JsEvalResult jsResult = _javascriptRuntime.evaluate("""JSON.stringify(globalThis.parse('$value'));""");
    return jsResult.stringResult;
  }

  static Future<String> parseDate(String value) async {
    JsEvalResult jsResult = _javascriptRuntime.evaluate("""JSON.stringify(globalThis.parseDate('$value'));""");
    return jsResult.stringResult;
  }
}
