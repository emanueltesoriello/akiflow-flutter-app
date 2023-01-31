import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/label/label.dart';

class LabelApi extends ApiClient {
  LabelApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v3/labels"),
          fromMap: Label.fromMap,
        );
}
