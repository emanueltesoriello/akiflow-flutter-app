import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  final SentryService _sentryService = locator<SentryService>();
  final DialogService _dialogService = locator<DialogService>();

  SettingsCubit() : super(const SettingsCubitState()) {
    _init();
  }

  _init() async {}

  void bugReport() {
    _sentryService.captureException(Exception('Bug report'));
    _dialogService.showMessage("Bug report sent");
  }
}
