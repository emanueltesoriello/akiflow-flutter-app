import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/api/integrations/google_api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:mobile/exceptions/database_exception.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_import_task_modal.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_mark_done_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/services/dialog_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/tz_utils.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';
import 'package:models/label/label.dart';
import 'package:models/nullable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  final SentryService _sentryService = locator<SentryService>();
  final DialogService _dialogService = locator<DialogService>();
  final GoogleApi _googleApi = locator<GoogleApi>();

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

  Future<void> gmailImportOptions(Account account, GmailSyncMode selectedType) async {
    Map<String, dynamic>? settings = Map.from(account.details ?? {});
    settings['syncMode'] = selectedType.key;

    account = account.copyWith(
      details: settings,
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
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
      updatedAt: Nullable(TzUtils.toUtcStringIfNotNull(DateTime.now())),
    );

    await _accountsRepository.updateById(account.id, data: account);

    List<Account> accounts = await _accountsRepository.get();
    emit(state.copyWith(accounts: accounts.where((element) => element.deletedAt == null).toList()));

    _syncCubit.sync();
  }

  Future<void> connectGmail() async {
    emit(state.copyWith(isAuthenticatingOAuth: true));

    FlutterAppAuth appAuth = const FlutterAppAuth();

    final AuthorizationTokenResponse? result = await appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        Platform.isIOS ? Config.googleCredentials.clientIdiOS : Config.googleCredentials.clientIdAndroid,
        Config.oauthRedirectUrl,
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

    Map<String, dynamic> accountData = await _googleApi.accountData(result!.accessToken!);

    AccountToken accountToken = AccountToken(
      id: "gmail-${accountData['id']}",
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
      accessTokenExpirationDateTime: result.accessTokenExpirationDateTime,
      tokenType: result.tokenType,
      idToken: result.idToken,
    );

    Account account = Account(
      id: const Uuid().v4(),
      accountId: accountToken.id!,
      connectorId: "gmail",
      originAccountId: accountData['id'],
      shortName: accountData['given_name'],
      fullName: accountData['family_name'],
      picture: accountData['picture'],
      identifier: accountData['email'],
      status: "INITIATED",
      createdAt: TzUtils.toUtcStringIfNotNull(DateTime.now()),
    );

    print("set account token in preferences for account ${account.id}");

    await _preferencesRepository.setAccountToken(account.id!, accountToken);

    try {
      Account? existingAccount = await _accountsRepository.getByAccountId(account.accountId);

      await _accountsRepository.updateById(existingAccount!.id, data: account);
    } on DatabaseItemNotFoundException {
      await _accountsRepository.add([account]);
    }

    emit(state.copyWith(isAuthenticatingOAuth: false));

    List<Account> accounts = await _accountsRepository.get();
    emit(state.copyWith(accounts: accounts.where((element) => element.deletedAt == null).toList()));

    emit(state.copyWith(connected: true));
    emit(state.copyWith(connected: false));

    _syncCubit.syncIntegration([IntegrationEntity.gmail]);
  }

  void syncGmail() {
    _syncCubit.syncIntegration([IntegrationEntity.gmail]);
  }
}
