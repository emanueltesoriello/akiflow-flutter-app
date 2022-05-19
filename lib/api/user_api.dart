import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:models/user.dart';

class UserApi extends ApiClient {
  final HttpClient _httpClient = locator<HttpClient>();

  UserApi()
      : super(
          Uri.parse("${Config.endpoint}/v3/user"),
          fromMap: User.fromMap,
        );

  Future<User> get() async {
    Response responseRaw = await _httpClient.get(url);

    var response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      throw ApiException(response);
    } else {
      return fromMap(response["data"]);
    }
  }
}
