import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/api/base_api.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:models/base.dart';

class Api implements IBaseApi {
  final HttpClient _httpClient = locator<HttpClient>();

  final Uri url;
  final Function(Map<String, dynamic>) fromMap;

  Api(this.url, {required this.fromMap});

  @override
  Future<List<T>> get<T>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = false,
  }) async {
    Map<String, dynamic> params = {
      "perPage": perPage.toString(),
      "withDeleted": withDeleted.toString(),
    };

    if (updatedAfter != null) {
      params["updatedAfter"] = updatedAfter.toIso8601String();
    }

    Uri urlWithQueryParameters = url.replace(queryParameters: params);

    Response responseRaw = await _httpClient.get(urlWithQueryParameters);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      throw ApiException(response);
    }

    List<dynamic> items = response["data"];

    String? nextPage = response["nextPage"];

    if (nextPage != null && allPages) {
      print("nextPage: $nextPage");

      List<T> moreItems = await get(
        perPage: perPage,
        withDeleted: withDeleted,
        updatedAfter: updatedAfter,
        allPages: allPages,
      );

      items.addAll(moreItems);

      print("items: ${items.length}");
    }

    List<T> result = [];

    for (dynamic item in items) {
      result.add(fromMap(item));
    }

    return result;
  }

  @override
  Future<List<T>> post<T>({
    required List<T> unsynced,
  }) async {
    List<dynamic> jsonList = [];

    for (T item in unsynced) {
      jsonList.add((item as Base).toMap());
    }

    String json = jsonEncode(jsonList);

    Response responseRaw = await _httpClient.post(url, body: json);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      throw ApiException(response);
    }

    List<dynamic> items = response["data"];

    List<T> result = [];

    for (dynamic item in items) {
      result.add(fromMap(item));
    }

    return result;
  }
}
