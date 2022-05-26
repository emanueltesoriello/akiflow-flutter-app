import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_import_task_modal.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_mark_done_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:models/account/account.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:package_info_plus/package_info_plus.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();

  final SentryService _sentryService = locator<SentryService>();
  final DialogService _dialogService = locator<DialogService>();

  final LabelsCubit _labelCubit;
  final AuthCubit _authCubit;
  late final SyncCubit _syncCubit;

  SettingsCubit(this._labelCubit, this._authCubit, this._syncCubit) : super(const SettingsCubitState()) {
    _syncCubit.syncCompletedStream.listen((_) async {
      List<Account> accounts = await _accountsRepository.get();
      emit(state.copyWith(accounts: accounts.where((element) => element.deletedAt == null).toList()));
    });

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
    emit(state.copyWith(accounts: accounts.where((element) => element.deletedAt == null).toList()));
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

  Future<void> gmailImportOptions(Account account, GmailImportTaskType selectedType) async {
    Map<String, dynamic>? settings = Map.from(account.details ?? {});
    settings['syncMode'] = selectedType.key;

    account = account.copyWith(
      details: settings,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    await _accountsRepository.updateById(account.id, data: account);

    List<Account> accounts = await _accountsRepository.get();
    emit(state.copyWith(accounts: accounts.where((element) => element.deletedAt == null).toList()));

    _syncCubit.sync();
  }

  void gmailBehaviorOnMarkAsDone(GmailMarkAsDoneType selectedType) {
    Map<String, dynamic> settings = Map.from(_authCubit.state.user!.settings ?? {});
    Map<String, dynamic> popups = settings['popups'] ?? {};

    popups['gmail.unstar'] = selectedType.key;

    settings['popups'] = popups;

    _authCubit.updateUserSettings(Map<String, dynamic>.from(settings));
  }

  Future<void> updateGmailSuperHumanEnabled(Account account, {required bool isSuperhumanEnabled}) async {
    Map<String, dynamic>? settings = Map.from(account.details ?? {});
    settings['isSuperhumanEnabled'] = isSuperhumanEnabled;

    account = account.copyWith(
      details: settings,
      updatedAt: Nullable(DateTime.now().toUtc().toIso8601String()),
    );

    await _accountsRepository.updateById(account.id, data: account);

    List<Account> accounts = await _accountsRepository.get();
    emit(state.copyWith(accounts: accounts.where((element) => element.deletedAt == null).toList()));

    _syncCubit.sync();
  }

  Future<void> connectGmail() async {
    FlutterAppAuth appAuth = const FlutterAppAuth();

    final AuthorizationResponse? result = await appAuth.authorize(
      AuthorizationRequest(
        Config.googleCredentials.clientId,
        Config.googleCredentials.redirectUri,
        preferEphemeralSession: true,
        serviceConfiguration: const AuthorizationServiceConfiguration(
          authorizationEndpoint: 'https://accounts.google.com/o/oauth2/auth',
          tokenEndpoint: "https://oauth2.googleapis.com/token",
        ),
        scopes: [
          'https://www.googleapis.com/auth/userinfo.email',
          'https://www.googleapis.com/auth/userinfo.profile',
          'https://www.googleapis.com/auth/gmail.modify',
        ],
      ),
    );

    print(result);

    // TODO gmail sync
  }
}
