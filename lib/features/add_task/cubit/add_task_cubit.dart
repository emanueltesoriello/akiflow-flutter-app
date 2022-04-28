import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';

part 'add_task_state.dart';

class AddTaskCubit extends Cubit<AddTaskCubitState> {
  final TasksCubit _tasksCubit;

  AddTaskCubit(this._tasksCubit) : super(const AddTaskCubitState()) {
    _init();
  }

  _init() async {}

  void selectPlanType(AddTaskPlanType type) {
    emit(state.copyWith(planType: type));
  }
}
