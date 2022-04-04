import 'package:flutter/widgets.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/main_com.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// Initialize the [Config] class based on the parameter received as file path
  await Config.initialize(true, 'assets/config/dev.json');

  await mainCom();
}
