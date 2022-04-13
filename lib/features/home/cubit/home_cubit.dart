import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/api/account_api.dart';
import 'package:mobile/api/calendar_api.dart';
import 'package:mobile/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/repository/calendars_repository.dart';
import 'package:mobile/repository/tasks_repository.dart';
import 'package:mobile/services/sync_service.dart';
import 'package:models/account/account.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {
  final TasksCubit _tasksCubit;
  final AccountApi _accountApi = locator<AccountApi>();
  final TaskApi _taskApi = locator<TaskApi>();
  final CalendarApi _calendarApi = locator<CalendarApi>();
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();
  final CalendarsRepository _calendarsRepository =
      locator<CalendarsRepository>();

  HomeCubit(this._tasksCubit) : super(const HomeCubitState()) {
    _init();
  }

  _init() {
    _syncTasks();
  }

  Future<void> _syncTasks() async {
    List<Account> accountsData = await _accountApi.get();

    // Akiflow account used to sync tasks and save local details last_updated_at (last sync)
    Account akiflowAccount =
        accountsData.firstWhere((account) => account.connectorId == 'akiflow');

    SyncService accounts = SyncService(
      akiflowAccount: akiflowAccount,
      api: _accountApi,
      databaseRepository: _accountsRepository,
    );

    SyncService tasks = SyncService(
      akiflowAccount: akiflowAccount,
      api: _taskApi,
      databaseRepository: _tasksRepository,
    );

    SyncService calendars = SyncService(
      akiflowAccount: akiflowAccount,
      api: _calendarApi,
      databaseRepository: _calendarsRepository,
    );

    await accounts.start();
    await tasks.start();
    await calendars.start();

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
