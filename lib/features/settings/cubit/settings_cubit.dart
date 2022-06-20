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
import 'package:mobile/features/settings/ui/gmail/gmail_mark_done_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/repository/accounts_repository.dart';
import 'package:mobile/services/analytics_service.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/services/sync_controller_service.dart';
import 'package:mobile/utils/tz_utils.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';
import 'package:models/integrations/gmail.dart';
import 'package:models/nullable.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsCubitState> {
  final AccountsRepository _accountsRepository = locator<AccountsRepository>();
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  final SentryService _sentryService = locator<SentryService>();
  final GoogleApi _googleApi = locator<GoogleApi>();

  final AuthCubit _authCubit;
  late final SyncCubit _syncCubit;

  SettingsCubit(this._authCubit, this._syncCubit) : super(const SettingsCubitState()) {
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

    List<Account> accounts = await _accountsRepository.get();
    emit(state.copyWith(accounts: accounts.where((element) => element.deletedAt == null).toList()));
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

    print("set account token in preferences for account ${account.accountId}");

    await _preferencesRepository.setAccountToken(account.accountId!, accountToken);

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

    AnalyticsService.track("Connector Connected");

    _syncCubit.syncIntegration([IntegrationEntity.gmail]);
  }

  void syncGmail() {
    _syncCubit.syncIntegration([IntegrationEntity.gmail]);
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
