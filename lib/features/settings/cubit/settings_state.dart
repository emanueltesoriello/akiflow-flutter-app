part of 'settings_cubit.dart';

class SettingsCubitState extends Equatable {
  final bool loading;
  final String? appVersion;
  final Map<Label, bool> folderOpen;

  const SettingsCubitState({
    this.loading = false,
    this.appVersion,
    this.folderOpen = const {},
  });

  SettingsCubitState copyWith({
    bool? loading,
    String? appVersion,
    Map<Label, bool>? folderOpen,
  }) {
    return SettingsCubitState(
      loading: loading ?? this.loading,
      appVersion: appVersion ?? this.appVersion,
      folderOpen: folderOpen ?? this.folderOpen,
    );
  }

  @override
  List<Object?> get props => [loading, appVersion, folderOpen];
}
