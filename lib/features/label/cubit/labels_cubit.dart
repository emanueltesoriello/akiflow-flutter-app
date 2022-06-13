import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/services/analytics_service.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:models/label/label.dart';
import 'package:models/user.dart';

part 'labels_state.dart';

enum LabelType { folder, label, section }

class LabelsCubit extends Cubit<LabelsCubitState> {
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

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

    newLabel = newLabel.copyWith(userId: user.id);

    List<Label> labels = List.from(state.labels);
    labels.add(newLabel);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.add([newLabel]);

    _syncCubit.sync([Entity.labels]);

    switch (labelType) {
      case LabelType.folder:
        locator<AnalyticsService>().track("New Label Folder");
        break;
      case LabelType.label:
        locator<AnalyticsService>().track("New Label");
        break;
      case LabelType.section:
        locator<AnalyticsService>().track("New Section");
        break;
    }
  }

  Future<void> updateLabel(Label label) async {
    List<Label> labels = List.from(state.labels);

    int index = labels.indexWhere((l) => l.id == label.id);

    labels[index] = label;

    emit(state.copyWith(labels: labels));

    await _labelsRepository.updateById(label.id, data: label);

    _syncCubit.sync([Entity.labels]);
  }

  Future<void> addSectionToDatabase(Label newSection) async {
    User user = _preferencesRepository.user!;

    newSection = newSection.copyWith(userId: user.id);

    List<Label> labels = List.from(state.labels);
    labels.add(newSection);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.add([newSection]);

    await _syncCubit.sync([Entity.labels]);

    await _init();
  }

  Future<void> fetchLabels() async {
    List<Label> labels = await _labelsRepository.get();
    emit(state.copyWith(labels: labels));
  }
}
