import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:mobile/api/base_api.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/utils/converters_isolate.dart';

class ApiClient implements IBaseApi {
  final HttpClient _httpClient = locator<HttpClient>();

  final Uri url;
  final Function(Map<String, dynamic>) fromMap;

  ApiClient(this.url, {required this.fromMap});

  @override
  Future<List<T>> get<T>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = true,
  }) async {
    int page = 1;

    Map<String, dynamic> params = {
      "per_page": perPage.toString(),
      "with_deleted": withDeleted.toString(),
      "page": page.toString(),
    };

    if (updatedAfter != null) {
      params["updatedAfter"] = updatedAfter.toIso8601String();
    }

    Map<String, dynamic> response;

    List<T> result = [];

    do {
      params["page"] = page.toString();
      Uri urlWithQueryParameters = url.replace(queryParameters: params);

      print(urlWithQueryParameters);

      Response responseRaw = await _httpClient.get(urlWithQueryParameters);

      response = jsonDecode(responseRaw.body);
      if (response.containsKey("errors")) {
        throw ApiException(response);
      }
      if (response.containsKey("data") && response["data"] != null) {
        List<dynamic> items = response["data"];
        result = await compute(convertToObjList, RawListConvert(items: items, converter: fromMap));
      }
      page++;
    } while (response["next_page_url"] != null);

    return result;
  }

  @override
  Future<List<T>> post<T>({
    required List<T> unsynced,
  }) async {
    List<dynamic> jsonList = await compute(fromObjToMapList, unsynced);

    String json = jsonEncode(jsonList);

    Response responseRaw = await _httpClient.post(url, body: json);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      print(response);
      throw ApiException(response);
    }

    List<dynamic> items = response["data"];

    List<T> result = await compute(convertToObjList, RawListConvert(items: items, converter: fromMap));

    return result;
  }
}
