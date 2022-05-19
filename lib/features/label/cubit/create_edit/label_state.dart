part of 'label_cubit.dart';

class LabelCubitState extends Equatable {
  final bool loading;
  final Label? selectedLabel;
  final TaskListSorting sorting;
  final bool showDone;
  final List<Label> sections;
  final Map<String?, bool> openedSections;

  const LabelCubitState({
    this.loading = false,
    this.selectedLabel,
    this.sorting = TaskListSorting.descending,
    this.showDone = false,
    this.sections = const [],
    this.openedSections = const {},
  });

  LabelCubitState copyWith({
    bool? loading,
    Label? selectedLabel,
    TaskListSorting? sorting,
    bool? showDone,
    List<Label>? sections,
    Map<String?, bool>? openedSections,
  }) {
    return LabelCubitState(
      loading: loading ?? this.loading,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      sorting: sorting ?? this.sorting,
      showDone: showDone ?? this.showDone,
      sections: sections ?? this.sections,
      openedSections: openedSections ?? this.openedSections,
    );
  }

  @override
  List<Object?> get props => [loading, selectedLabel, sorting, showDone, sections, openedSections];
}
