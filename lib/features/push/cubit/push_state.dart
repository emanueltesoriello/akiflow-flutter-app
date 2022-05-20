part of 'push_cubit.dart';

class PushCubitState extends Equatable {
  final bool loading;

  const PushCubitState({
    this.loading = false,
  });

  PushCubitState copyWith({
    bool? loading,
  }) {
    return PushCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
