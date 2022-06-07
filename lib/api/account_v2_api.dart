import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/account/account_v2.dart';

class AccountV2Api extends ApiClient {
  AccountV2Api()
      : super(
          Uri.parse("${Config.endpoint}/v2/accounts"),
          fromMap: AccountV2.fromMap,
        );
}
