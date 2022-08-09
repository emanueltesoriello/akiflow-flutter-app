import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:mobile/core/api/base_api.dart';
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
  Future<List<T>> getItems<T>({
    int perPage = 2500,
    bool withDeleted = true,
    DateTime? updatedAfter,
    bool allPages = true,
    Uri? nextPageUrl,
  }) async {
    Map<String, dynamic> response;

    List<T> result = [];

    Uri urlWithQueryParameters;

    if (nextPageUrl != null) {
      urlWithQueryParameters = nextPageUrl;
    } else {
      Map<String, dynamic> params = {
        "per_page": perPage.toString(),
        "with_deleted": withDeleted.toString(),
      };

      if (updatedAfter != null) {
        params["updatedAfter"] = updatedAfter.toIso8601String();
      }

      urlWithQueryParameters = url.replace(queryParameters: params);
    }

    print(urlWithQueryParameters);

    Response responseRaw = await _httpClient.get(urlWithQueryParameters);

    response = jsonDecode(responseRaw.body);
    if (response.containsKey("errors")) {
      throw ApiException(response);
    }
    if (response.containsKey("data") && response["data"] != null) {
      List<dynamic> items = response["data"];
      List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromMap));
      result.addAll(objects);
    }

    if (response["next_page_url"] != null) {
      result.addAll(await getItems<T>(
        perPage: perPage,
        withDeleted: withDeleted,
        updatedAfter: updatedAfter,
        nextPageUrl: Uri.parse(response["next_page_url"]),
      ));
    }

    return result;
  }

  @override
  Future<List<T>> postUnsynced<T>({
    required List<T> unsynced,
  }) async {
    List<dynamic> jsonList = await compute(fromObjToMapList, unsynced);

    String json = jsonEncode(jsonList);

    Response responseRaw = await _httpClient.post(url, body: json);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      log(json);
      print(response);
      throw ApiException(response);
    }

    List<dynamic> items = response["data"];

    List<T> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromMap));

    return objects;
  }
}
