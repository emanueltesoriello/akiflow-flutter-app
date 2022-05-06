part of 'plan_modal_cubit.dart';

class PlanModalCubitState extends Equatable {
  final bool loading;
  final TaskStatusType statusType;
  final DateTime? selectedDate;

  const PlanModalCubitState({
    this.loading = false,
    this.statusType = TaskStatusType.planned,
    this.selectedDate,
  });

  PlanModalCubitState copyWith({
    bool? loading,
    TaskStatusType? statusType,
    DateTime? selectedDate,
  }) {
    return PlanModalCubitState(
      loading: loading ?? this.loading,
      statusType: statusType ?? this.statusType,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        statusType,
        selectedDate,
      ];
}
