import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/event/event_modifier.dart';

class EventModifiersApi extends ApiClient {
  EventModifiersApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v3/events/modifiers"),
          fromMap: EventModifier.fromMap,
        );
}
