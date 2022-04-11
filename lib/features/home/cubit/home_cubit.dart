import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/services/sync_service.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {
  final SyncService _syncService = locator<SyncService>();
  final TasksCubit _tasksCubit;

  HomeCubit(this._tasksCubit) : super(const HomeCubitState());

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
    await _syncService.start();

    _tasksCubit.refresh();
  }
}
