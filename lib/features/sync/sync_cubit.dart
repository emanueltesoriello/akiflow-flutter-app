import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/api/core_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:models/user.dart';

part 'sync_state.dart';

class SyncCubit extends Cubit<SyncCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();

  Stream get syncCompletedStream => _syncControllerService.syncCompletedStream;

  SyncCubit() : super(const SyncCubitState(loading: true));

  sync({List<Entity>? entities, bool loading = false}) async {
    print("start sync $entities");
    return;

    try {
      emit(state.copyWith(loading: loading));

      await CoreApi().check();

      User? user = _preferencesRepository.user;

      if (user != null) {
        await _syncControllerService.sync(entities);

        print("sync completed");
      }

      emit(state.copyWith(loading: false));
    } catch (_) {
      emit(state.copyWith(loading: false));
    }
  }

  syncIntegration([List<IntegrationEntity>? entities]) async {
    print("start sync integration $entities");

    User? user = _preferencesRepository.user;

    if (user != null) {
      await _syncControllerService.syncIntegrationWithCheckUser();
    }
  }

  @override
  Future<void> close() async {
    await _syncControllerService.syncCompletedController.close();
    return super.close();
  }
}
