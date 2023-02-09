import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/calendar/calendar.dart';

class CalendarApi extends ApiClient {
  CalendarApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v3/calendars"),
          fromMap: Calendar.fromMap,
        );
}
