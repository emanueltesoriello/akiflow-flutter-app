import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/availabilities_repository.dart';
import '../../../../core/api/availability_api.dart';
import '../models/navigation_state.dart';
import 'package:models/task/availability_config.dart';

part 'availability_state.dart';

class AvailabilityCubit extends Cubit<AvailabilityCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final AvailabilitiesRepository _availabilitiesRepository = locator<AvailabilitiesRepository>();

  static final AvailabilityApi _client = locator<AvailabilityApi>();

  AvailabilityCubit() : super(const AvailabilityCubitState()) {
    _init();
  }

  _init() async {
    if (_preferencesRepository.inboxNoticeHidden == false) {
      emit(state.copyWith(isNoticeDismissed: false));
    }
    if (_preferencesRepository.user != null) {
      await getAvailabilities();
    }
  }

  Future<void> noticeClosed() async {
    emit(state.copyWith(isNoticeDismissed: true));
    await _preferencesRepository.setAvailabilitiesNoticeHidden(true);
  }

  void toggleHeader(AvailabililtyConfigSlotsType type) {
    switch (type) {
      case AvailabililtyConfigSlotsType.manual:
        emit(state.copyWith(isManualOpen: !state.isManualOpen));
        return;
      case AvailabililtyConfigSlotsType.recurrent:
        emit(state.copyWith(isRecurrentOpen: !state.isRecurrentOpen));
        return;
    }
  }

  Future<void> getAvailabilities() async {
    List<AvailabilityConfig> availabilities = await _availabilitiesRepository.getAvailabilities();
    emit(state.copyWith(availabilities: availabilities, navigationState: AvailabilityNavigationState.mainPage));
    List<AvailabilityConfig> networkAvailabilities = await _client.getItems(
        perPage: 2500, withDeleted: false, nextPageUrl: Uri.parse("${Config.endpoint}/v3/availability-configs"));
    emit(state.copyWith(
      navigationState: AvailabilityNavigationState.mainPage,
      availabilities: networkAvailabilities,
    ));
    await _availabilitiesRepository.add(networkAvailabilities);
  }
}
