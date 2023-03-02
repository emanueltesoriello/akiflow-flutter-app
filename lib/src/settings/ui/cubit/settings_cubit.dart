import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  final SentryService _sentryService = locator<SentryService>();

  SettingsCubit() : super(const SettingsCubitState()) {
    _init();
  }

  _init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    emit(state.copyWith(appVersion: '$version ($buildNumber)'));
  }

  Future<void> launchIntercom() async {
    await Intercom.instance.displayMessenger();
  }

  Future<void> sendEmail() async {
    try {
      SentryId? sentryId = await _sentryService.captureException(Exception('Bug report'));

      if (sentryId != null) {
        launchUrl(
          Uri.parse("mailto:support@akiflow.com?subject=Mobile%20Request%20${sentryId.toString()}"),
          mode: LaunchMode.externalApplication,
        );
      } else {
        launchUrl(Uri.parse("mailto:support@akiflow.com"), mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      launchUrl(Uri.parse("mailto:support@akiflow.com"), mode: LaunchMode.externalApplication);
    }
  }
}
