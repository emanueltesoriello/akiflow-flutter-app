import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/account/account.dart';

class AccountApi extends Api {
  AccountApi()
      : super(
          Uri.parse(Config.endpoint + "/v3/accounts"),
          fromMap: Account.fromMap,
        );

  @override
  Future<List<Account>> get<Account>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = false,
  }) async {
    return (await super.get<Account>(
      perPage: perPage,
      withDeleted: withDeleted,
      updatedAfter: updatedAfter,
      allPages: allPages,
    ));
  }

  @override
  Future<List<Account>> post<Account>({required List<Account> unsynced}) async {
    return (await super.post(
      unsynced: unsynced,
    ));
  }
}
