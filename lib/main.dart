import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/main_com.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  await Config.initialize(
    configFile: 'assets/config/prod.json',
    production: true,
  );

  await mainCom();
}
