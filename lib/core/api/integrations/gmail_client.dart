import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';

class GmailClient extends BaseClient {
  final PreferencesRepository _preferencesRepository = locator<PreferencesRepository>();

  final Client _inner;
  AccountToken _accountToken;
  Account account;

  GmailClient(this._accountToken, {required this.account}) : _inner = Client();

  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    request.headers['Authorization'] = "Bearer ${_accountToken.accessToken ?? ''}";

    StreamedResponse streamedResponse = await _inner.send(request);

    if (streamedResponse.statusCode == 401 || streamedResponse.statusCode == 403) {
      await refreshToken();

      BaseRequest newRequest = _buildNewRequest(request);

      return await _inner.send(newRequest);
    } else {
      return streamedResponse;
    }
  }

  BaseRequest _buildNewRequest(BaseRequest originalRequest) {
    originalRequest.headers['Authorization'] = "Bearer ${_accountToken.accessToken ?? ''}";

    if (originalRequest is MultipartRequest) {
      return MultipartRequest(originalRequest.method, originalRequest.url)
        ..fields.addAll(originalRequest.fields)
        ..files.addAll(originalRequest.files)
        ..headers.addAll(originalRequest.headers)
        ..persistentConnection = (originalRequest).persistentConnection
        ..followRedirects = (originalRequest).followRedirects
        ..maxRedirects = (originalRequest).maxRedirects
        ..contentLength = (originalRequest).contentLength;
    } else {
      return Request(originalRequest.method, originalRequest.url)
        ..encoding = (originalRequest as Request).encoding
        ..body = (originalRequest).body
        ..headers.addAll(originalRequest.headers)
        ..persistentConnection = (originalRequest).persistentConnection
        ..followRedirects = (originalRequest).followRedirects
        ..maxRedirects = (originalRequest).maxRedirects
        ..bodyBytes = originalRequest.bodyBytes;
    }
  }

  Future<void> refreshToken() async {
    Response response = await _inner.post(Uri.parse('https://oauth2.googleapis.com/token'), body: {
      "client_id": Platform.isIOS ? Config.googleCredentials.clientIdiOS : Config.googleCredentials.clientIdAndroid,
      "grant_type": 'refresh_token',
      "refresh_token": _accountToken.refreshToken,
    });

    var result = jsonDecode(response.body);

    AccountToken accountWithNewAccessToken = _preferencesRepository.getAccountToken(account.accountId!)!;

    DateTime now = DateTime.now();
    DateTime expiration = now.add(Duration(seconds: result['expires_in'] as int? ?? 0));

    accountWithNewAccessToken = accountWithNewAccessToken.copyWith(
      accessToken: result?['access_token'],
      idToken: result?['id_token'],
      accessTokenExpirationDateTime: expiration,
      tokenType: result?['token_type'],
    );

    await _preferencesRepository.setAccountToken(account.accountId!, accountWithNewAccessToken);

    _accountToken = accountWithNewAccessToken;

    print("gmail api token refreshed");
  }
}
