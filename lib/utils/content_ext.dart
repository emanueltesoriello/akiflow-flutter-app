import 'package:intl/intl.dart';
import 'package:models/content.dart';

extension ContentExt on Content {
  String? get internalDateFormatted {
    if (internalDate == null) {
      return null;
    }

    int millis = int.parse(internalDate!);

    DateTime date = DateTime.fromMillisecondsSinceEpoch(millis).toLocal();

    return DateFormat("dd MMM yyyy").format(date);
  }
}
