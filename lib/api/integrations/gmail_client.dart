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
    BaseRequest request;

    if (originalRequest is MultipartRequest) {
      request = MultipartRequest(originalRequest.method, originalRequest.url)
        ..fields.addAll(originalRequest.fields)
        ..files.addAll(originalRequest.files);
    } else {
      request = Request(originalRequest.method, originalRequest.url)
        ..encoding = (originalRequest as Request).encoding
        ..bodyBytes = originalRequest.bodyBytes;
    }

    request.headers['Authorization'] = "Bearer ${_accountToken.accessToken ?? ''}";

    originalRequest.headers.forEach((key, value) {
      request.headers[key] = value;
    });

    return request;
  }

  Future<void> refreshToken() async {
    Response response = await _inner.post(Uri.parse('https://oauth2.googleapis.com/token'), body: {
      "client_id": Platform.isIOS ? Config.googleCredentials.clientIdiOS : Config.googleCredentials.clientIdAndroid,
      "grant_type": 'refresh_token',
      "refresh_token": _accountToken.refreshToken,
    });

    var result = jsonDecode(response.body);

    AccountToken accountWithNewAccessToken = _preferencesRepository.getAccountToken(account.id!)!;

    accountWithNewAccessToken = accountWithNewAccessToken.copyWith(
      accessToken: result?['accessToken'],
      refreshToken: result?['refreshToken'],
      accessTokenExpirationDateTime: result?['accessTokenExpirationDateTime'],
      tokenType: result?['tokenType'],
      idToken: result?['idToken'],
    );

    await _preferencesRepository.setAccountToken(_accountToken.id!, accountWithNewAccessToken);

    _accountToken = accountWithNewAccessToken;

    print("gmail api token refreshed");
  }
}
