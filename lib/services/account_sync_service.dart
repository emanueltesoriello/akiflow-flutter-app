import 'dart:async';

import 'package:mobile/api/account_api.dart';
import 'package:mobile/core/locator.dart';
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
    // TODO read all paginated response
    List<Account> remoteItems = await _accountApi.all();

    if (remoteItems.isEmpty) return;

    List<Account> localItems = await _accountsRepository.all();

    for (Account remoteItem in remoteItems) {
      // check if remote account is already in local database
      if (localItems.any((element) => element.id == remoteItem.id)) {
        Account localAccount =
            localItems.firstWhere((element) => element.id == remoteItem.id);

        DateTime? remoteGlobalUpdateAt = remoteItem.globalUpdatedAt;
        DateTime? localGlobalUpdatedAt = localAccount.globalUpdatedAt;

        bool remoteItemIsRecentThanLocal = remoteGlobalUpdateAt != null &&
            localGlobalUpdatedAt != null &&
            remoteGlobalUpdateAt.isAfter(localGlobalUpdatedAt);

        if (remoteItemIsRecentThanLocal) {
          remoteItem = remoteItem.rebuild((t) {
            t.createdAt = remoteItem.globalCreatedAt;
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

    Account? maxRemoteAccountsUpdatedAt = remoteItems
        .reduce((t1, t2) => t1.updatedAt!.isAfter(t2.updatedAt!) ? t1 : t2);

    await updateLocalLastSyncAt(maxRemoteAccountsUpdatedAt.updatedAt);

    // TODO update lastSyncAt in db of account table

    // TODO update globalUpdatedAt remote account
  }

  Future<void> _localToRemote() async {
    List<Account> unsynced = await _accountsRepository.unsynced();

    if (unsynced.isNotEmpty) {
      print("sync local accounts: ${unsynced.length}");

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
          t.globalUpdatedAt = maxDate;
          t.globalCreatedAt = t.createdAt;
        });
      }

      List<Account> updated = await _accountApi.post(unsynced);

      print("updated: ${updated.length}");
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
    print("update local account");
    await _accountsRepository.updateById(id, data: remoteItem);
  }

  Future<void> _addRemoteAccountToLocalDb(Account remoteItem) async {
    print("does not exist locally, add it");
    await _accountsRepository.add([remoteItem]);
  }
}
