import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/event/event.dart';

class EventApi extends ApiClient {
  EventApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v3/events"),
          fromMap: Event.fromMap,
        );
}
