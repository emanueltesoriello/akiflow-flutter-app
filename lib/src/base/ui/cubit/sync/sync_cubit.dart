import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/api/core_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:models/user.dart';

part 'sync_state.dart';

class SyncCubit extends Cubit<SyncCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();
  Stream get syncCompletedStream => _syncControllerService.syncCompletedStream;

  SyncCubit() : super(const SyncCubitState(loading: true));

  Future sync({List<Entity>? entities, bool loading = true}) async {
    print("start sync $entities");

    try {
      emit(state.copyWith(loading: loading));

      await CoreApi().check();
      emit(state.copyWith(networkError: false));

      User? user = _preferencesRepository.user;

      if (user != null) {
        await _syncControllerService.sync(entities);
        print("sync completed");
      }

      emit(state.copyWith(loading: false));
    } catch (e) {
      print("sync error $e");
      emit(state.copyWith(error: true, loading: false, networkError: true));
    }
    return;
  }

  syncIntegration([List<IntegrationEntity>? entities]) async {
    print("start sync integration $entities");

    User? user = _preferencesRepository.user;

    if (user != null) {
      await _syncControllerService.syncIntegrationWithCheckUser();
    }
  }

  Future checkConnectivity() async {
    try {
      await CoreApi().check();
      emit(state.copyWith(networkError: false));
    } catch (e) {
      emit(state.copyWith(networkError: true));
    }
  }

  void showLoadingIcon(bool loading) {
    emit(state.copyWith(loading: loading));
  }

  @override
  Future<void> close() async {
    await _syncControllerService.syncCompletedController.close();
    return super.close();
  }
}
