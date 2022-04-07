part of 'view_cubit.dart';

class SettingsCubitState extends Equatable {
  final bool loading;

  const SettingsCubitState({
    this.loading = false,
  });

  SettingsCubitState copyWith({
    bool? loading,
  }) {
    return SettingsCubitState(
      loading: loading ?? this.loading,
    );
  }

  @override
  List<Object?> get props => [loading];
}
