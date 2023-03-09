import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_js/flutter_js.dart';

class TestJsLibrary extends StatefulWidget {
  const TestJsLibrary({super.key});

  @override
  State<TestJsLibrary> createState() => _TestJsLibraryState();
}

class _TestJsLibraryState extends State<TestJsLibrary> {
  final JavascriptRuntime jsRuntime = getJavascriptRuntime();
  Future<dynamic>? _loadingFuture;

  @override
  void initState() {
    super.initState();
    _loadingFuture = initJsEngine();
  }

  // Platform messages are asynchronous, so we have to initialize in an async method.
  Future<void> initJsEngine() async {
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
      } on PlatformException catch (e) {
        print('Failed to init js engine: ${e.details}');
      } catch (e) {
        print(e);
      }
    }

    if (!mounted) return;
  }

  test() {
    jsRuntime.evaluate("""  
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

    """);
    String text = "Ciao today at 17:00 make";
    String expression = """ChronoHelper.extractDateAndText("$text");""";

    JsEvalResult jsResult = jsRuntime.evaluate(expression);

    var map = jsResult.rawResult as Map;
    print(map.toString());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadingFuture,
      builder: (_, snapshot) => snapshot.connectionState == ConnectionState.waiting
          ? const Center(child: Text('Loading...'))
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextFormField(
                      decoration: const InputDecoration(hintText: 'Insert text..'),
                    ),
                  ),
                  ElevatedButton(onPressed: test, child: Text('Teeest JS'))
                ],
              ),
            ),
    );
  }
}
