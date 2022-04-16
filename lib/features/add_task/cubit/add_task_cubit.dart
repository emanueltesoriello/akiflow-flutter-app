import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'add_task_state.dart';

class AddTaskCubit extends Cubit<AddTaskCubitState> {
  AddTaskCubit() : super(const AddTaskCubitState()) {
    _init();
  }

  _init() async {}
}
