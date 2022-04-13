part of 'view_cubit.dart';

class InboxCubitState extends Equatable {
  final bool loading;
  final bool showInboxNotice;

  const InboxCubitState({
    this.loading = false,
    this.showInboxNotice = false,
  });

  InboxCubitState copyWith({
    bool? loading,
    bool? showInboxNotice,
  }) {
    return InboxCubitState(
      loading: loading ?? this.loading,
      showInboxNotice: showInboxNotice ?? this.showInboxNotice,
    );
  }

  @override
  List<Object?> get props => [loading, showInboxNotice];
}
