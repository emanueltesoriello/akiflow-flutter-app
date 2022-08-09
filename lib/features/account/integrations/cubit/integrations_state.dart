part of 'integrations_cubit.dart';

class IntegrationsCubitState extends Equatable {
  final bool loading;
  final List<Account> accounts;
  final bool isAuthenticatingOAuth;
  final bool connected;
  final bool reconnectPageVisible;

  const IntegrationsCubitState({
    this.loading = false,
    this.accounts = const [],
    this.isAuthenticatingOAuth = false,
    this.connected = false,
    this.reconnectPageVisible = false,
  });

  IntegrationsCubitState copyWith({
    bool? loading,
    List<Account>? accounts,
    bool? isAuthenticatingOAuth,
    bool? connected,
    bool? reconnectPageVisible,
  }) {
    return IntegrationsCubitState(
      loading: loading ?? this.loading,
      accounts: accounts ?? this.accounts,
      isAuthenticatingOAuth: isAuthenticatingOAuth ?? this.isAuthenticatingOAuth,
      connected: connected ?? this.connected,
      reconnectPageVisible: reconnectPageVisible ?? this.reconnectPageVisible,
    );
  }

  @override
  List<Object?> get props => [loading, accounts, isAuthenticatingOAuth, connected, reconnectPageVisible];
}
