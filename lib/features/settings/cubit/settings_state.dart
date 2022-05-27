part of 'settings_cubit.dart';

class SettingsCubitState extends Equatable {
  final bool loading;
  final String? appVersion;
  final Map<Label, bool> folderOpen;
  final List<Account> accounts;
  final bool isAuthenticatingOAuth;

  const SettingsCubitState({
    this.loading = false,
    this.appVersion,
    this.folderOpen = const {},
    this.accounts = const [],
    this.isAuthenticatingOAuth = false,
  });

  SettingsCubitState copyWith({
    bool? loading,
    String? appVersion,
    Map<Label, bool>? folderOpen,
    List<Account>? accounts,
    bool? isAuthenticatingOAuth,
  }) {
    return SettingsCubitState(
      loading: loading ?? this.loading,
      appVersion: appVersion ?? this.appVersion,
      folderOpen: folderOpen ?? this.folderOpen,
      accounts: accounts ?? this.accounts,
      isAuthenticatingOAuth: isAuthenticatingOAuth ?? this.isAuthenticatingOAuth,
    );
  }

  @override
  List<Object?> get props => [loading, appVersion, folderOpen, accounts, isAuthenticatingOAuth];
}
