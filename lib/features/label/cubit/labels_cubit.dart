import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/repository/labels_repository.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:models/label/label.dart';
import 'package:models/user.dart';

part 'labels_state.dart';

class LabelsCubit extends Cubit<LabelsCubitState> {
  final LabelsRepository _labelsRepository = locator<LabelsRepository>();
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  LabelsCubit() : super(const LabelsCubitState()) {
    _init();
  }

  _init() async {
    await syncAllAndRefresh();
  }

  Future<void> addLabel(Label newLabel) async {
    User user = _preferencesRepository.user!;

    newLabel = newLabel.copyWith(userId: user.id);

    List<Label> labels = List.from(state.labels);
    labels.add(newLabel);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.add([newLabel]);

    await _syncControllerService.syncAll();

    await _init();
  }

  Future<void> updateLabel(Label label) async {
    List<Label> labels = List.from(state.labels);
    labels.add(label);
    emit(state.copyWith(labels: labels));

    await _labelsRepository.updateById(label.id, data: label);

    await syncAllAndRefresh();
  }

  Future<void> syncAllAndRefresh() async {
    await _syncControllerService.syncAll();

    List<Label> labels = await _labelsRepository.get();
    emit(state.copyWith(labels: labels));
  }
}
