import 'package:html/parser.dart';

extension StringExt on String {
  String capitalizeFirstCharacter() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String? get parseHtmlString {
    final document = parse(this);
    final String? parsedString = parse(document.body?.text).documentElement?.text;

    return (parsedString?.isNotEmpty??false) ? parsedString : null;
  }
}
