import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/utils/task_extension.dart';

part 'plan_modal_state.dart';

class PlanModalCubit extends Cubit<PlanModalCubitState> {
  PlanModalCubit(TaskStatusType statusType)
      : super(PlanModalCubitState(statusType: statusType));

  void selectPlanType(TaskStatusType type) {
    emit(state.copyWith(statusType: type));
  }

  void selectDate(DateTime? date) {
    emit(state.copyWith(selectedDate: date));
  }
}
