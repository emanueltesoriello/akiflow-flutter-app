part of 'settings_cubit.dart';

class SettingsCubitState extends Equatable {
  final bool loading;
  final String? appVersion;
  final Map<Label, bool> folderOpen;
  final List<Account> accounts;
  final bool isAuthenticatingOAuth;
  final bool connected;

  const SettingsCubitState({
    this.loading = false,
    this.appVersion,
    this.folderOpen = const {},
    this.accounts = const [],
    this.isAuthenticatingOAuth = false,
    this.connected = false,
  });

  SettingsCubitState copyWith({
    bool? loading,
    String? appVersion,
    Map<Label, bool>? folderOpen,
    List<Account>? accounts,
    bool? isAuthenticatingOAuth,
    bool? connected,
  }) {
    return SettingsCubitState(
      loading: loading ?? this.loading,
      appVersion: appVersion ?? this.appVersion,
      folderOpen: folderOpen ?? this.folderOpen,
      accounts: accounts ?? this.accounts,
      isAuthenticatingOAuth: isAuthenticatingOAuth ?? this.isAuthenticatingOAuth,
      connected: connected ?? this.connected,
    );
  }

  @override
  List<Object?> get props => [loading, appVersion, folderOpen, accounts, isAuthenticatingOAuth, connected];
}
