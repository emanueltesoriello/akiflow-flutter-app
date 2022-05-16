import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/account/account.dart';

class AccountApi extends ApiClient {
  AccountApi()
      : super(
          Uri.parse("${Config.endpoint}/v3/accounts"),
          fromMap: Account.fromMap,
        );
}
