import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:mobile/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:mobile/utils/converters_isolate.dart';
import 'package:models/account/account_v2.dart';

class AccountV2Api extends ApiClient {
  final HttpClient _httpClient = locator<HttpClient>();

  AccountV2Api()
      : super(
          Uri.parse("${Config.endpoint}/v2/accounts"),
          fromMap: AccountV2.fromMap,
        );

  @override
  Future<List<T>> getItems<T>({
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

    List<AccountV2> result = [];

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
        List<AccountV2> objects = await compute(convertToObjList, RawListConvert(items: items, converter: fromMap));

        // Filter only Gmail account
        objects = objects.where((item) => item.connectorId == "gmail").toList();

        result.addAll(objects);
      }
      page++;
    } while (response["next_page_url"] != null);

    return result as List<T>;
  }
}
