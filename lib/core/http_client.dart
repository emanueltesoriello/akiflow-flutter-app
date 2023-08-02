import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/preferences.dart';
import 'package:models/user.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:math' as math;

Uri refreshTokenUrl = Uri.parse('https://web.akiflow.com/oauth/refreshToken');

class HttpClient extends BaseClient {
  final PreferencesRepository _preferences;

  final Client _inner;

  HttpClient(this._preferences) : _inner = Client();
  @override
  Future<StreamedResponse> send(BaseRequest request) async {
    User? user = _preferences.user;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String platform = Platform.isAndroid ? "android" : "ios";

    if (user != null) {
      request.headers['Authorization'] = "Bearer ${user.accessToken ?? ''}";
    }

    request.headers['Content-Type'] = "application/json";
    request.headers['Akiflow-Version'] = packageInfo.version;
    request.headers['Akiflow-Platform'] = platform;

    try {
      BaseDeviceInfo deviceInfo = await DeviceInfoPlugin().deviceInfo;
      String? deviceId = deviceInfo.toMap()['id'];
      if (deviceId == null) {
        deviceId = deviceInfo.toMap()["identifierForVendor"];
      }
      request.headers['Akiflow-ClientId'] = deviceId ?? '';
    } catch (e) {
      print(e);
    }

    int retryCount = 0;
    while (retryCount < 20) {
      StreamedResponse response = await _inner.send(request);

      if (response.statusCode >= 500 && response.statusCode < 600) {
        // Exponential backoff with jitter
        int delay = (100 * math.pow(2, retryCount) * (math.Random().nextDouble() * 0.2 + 0.9)).toInt();
        await Future.delayed(Duration(milliseconds: delay));
        retryCount++;
        continue; // Retry the request
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        bool result = await refreshToken(user);
        if (result) {
          return _inner.send(request);
        } else {
          return StreamedResponse(Stream<List<int>>.fromIterable([]), 401);
        }
      } else {
        return response; // Success or a client error, so no retry
      }
    }

    // If we reached here, we failed after 20 attempts
    print('Error after 20 retries');
    return StreamedResponse(Stream<List<int>>.fromIterable([]), 500);
  }

  Future<bool> refreshToken(User? user) async {
    if (user != null) {
      Response response = await _inner.post(refreshTokenUrl, body: {
        "client_id": Config.oauthClientId,
        "refresh_token": user.refreshToken,
      });
      Map<String, dynamic> map = jsonDecode(response.body);
      String statusCode = response.statusCode.toString();
      if (map["access_token"] == null && statusCode.startsWith('4')) {
        return clear();
      } else if (map["access_token"] != null) {
        return updateTokens(user, map);
      } else {
        return refreshToken(user);
      }
    }
    return clear();
  }

  Future<bool> clear() async {
    await _preferences.clear();
    return false;
  }

  Future<bool> updateTokens(User user, Map<String, dynamic> map) async {
    await _preferences.saveUser(user.copyWith(accessToken: map["access_token"], refreshToken: map["refresh_token"]));
    return true;
  }
}
