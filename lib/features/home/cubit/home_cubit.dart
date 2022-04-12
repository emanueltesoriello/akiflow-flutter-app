import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/api/account_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/services/account_sync_service.dart';
import 'package:mobile/services/task_sync_service.dart';
import 'package:models/account/account.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {
  final TasksCubit _tasksCubit;
  final AccountApi _accountApi = locator<AccountApi>();

  HomeCubit(this._tasksCubit) : super(const HomeCubitState()) {
    _init();
  }

  _init() {
    _syncTasks();
  }

  Future<void> _syncTasks() async {
    List<Account> accounts = await _accountApi.all();

    for (Account account in accounts) {
      AccountSyncService accountSyncService =
          AccountSyncService(account: account);
      await accountSyncService.start();
    }

    Account akiflowAccount =
        accounts.firstWhere((account) => account.connectorId == 'akiflow');

    TaskSyncService _syncService = TaskSyncService(account: akiflowAccount);
    await _syncService.start();

    _tasksCubit.refresh();
  }

  void bottomBarViewClick(int index) {
    switch (index) {
      case 1:
        emit(state.copyWith(homeViewType: HomeViewType.inbox));
        break;
      case 2:
        emit(state.copyWith(homeViewType: HomeViewType.today));
        break;
      case 3:
        emit(state.copyWith(homeViewType: HomeViewType.calendar));
        break;
    }
  }

  addTask() async {
    _syncTasks();
  }
}
