import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';

part 'label_state.dart';

class LabelCubit extends Cubit<LabelCubitState> {
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();

  final LabelsCubit labelsCubit;

  LabelCubit(Label label, {required this.labelsCubit}) : super(LabelCubitState(selectedLabel: label)) {
    _init();
  }

  _init() async {
    labelsCubit.getLabelTasks(state.selectedLabel);

    List<Label> allLabels = await _labelsRepository.get();
    List<Label> sections = allLabels.where((label) => label.type == "section" && label.deletedAt == null).toList();
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

  void setColor(String rawColorName) {
    Label label = state.selectedLabel!.copyWith(color: rawColorName);
    emit(state.copyWith(selectedLabel: label));
  }

  void setFolder(Label folder) {
    Label label = state.selectedLabel!.copyWith(parentId: folder.id);
    emit(state.copyWith(selectedLabel: label));
  }

  void saveLabel(Label label) {
    label = label.copyWith(updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()));
    labelsCubit.updateLabel(label);
    emit(state.copyWith(selectedLabel: label));
  }

  void titleChanged(String value) {
    Label label = state.selectedLabel!.copyWith(title: value);
    emit(state.copyWith(selectedLabel: label));
  }

  void toggleSorting() {
    TaskListSorting sorting = state.sorting;

    if (sorting == TaskListSorting.ascending) {
      emit(state.copyWith(sorting: TaskListSorting.descending));
    } else {
      emit(state.copyWith(sorting: TaskListSorting.ascending));
    }
  }

  void toggleShowDone() {
    emit(state.copyWith(showDone: !state.showDone));
  }

  Future<void> delete() async {
    Label labelUpdated = state.selectedLabel!.copyWith(deletedAt: DateTime.now().toUtc().toIso8601String());
    emit(state.copyWith(selectedLabel: labelUpdated));
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
}
