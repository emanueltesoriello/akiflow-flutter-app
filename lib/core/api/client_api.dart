import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/client/client.dart';

class ClientApi extends ApiClient {
  ClientApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v3/clients"),
          fromMap: Client.fromMap,
        );
}
