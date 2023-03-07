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
    var ajvIsLoaded = jsRuntime.evaluate("""var chronoIsLoaded = (typeof ajv == 'undefined') ? 
          "0" : "1"; chronoIsLoaded;
        """).stringResult;
    print("Chrono is Loaded $ajvIsLoaded");
    if (ajvIsLoaded == "0") {
      try {
        String chrono = await rootBundle.loadString("assets/js/chrono-custom-rules-master/dist/index.js");

        jsRuntime.evaluate("""var window = global = globalThis;""");

        jsRuntime.evaluate(chrono + "");
      } on PlatformException catch (e) {
        print('Failed to init js engine: ${e.details}');
      }
    }

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
