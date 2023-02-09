part of 'labels_cubit.dart';

class LabelsCubitState extends Equatable {
  final bool loading;
  final List<Label> labels;
  final Label? selectedLabel;
  final TaskListSorting sorting;
  final bool showDone;
  final List<Label> sections;
  final Map<String?, bool> openedSections;
  final bool showSnoozed;
  final bool showSomeday;

  const LabelsCubitState({
    this.loading = false,
    this.labels = const [],
    this.selectedLabel,
    this.sorting = TaskListSorting.sortingDescending,
    this.showDone = false,
    this.sections = const [],
    this.openedSections = const {},
    this.showSnoozed = false,
    this.showSomeday = false,
  });

  LabelsCubitState copyWith({
    bool? loading,
    List<Label>? labels,
    Label? selectedLabel,
    TaskListSorting? sorting,
    bool? showDone,
    List<Label>? sections,
    Map<String?, bool>? openedSections,
    bool? showSnoozed,
    bool? showSomeday,
  }) {
    return LabelsCubitState(
      loading: loading ?? this.loading,
      labels: labels ?? this.labels,
      selectedLabel: selectedLabel ?? this.selectedLabel,
      sorting: sorting ?? this.sorting,
      showDone: showDone ?? this.showDone,
      sections: sections ?? this.sections,
      openedSections: openedSections ?? this.openedSections,
      showSnoozed: showSnoozed ?? this.showSnoozed,
      showSomeday: showSomeday ?? this.showSomeday,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        labels,
        selectedLabel,
        sorting,
        showDone,
        sections,
        openedSections,
        showSnoozed,
        showSomeday,
      ];
}
