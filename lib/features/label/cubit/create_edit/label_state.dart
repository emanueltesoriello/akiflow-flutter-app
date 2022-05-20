part of 'label_cubit.dart';

class LabelCubitState extends Equatable {
  final bool loading;
  final Label? selectedLabel;
  final TaskListSorting sorting;
  final bool showDone;
  final List<Label> sections;
  final Map<String?, bool> openedSections;
  final bool showSnoozed;
  final bool showSomeday;

  const LabelCubitState({
    this.loading = false,
    this.selectedLabel,
    this.sorting = TaskListSorting.descending,
    this.showDone = false,
    this.sections = const [],
    this.openedSections = const {},
    this.showSnoozed = false,
    this.showSomeday = false,
  });

  LabelCubitState copyWith({
    bool? loading,
    Label? selectedLabel,
    TaskListSorting? sorting,
    bool? showDone,
    List<Label>? sections,
    Map<String?, bool>? openedSections,
    bool? showSnoozed,
    bool? showSomeday,
  }) {
    return LabelCubitState(
      loading: loading ?? this.loading,
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
        selectedLabel,
        sorting,
        showDone,
        sections,
        openedSections,
        showSnoozed,
        showSomeday,
      ];
}