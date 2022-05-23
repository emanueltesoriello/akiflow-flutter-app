part of 'sync_cubit.dart';

class SyncCubitState extends Equatable {
  final bool loading;

  const SyncCubitState({
    this.loading = false,
  });

  SyncCubitState copyWith({
    bool? loading,
  }) {
    return SyncCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
