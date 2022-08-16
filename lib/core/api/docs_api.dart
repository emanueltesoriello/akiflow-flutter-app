import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/doc/doc.dart';

class DocsApi extends ApiClient {
  DocsApi()
      : super(
          Uri.parse("${Config.endpoint}/v2/docs"),
          fromMap: Doc.fromMap,
        );
}
