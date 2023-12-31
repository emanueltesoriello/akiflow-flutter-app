import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/labels_repository.dart';
import 'package:mobile/core/services/analytics_service.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list.dart';
import 'package:mobile/src/label/ui/widgets/create_edit_label_modal.dart';
import 'package:mobile/src/label/ui/widgets/create_edit_section_modal.dart';
import 'package:mobile/src/label/ui/widgets/delete_label_dialog.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:models/user.dart';
import 'package:uuid/uuid.dart';

part 'labels_state.dart';

enum LabelType { folder, label, section }

class LabelsCubit extends Cubit<LabelsCubitState> {
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final TasksCubit _tasksCubit = locator<TasksCubit>();

  final SyncCubit _syncCubit;

  LabelsCubit(this._syncCubit) : super(const LabelsCubitState()) {
    fetchLabels();

    _init();
  }

  _init() async {
    _syncCubit.syncCompletedStream.listen((_) async {
      await fetchLabels();
    });
  }

  Future<void> addLabel(Label newLabel, {required LabelType labelType}) async {
    User user = _preferencesRepository.user!;

    newLabel = newLabel.copyWith(userId: user.id, sorting: DateTime.now().toUtc().millisecondsSinceEpoch);

    List<Label> labels = List.from(state.labels);
    labels.add(newLabel);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.add([newLabel]);

    _syncCubit.sync(entities: [Entity.labels]);

    switch (labelType) {
      case LabelType.folder:
        AnalyticsService.track("New Label Folder");
        break;
      case LabelType.label:
        AnalyticsService.track("New Label");
        break;
      case LabelType.section:
        AnalyticsService.track("New Section");
        break;
    }
  }

  Future<void> updateLabel(Label label) async {
    List<Label> labels = List.from(state.labels);

    int index = labels.indexWhere((l) => l.id == label.id);

    labels[index] = label;

    emit(state.copyWith(labels: labels));

    await _labelsRepository.updateById(label.id, data: label);

    _syncCubit.sync(entities: [Entity.labels]);
  }

  Future<void> addSectionToDatabase(Label newSection) async {
    User user = _preferencesRepository.user!;

    newSection = newSection.copyWith(userId: user.id);

    List<Label> labels = List.from(state.labels);
    labels.add(newSection);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.add([newSection]);

    await _syncCubit.sync(entities: [Entity.labels]);

    await _init();
  }

  Future<void> fetchLabels() async {
    List<Label> labels = await _labelsRepository.getLabels();
    emit(state.copyWith(labels: labels));
  }

  removeLabel() async {
    emit(state.copyWith(selectedLabel: null));
    _tasksCubit.attachLabelCubit(this);
  }

  selectLabel(Label label) async {
    emit(state.copyWith(selectedLabel: label));

    _tasksCubit.attachLabelCubit(this);
    _tasksCubit.fetchLabelTasks(state.selectedLabel!);

    List<Label> allLabels = await _labelsRepository.get();
    List<Label> sections = allLabels.where((label) => label.isSection && label.deletedAt == null).toList();
    List<Label> labelSections = [];

    Label noSection = const Label(title: "No Section", type: "section");
    labelSections.add(noSection);
    labelSections.addAll(sections.where((label) => label.parentId == state.selectedLabel!.id).toList());

    emit(state.copyWith(sections: labelSections));

    Map<String?, bool> openedSections = {};
    for (Label label in labelSections) {
      openedSections[label.id] = true;
    }
    emit(state.copyWith(openedSections: openedSections));
  }

