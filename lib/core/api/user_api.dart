import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/exceptions/api_exception.dart';
import 'package:models/user.dart';

class UserApi extends ApiClient {
  final HttpClient _httpClient = locator<HttpClient>();

  UserApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v4/user"),
          fromMap: User.fromMap,
        );

  Future<Map<String, dynamic>?> getSettings() async {
    Response responseRaw = await _httpClient.get(url);

    var response = jsonDecode(responseRaw.body);
    print('getSettings');
    print('getSettings: $response');
    if (response["data"] == null) {
      return null;
    } else if (response.containsKey("errors")) {
      throw ApiException(response);
    } else {
      return User.fromMap(response["data"]).settings;
    }
  }

  Future<Map<String, dynamic>?> postSettings(String id, Map<String, dynamic> newSettings) async {
    String json = jsonEncode({
      "clientId": id,
      "settings": newSettings,
    });

    Response responseRaw = await _httpClient.patch(Uri.parse("${Config.endpoint}/v4/user/settings"), body: json);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      throw ApiException(response);
    }

    User userUpdated = User.fromMap(response["data"]);

    return userUpdated.settings;
  }

  Future<User?> getUserData() async {
    Uri userUrl = Uri.parse("${Config.oauthEndpoint}/api/user?version=akiflow2");
    Response infoResponse = await _httpClient.get(userUrl);
    if (infoResponse.statusCode == 404) {
      return null;
    }
    try {
      final user = User.fromMap(json.decode(infoResponse.body));
      return user;
    } on FormatException {
      return null;
    }
  }

  Future<bool> hasValidPlan() async {
    User? user = await getUserData();
    return user != null ? DateTime.parse(user.planExpireDate!).isAfter(DateTime.now()) : false;
  }
}
