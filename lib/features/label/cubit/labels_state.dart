part of 'labels_cubit.dart';

class LabelsCubitState extends Equatable {
  final bool loading;
  final List<Label> labels;

  const LabelsCubitState({
    this.loading = false,
    this.labels = const [],
  });

  LabelsCubitState copyWith({
    bool? loading,
    List<Label>? labels,
  }) {
    return LabelsCubitState(
      loading: loading ?? this.loading,
      labels: labels ?? this.labels,
    );
  }

  @override
  List<Object?> get props => [loading, labels];
}
