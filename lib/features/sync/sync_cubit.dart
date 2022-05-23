import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:models/user.dart';

part 'sync_state.dart';

class SyncCubit extends Cubit<SyncCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final SyncControllerService _syncControllerService = locator<SyncControllerService>();

  SyncCubit() : super(const SyncCubitState());

  Stream get syncCompletedStream => _syncControllerService.syncCompletedStream;

  sync([List<Entity>? entities]) async {
    print("start sync $entities");

    User? user = _preferencesRepository.user;

    if (user != null) {
      emit(state.copyWith(loading: true));

      await _syncControllerService.sync(entities);

      emit(state.copyWith(loading: false));
    }
  }
}
