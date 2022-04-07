import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/tasks.dart';
import 'package:models/task/task.dart';
import 'package:models/user.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {
  final PreferencesRepository _preferencesRepository =
      locator<PreferencesRepository>();
  final TasksRepository _tasksRepository = locator<TasksRepository>();

  HomeCubit() : super(const HomeCubitState()) {
    _init();
  }

  _init() async {
    User? user = _preferencesRepository.user;

    if (user != null) {
      List<Task> all = await _tasksRepository.all();

      for (var task in all) {
        print(task.title);
      }
    }
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
}
