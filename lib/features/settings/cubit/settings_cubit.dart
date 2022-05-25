import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/account/account.dart';
import 'package:models/label/label.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();

  final SentryService _sentryService = locator<SentryService>();
  final DialogService _dialogService = locator<DialogService>();

  final LabelsCubit _labelCubit;

  SettingsCubit(this._labelCubit) : super(const SettingsCubitState()) {
    _init();
  }

  _init() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    emit(state.copyWith(appVersion: '$version ($buildNumber)'));

    List<Label> allItems = _labelCubit.state.labels;
    List<Label> folders = allItems.where((element) => element.type == "folder").toList();

    Map<Label, bool> folderOpen = {};

    for (var folder in folders) {
      folderOpen[folder] = false;
    }

    emit(state.copyWith(folderOpen: folderOpen));

    List<Account> accounts = await _accountsRepository.get();
    emit(state.copyWith(accounts: accounts));
  }

  void bugReport() {
    _sentryService.captureException(Exception('Bug report'));
    _dialogService.showMessage("Bug report sent");
  }

  void toggleFolder(Label folder) {
    Map<Label, bool> openFolder = Map.from(state.folderOpen);

    openFolder[folder] = !(openFolder[folder] ?? false);

    emit(state.copyWith(folderOpen: openFolder));
  }
}
