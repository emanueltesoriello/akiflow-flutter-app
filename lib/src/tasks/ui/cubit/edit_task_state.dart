part of 'edit_task_cubit.dart';

enum EditTaskPlanType { plan, snooze }

class EditTaskCubitState extends Equatable {
  final bool loading;
  final Task originalTask;
  final Task updatedTask;
  final DateTime? selectedDate;
  final double? selectedDuration;
  final bool showDuration;
  final bool showPriority;
  final bool openedDurationfromNLP;
  final bool openedPrirorityfromNLP;
  final bool openedLabelfromNLP;
  final bool showLabelsList;
  final bool hasFocusOnTitleOrDescription;

  const EditTaskCubitState({
    this.loading = false,
    this.originalTask = const Task(),
    this.updatedTask = const Task(),
    this.selectedDate,
    this.selectedDuration,
    this.showDuration = false,
    this.showLabelsList = false,
    this.openedDurationfromNLP = false,
    this.openedPrirorityfromNLP = false,
    this.openedLabelfromNLP = false,
    this.showPriority = false,
    this.hasFocusOnTitleOrDescription = false,
  });

  EditTaskCubitState copyWith(
      {bool? loading,
      Task? originalTask,
      Task? updatedTask,
      DateTime? selectedDate,
      double? selectedDuration,
      bool? showDuration,
      bool? openedDurationfromNLP,
      bool? openedPrirorityfromNLP,
      bool? openedLabelfromNLP,
      bool? showLabelsList,
      bool? showPriority,
      bool? hasFocusOnTitleOrDescription}) {
    return EditTaskCubitState(
        loading: loading ?? this.loading,
        originalTask: originalTask ?? this.originalTask,
        updatedTask: updatedTask ?? this.updatedTask,
        selectedDate: selectedDate ?? this.selectedDate,
        selectedDuration: selectedDuration ?? this.selectedDuration,
        showDuration: showDuration ?? this.showDuration,
        openedDurationfromNLP: openedDurationfromNLP ?? this.openedDurationfromNLP,
        openedPrirorityfromNLP: openedPrirorityfromNLP ?? this.openedPrirorityfromNLP,
        openedLabelfromNLP: openedLabelfromNLP ?? this.openedLabelfromNLP,
        showLabelsList: showLabelsList ?? this.showLabelsList,
        showPriority: showPriority ?? this.showPriority,
        hasFocusOnTitleOrDescription: hasFocusOnTitleOrDescription ?? this.hasFocusOnTitleOrDescription);
  }

  @override
  List<Object?> get props => [
        loading,
        originalTask,
        updatedTask,
        selectedDate,
        selectedDuration,
        openedDurationfromNLP,
        openedPrirorityfromNLP,
        openedLabelfromNLP,
        showDuration,
        showLabelsList,
        showPriority,
        hasFocusOnTitleOrDescription
      ];
}
