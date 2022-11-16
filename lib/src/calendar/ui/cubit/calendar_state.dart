part of 'calendar_cubit.dart';

class CalendarCubitState extends Equatable {
  final bool loading;

  const CalendarCubitState({
    this.loading = false,
  });

  CalendarCubitState copyWith({
    bool? loading,
  }) {
    return CalendarCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
