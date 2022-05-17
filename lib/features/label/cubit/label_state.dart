part of 'label_cubit.dart';

class LabelCubitState extends Equatable {
  final bool loading;
  final Label? selectedLabel;

  const LabelCubitState({
    this.loading = false,
    this.selectedLabel,
  });

  LabelCubitState copyWith({
    bool? loading,
    Label? selectedLabel,
  }) {
    return LabelCubitState(
      loading: loading ?? this.loading,
      selectedLabel: selectedLabel ?? this.selectedLabel,
    );
  }

  @override
  List<Object?> get props => [loading, selectedLabel];
}
