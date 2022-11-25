import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/main_com.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Config.initialize(
    configFile: 'assets/config/dev.json',
    production: false,
  );

  await mainCom(kDebugMode: true);
}
