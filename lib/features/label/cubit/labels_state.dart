part of 'labels_cubit.dart';

class LabelsCubitState extends Equatable {
  final bool loading;
  final List<Label> labels;
  final List<Task> labelTasks;

  const LabelsCubitState({
    this.loading = false,
    this.labels = const [],
    this.labelTasks = const [],
  });

  LabelsCubitState copyWith({
    bool? loading,
    List<Label>? labels,
    List<Task>? labelTasks,
  }) {
    return LabelsCubitState(
      loading: loading ?? this.loading,
      labels: labels ?? this.labels,
      labelTasks: labelTasks ?? this.labelTasks,
    );
  }

  @override
  List<Object?> get props => [loading, labels, labelTasks];
}
