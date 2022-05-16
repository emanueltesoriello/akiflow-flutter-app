import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  final SentryService _sentryService = locator<SentryService>();
  final DialogService _dialogService = locator<DialogService>();

  SettingsCubit() : super(const SettingsCubitState()) {
    _init();
  }

  _init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    emit(state.copyWith(appVersion: '$version ($buildNumber)'));
  }

  void bugReport() {
    _sentryService.captureException(Exception('Bug report'));
    _dialogService.showMessage("Bug report sent");
  }
}
