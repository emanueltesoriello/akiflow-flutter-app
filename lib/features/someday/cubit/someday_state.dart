part of 'someday_cubit.dart';

class SomedayCubitState extends Equatable {
  final bool loading;
  final List<Task> tasks;

  const SomedayCubitState({
    this.loading = false,
    this.tasks = const [],
  });

  SomedayCubitState copyWith({
    bool? loading,
    List<Task>? tasks,
  }) {
    return SomedayCubitState(
      loading: loading ?? this.loading,
      tasks: tasks ?? this.tasks,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        tasks,
      ];
}
