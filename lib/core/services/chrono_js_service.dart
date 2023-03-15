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
    /*jsRuntime.evaluate("""  
      try {

        var extractDateAndTextWrapper = (text, forwardDate, forwardFromAsIsoString, startFromDateAsIsoString, startDayHour, startFromDateTimeAsIsoString) => {
          var options = {
            forwardDate: forwardDate,
            forwardFrom: forwardFromAsIsoString,
            startFromDate: startFromDateAsIsoString, 
            startDayHour: startDayHour, 
            startFromDateTime: startFromDateTimeAsIsoString, 
          } 
          return ChronoHelper.extractDateAndText(text, options);
        }     
      } catch(e) { 
        console.log(e);  
      }  

    """);*/

    String expression = """ChronoHelper.extractDateAndText("$text",{forwardDate: true});""";

    JsEvalResult jsResult = jsRuntime.evaluate(expression);

    var map = jsResult.rawResult as Map;

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
