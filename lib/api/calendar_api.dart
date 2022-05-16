import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/calendar/calendar.dart';

class CalendarApi extends ApiClient {
  CalendarApi()
      : super(
          Uri.parse("${Config.endpoint}/v3/calendars"),
          fromMap: Calendar.fromMap,
        );
}
