part of 'view_cubit.dart';

class InboxCubitState extends Equatable {
  final bool loading;

  const InboxCubitState({
    this.loading = false,
  });

  InboxCubitState copyWith({
    bool? loading,
  }) {
    return InboxCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
