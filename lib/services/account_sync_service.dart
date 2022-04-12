import 'dart:async';

import 'package:mobile/api/account_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:models/account/account.dart';

class AccountSyncService {
  final AccountApi _accountApi = locator<AccountApi>();
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();

  final Account account;

  AccountSyncService({required this.account});

  Future<void> start() async {
    await _remoteToLocal();
    await _localToRemote();
  }

  Future<void> _remoteToLocal() async {
    DateTime? lastSyncAt = await getRemoteUpdatedAt();

    List<Account> remoteItems = await _accountApi.all(
      updatedAfter: lastSyncAt,
      allPages: true,
    );

    if (remoteItems.isEmpty) {
      print('No remote accounts to sync');
      return;
    }

    List<Account> localItems = await _accountsRepository.all();

    for (Account remoteItem in remoteItems) {
      bool hasAlreadyInLocalDatabase =
          localItems.any((element) => element.id == remoteItem.id);

      if (hasAlreadyInLocalDatabase) {
        Account localAccount =
            localItems.firstWhere((element) => element.id == remoteItem.id);

        DateTime? remoteGlobalUpdateAt = remoteItem.globalUpdatedAt;
        DateTime? localUpdatedAt = localAccount.updatedAt;

        bool notYetUpdated =
            localUpdatedAt == null || remoteGlobalUpdateAt == null;

        bool remoteItemIsRecentThanLocal =
            notYetUpdated || remoteGlobalUpdateAt.isAfter(localUpdatedAt);

        if (remoteItemIsRecentThanLocal) {
          remoteItem = remoteItem.rebuild((t) {
            t.updatedAt = remoteGlobalUpdateAt;
            t.remoteUpdatedAt = remoteGlobalUpdateAt;
          });

          await _updateLocalAccount(
              id: localAccount.id!, remoteItem: remoteItem);
        }
      } else {
        await _addRemoteAccountToLocalDb(remoteItem);
      }
    }

    if (remoteItems.any((element) => element.updatedAt != null)) {
      Account maxRemoteAccountsUpdatedAt = remoteItems.reduce((t1, t2) {
        if (t1.updatedAt == null) return t2;
        if (t2.updatedAt == null) return t1;
        return t1.updatedAt!.isAfter(t2.updatedAt!) ? t1 : t2;
      });

      await updateLocalLastSyncAt(maxRemoteAccountsUpdatedAt.updatedAt);
    }
  }

  Future<void> _localToRemote() async {
    List<Account> unsynced = await _accountsRepository.unsynced();

    if (unsynced.isEmpty) {
      print('No local accounts to sync');
      return;
    }

    for (Account item in unsynced) {
      DateTime? updatedAt = item.updatedAt;
      DateTime? deletedAt = item.deletedAt;

      DateTime? maxDate;

      if (updatedAt != null && deletedAt != null) {
        maxDate = updatedAt.isAfter(deletedAt) ? updatedAt : deletedAt;
      } else if (updatedAt != null) {
        maxDate = updatedAt;
      } else if (deletedAt != null) {
        maxDate = deletedAt;
      }

      item = item.rebuild((t) {
        t.updatedAt = maxDate;
        t.remoteUpdatedAt = maxDate;
      });
    }

    try {
      List<Account> updated = await _accountApi.post(unsynced);

      print("updated: ${updated.length}");
    } on ApiException catch (e) {
      print(e);
    }
  }

  Future<DateTime?> getRemoteUpdatedAt() async {
    Account localAccount = await _accountsRepository.byId(account.id!);
    return localAccount.localDetails?.lastAccountsSyncAt;
  }

  Future<void> updateLocalLastSyncAt(DateTime? date) async {
    Account localAccount = await _accountsRepository.byId(account.id!);

    localAccount = localAccount.rebuild((t) {
      t.localDetails.lastAccountsSyncAt = date;
    });

    await _accountsRepository.updateById(
      localAccount.id.toString(),
      data: localAccount,
    );
  }

  Future<void> _updateLocalAccount(
      {required String id, required Account remoteItem}) async {
    print("update local account: ${remoteItem.accountId}");
    await _accountsRepository.updateById(id, data: remoteItem);
  }

  Future<void> _addRemoteAccountToLocalDb(Account remoteItem) async {
    print("does not exist locally, add it");
    await _accountsRepository.add([remoteItem]);
  }
}
