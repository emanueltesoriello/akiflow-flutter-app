import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/utils/tz_utils.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/core/repository/availabilities_repository.dart';
import 'package:mobile/extensions/date_extension.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../../core/api/availability_api.dart';
import '../models/navigation_state.dart';
import 'package:models/task/availability_config.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

part 'availability_state.dart';

class AvailabilityCubit extends Cubit<AvailabilityCubitState> {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();
  final AvailabilitiesRepository _availabilitiesRepository = locator<AvailabilitiesRepository>();

  static final AvailabilityApi _client = locator<AvailabilityApi>();

  AvailabilityCubit() : super(const AvailabilityCubitState()) {
    _init();
  }

  _init() async {
    if (_preferencesRepository.user != null) {
      await getAvailabilities();
    }
  }

  String getAbbreviatedTimezone(String? timezone, String? minTime) {
    tz.initializeTimeZones();
    try {
      if (timezone != null && timezone.isNotEmpty && minTime != null && minTime.isNotEmpty) {
        final locationTz = tz.getLocation(timezone);
        var timeInUtc = DateTime.parse(minTime).toUtc();
        var isDst = locationTz.timeZone(timeInUtc.millisecondsSinceEpoch).isDst;
        if (isDst &&
            LocalizationAbbreviations.abbreviations[timezone] != null &&
            LocalizationAbbreviations.abbreviations[timezone]?["dst"] != null) {
          return LocalizationAbbreviations.abbreviations[timezone]?["dst"] ?? '-';
        } else {
          return LocalizationAbbreviations.abbreviations[timezone]?["default"] ?? '-';
        }
      }
    } catch (e) {
      print(e);
    }
    return '-';
  }

  String getAvailabilityText(AvailabilityConfig config) {
    DateTime? start;
    DateTime? end;
    int? startTime = config.slots_configuration?.last.startTime;
    int? endTime = config.slots_configuration?.last.endTime;

    if (startTime != null && endTime != null) {
      start = DateTime.fromMillisecondsSinceEpoch(startTime, isUtc: true).toLocal();
      end = DateTime.fromMillisecondsSinceEpoch(endTime, isUtc: true).toLocal();
    }
    String text = (config.type == AvailabililtyConfigSlotsType.manual && start != null && end != null)
        ? ''' Would any of these times work for you for a ${config.durationString} meeting? ${"(${getAbbreviatedTimezone(config.timezone, config.min_start_time)})"}
${start.shortDateFormatted}
• ${start.timeFormatted} - ${end.timeFormatted}
Let me know or confirm here:
https://booking.akiflow.com/${config.url_path}'''
        : " https://booking.akiflow.com/${config.url_path}";
    print(text);
    return text;
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
    emit(state.copyWith(
        availabilities: availabilities
            .where((element) =>
                element.max_end_time == null || DateTime.parse(element.max_end_time ?? '').isAfter(DateTime.now()))
            .toList(),
        navigationState: AvailabilityNavigationState.mainPage));

    List<AvailabilityConfig> networkAvailabilities = await _client.getItems(
        perPage: 2500,
        withDeleted: false,
        nextPageUrl: Uri.parse("${Config.endpoint}/v3/availability-configs?with_deleted=false"));
    List<AvailabilityConfig> filteredNetworkAvailabilities = networkAvailabilities
        .where((element) =>
            element.max_end_time == null || DateTime.parse(element.max_end_time ?? '').isAfter(DateTime.now()))
        .toList();
    emit(state.copyWith(
        navigationState: AvailabilityNavigationState.mainPage, availabilities: filteredNetworkAvailabilities));
    await _availabilitiesRepository.add(filteredNetworkAvailabilities);
  }

  launchUrl(String? urlPath) {
    launchUrlString("https://booking.akiflow.com/$urlPath", mode: LaunchMode.externalApplication);
  }

  Future<void> copyLinkToClipboard(AvailabilityConfig config) async {
    Clipboard.setData(ClipboardData(text: getAvailabilityText(config)));
  }
}
