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
    print("Chrono is Loaded $chronoIsLoaded"); //console.log(typeof customChrono);
    if (chronoIsLoaded == "0") {
      try {
        String chrono = await rootBundle.loadString("assets/js/chrono-custom-rules-master/dist/index.umd.js");

        jsRuntime.evaluate("""var window = global = globalThis;""");

        // ignore: prefer_interpolation_to_compose_strings
        jsRuntime.evaluate(chrono + "");

        jsRuntime.evaluate(""" 
          console.log('GLOBAL', global);
          const customChrono = chrono.casual.clone()

          customChrono.parsers.push(customParsers.tod)
          customChrono.parsers.push(customParsers.toda)
          customChrono.parsers.push(customParsers.tom)
          customChrono.parsers.push(customParsers.tmrw)
          customChrono.parsers.push(customParsers.tmw)
          customChrono.parsers.push(customParsers.tmr)
          customChrono.parsers.push(customParsers.addMinutes)
        """);

        // jsRuntime.evaluate(chrono + "");
        jsRuntime.evaluate(""" 
         export function extractDateAndText (text, options) {
            // forwardDate expect a date in the format yyyy-mm-dd
            if(options.forwardFrom) {
              const dateString = options.forwardFrom + ' 00:00:00';
              options.forwardFrom = new Date(dateString)
            } 
            return customExtractor(customChrono as any, text, options)
          }
        """);
        var a = 0;
        /*jsRuntime.evaluate("""
const text = 'Do laundry =1h30m, clean room';
const result = extractDurationAndText(text);

console.log(result.duration); // outputs: 5400 (duration in seconds) 
console.log(result.textWithoutDuration); // outputs: 'Do laundry, clean room' 
""");*/

        //jsRuntime.evaluate(chrono + "");
        jsRuntime.evaluate(""" 
          const extractDurationAndText = function (text) {
            try { 
              console.log("GLOBAL 2");
            } catch (e) {
              console.log("error", e);
            }
            // const parse = customExtractor(customChrono as any, "ciao", { forwardDate: true, forwardFrom: new Date(), startDayHour: 9 });
            return { duration: "2", textWithoutDuration: "ciao!" }; 
          };
        """);
        var b = 0;
        /*jsRuntime.evaluate("""
const text = 'Do laundry =1h30m, clean room';
const result = extractDurationAndText(text);
 
console.log(result.duration); // outputs: 5400 (duration in seconds)
console.log(result.textWithoutDuration); // outputs: 'Do laundry, clean room' 
""");*/
      } on PlatformException catch (e) {
        print('Failed to init js engine: ${e.details}');
      } catch (e) {
        print(e);
      }
    }

    if (!mounted) return;
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
                  )
                ],
              ),
            ),
    );
  }
}
