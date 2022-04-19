part of 'today_cubit.dart';

class TodayCubitState extends Equatable {
  final bool loading;

  const TodayCubitState({
    this.loading = false,
  });

  TodayCubitState copyWith({
    bool? loading,
  }) {
    return TodayCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
