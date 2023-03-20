import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:models/nlp/nlp_date_time.dart';

import 'package:flutter_js/flutter_js.dart';

class ChronoJsLibrary {
  JavascriptRuntime jsRuntime = getJavascriptRuntime();

  dispose() {
    jsRuntime.dispose();
  }

  // Platform messages are asynchronous, so we have to initialize in an async method.
  Future<bool> initJsEngine() async {
    // loads ajv only once into the jsRuntime
    var chronoIsLoaded = jsRuntime.evaluate("""var chronoIsLoaded = (typeof chrono == 'undefined') ? 
          "0" : "1"; chronoIsLoaded; 
        """).stringResult;
    print("Chrono is Loaded $chronoIsLoaded");
    if (chronoIsLoaded == "0") {
      try {
        String chrono = await rootBundle.loadString("assets/js/chrono-custom-rules-master/dist/index.umd.js");

        jsRuntime.evaluate("""var window = global = globalThis;""");

        // ignore: prefer_interpolation_to_compose_strings
        jsRuntime.evaluate(chrono + "");
        return true;
      } on PlatformException catch (e) {
        print('Failed to init js engine: ${e.details}');
        return false;
      } catch (e) {
        print(e);
        return false;
      }
    }
    return true;
  }

  NLPDateTime runNlp(
    String text,
  ) {
    late Map map;

    if (Platform.isAndroid) {
      String expression = """ChronoHelper.extractDateAndText("$text",{forwardDate: true});""";
      JsEvalResult jsResult = jsRuntime.evaluate(expression);

      map = jsResult.rawResult as Map;
    } else if (Platform.isIOS) {
      String expression = """var result = ChronoHelper.extractDateAndText("$text",{forwardDate: true});
    var b = JSON.stringify(result)""";
      jsRuntime.evaluate(expression);

      JsEvalResult result = jsRuntime.evaluate("""b""");
      map = json.decode(result.stringResult) as Map;
    }
    NLPDateTime? nlpDateTime;

    try {
      nlpDateTime = NLPDateTime.fromMap(map);

      print(nlpDateTime.toMap().toString());
      print("Date: ${nlpDateTime.getDate().toString()} time: ${nlpDateTime.getTime().toString()}");
      return nlpDateTime;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
