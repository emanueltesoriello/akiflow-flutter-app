part of 'settings_cubit.dart';

class SettingsCubitState extends Equatable {
  final bool loading;
  final String? appVersion;

  const SettingsCubitState({
    this.loading = false,
    this.appVersion,
  });

  SettingsCubitState copyWith({
    bool? loading,
    String? appVersion,
  }) {
    return SettingsCubitState(
      loading: loading ?? this.loading,
      appVersion: appVersion ?? this.appVersion,
    );
  }

  @override
  List<Object?> get props => [loading, appVersion];
}
