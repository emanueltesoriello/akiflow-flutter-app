import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/event/event.dart';

class EventApi extends Api {
  EventApi()
      : super(
          Uri.parse(Config.endpoint + "/v3/events"),
          fromMap: Event.fromMap,
        );
}
