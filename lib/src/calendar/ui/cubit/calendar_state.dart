part of 'calendar_cubit.dart';

class CalendarCubitState extends Equatable {
  final CalendarNavigationState navigationState;

  const CalendarCubitState({
    this.navigationState = CalendarNavigationState.loading,
  });

  CalendarCubitState copyWith({
    CalendarNavigationState? navigationState,
  }) {
    return CalendarCubitState(
      navigationState: navigationState ?? this.navigationState,
    );
  }

  @override
  List<Object?> get props => [navigationState];
}
