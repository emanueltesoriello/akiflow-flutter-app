part of 'sync_cubit.dart';

class SyncCubitState extends Equatable {
  final bool loading;
  final bool error;

  const SyncCubitState({
    this.loading = false,
    this.error = false,
  });

  SyncCubitState copyWith({
    bool? loading,
    bool? error,
  }) {
    return SyncCubitState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loading, error];
}