  void saveLabel(Label updated) {
    updated = updated.copyWith(updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())));
    updateLabel(updated);
    emit(state.copyWith(selectedLabel: updated));
  }

  void toggleSorting() {
    TaskListSorting sorting = state.sorting;

    if (sorting == TaskListSorting.sortingAscending) {
      emit(state.copyWith(sorting: TaskListSorting.sortingDescending));
    } else {
      emit(state.copyWith(sorting: TaskListSorting.sortingAscending));
    }
  }

  void toggleShowDone() {
    emit(state.copyWith(showDone: !state.showDone));
  }

  Future<void> delete({bool markTasksAsDone = false}) async {
    Label labelUpdated = state.selectedLabel!.copyWith(deletedAt: TzUtils.toUtcStringIfNotNull(DateTime.now()));
    emit(state.copyWith(selectedLabel: labelUpdated));

    if (markTasksAsDone) {
      await _tasksCubit.markLabelTasksAsDone();
    }
  }

  void toggleOpenSection(String? sectionId) {
    Map<String?, bool> openedSections = Map.from(state.openedSections);
    openedSections[sectionId] = !(openedSections[sectionId] ?? true);
    emit(state.copyWith(openedSections: openedSections));
  }

  void addSectionToLocalUi(Label newSectionUpdated) {
    List<Label> sections = List.from(state.sections);
    sections.add(newSectionUpdated);

    emit(state.copyWith(sections: sections));

    Map<String?, bool> openedSections = {};
    for (Label label in sections) {
      openedSections[label.id] = true;
    }
    emit(state.copyWith(openedSections: openedSections));
  }

  Future<void> deleteSection(Label section) async {
    List<Label> sections = List.from(state.sections);
    sections.remove(section);
    emit(state.copyWith(sections: sections));

    String? now = TzUtils.toUtcStringIfNotNull(DateTime.now());

    section = section.copyWith(
      deletedAt: now,
      updatedAt: Nullable(now),
    );

    await updateLabel(section);

    _tasksCubit.refreshAllFromRepository();
  }

  Future<void> updateSection(Label sectionUpdated) async {
    sectionUpdated = sectionUpdated.copyWith(updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())));

    List<Label> sections = List.from(state.sections);
    int index = sections.indexWhere((section) => section.id == sectionUpdated.id);
    sections[index] = sectionUpdated;
    emit(state.copyWith(sections: sections));

    await updateLabel(sectionUpdated);
  }

  void toggleShowSnoozed() {
    emit(state.copyWith(showSnoozed: !state.showSnoozed));
  }

  void toggleShowSomeday() {
    emit(state.copyWith(showSomeday: !state.showSomeday));
  }

  void appbarActionEditLabel(BuildContext context) async {
    List<Label> folders = state.labels.where((label) => label.isFolder && label.deletedAt == null).toList();

    Label? updated = await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => CreateEditLabelModal(
        label: state.selectedLabel!,
        folders: folders,
      ),
    );
    if (updated != null) {
      saveLabel(updated);
    }
  }

  void appbarActionNewSection(BuildContext context) async {
    Label currentLabel = state.selectedLabel!;
    Label newSection = Label(id: const Uuid().v4(), parentId: currentLabel.id!, type: "section");

    LabelsCubit labelsCubit = context.read<LabelsCubit>();

    Label? section = await showCupertinoModalBottomSheet(
      context: context,
      builder: (context) => CreateEditSectionModal(initialSection: newSection),
    );

    if (section != null) {
      labelsCubit.addSectionToLocalUi(section);
      labelsCubit.addLabel(section, labelType: LabelType.section);
    }
  }

  void appbarActionDeleteLabel(BuildContext context) async {
    MainCubit mainCubit = context.read<MainCubit>();

    Label labelToDelete = state.selectedLabel!;

    showDialog(
        context: context,
        builder: (context) => DeleteLabelDialog(
              labelToDelete,
              justDeleteTheLabelClick: () {
                delete();

                Label deletedLabel = state.selectedLabel!;
                updateLabel(deletedLabel);

                mainCubit.changeHomeView(HomeViewType.inbox);
              },
              markAllTasksAsDoneClick: () {
                delete(markTasksAsDone: true);

                Label deletedLabel = state.selectedLabel!;
                updateLabel(deletedLabel);

                mainCubit.changeHomeView(HomeViewType.inbox);
              },
            ));
  }
}
