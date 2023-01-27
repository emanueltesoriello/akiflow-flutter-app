part of 'sync_cubit.dart';

class SyncCubitState extends Equatable {
  final bool loading;
  final bool error;
  final bool networkError;

  const SyncCubitState({
    this.loading = false,
    this.error = false,
    this.networkError = false,
  });

  SyncCubitState copyWith({
    bool? loading,
    bool? error,
    bool? networkError,
  }) {
    return SyncCubitState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      networkError: networkError ?? this.networkError,
    );
  }

  @override
  List<Object?> get props => [loading, error, networkError];
}
