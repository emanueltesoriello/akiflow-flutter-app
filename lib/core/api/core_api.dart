import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/exceptions/api_exception.dart';

class CoreApi {
  final HttpClient _httpClient = locator<HttpClient>();

  CoreApi();

  Future<void> check() async {
    Response response = await _httpClient.get(Uri.parse("${Config.endpoint}/check"));

    if (response.statusCode != 204) {
      throw ApiException(jsonDecode(response.body));
    }
  }
}
