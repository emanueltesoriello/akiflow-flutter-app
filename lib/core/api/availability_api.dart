import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/task/availability_config.dart';

class AvailabilityApi extends ApiClient {
  AvailabilityApi()
      : super(
          Uri.parse("${Config.endpoint}/v3/availability-configs"),
          fromMap: AvailabilityConfig.fromMap,
        );
}
