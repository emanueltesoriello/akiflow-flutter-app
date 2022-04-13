import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/calendar/calendar.dart';

class CalendarApi extends Api {
  CalendarApi()
      : super(
          Uri.parse(Config.endpoint + "/v3/calendars"),
          fromMap: Calendar.fromMap,
        );

  @override
  Future<List<Calendar>> get<Calendar>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = false,
  }) async {
    return await super.get<Calendar>(
      perPage: perPage,
      withDeleted: withDeleted,
      updatedAfter: updatedAfter,
      allPages: allPages,
    );
  }

  @override
  Future<List<Calendar>> post<Calendar>(
      {required List<Calendar> unsynced}) async {
    return (await super.post(
      unsynced: unsynced,
    ));
  }
}
