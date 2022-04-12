import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/api_exception.dart';
import 'package:models/account/account.dart';

abstract class IAccountApi {
  Future<List<Account>> all({
    DateTime? updatedAfter,
    bool allPages = false,
  });
}

class AccountApi implements IAccountApi {
  final HttpClient _httpClient = locator<HttpClient>();

  AccountApi();

  @override
  Future<List<Account>> all({
    DateTime? updatedAfter,
    bool allPages = false,
  }) async {
    Map<String, dynamic> params = {};

    if (updatedAfter != null) {
      params["updatedAfter"] = updatedAfter.toIso8601String();
    }

    Uri url = Uri.parse(Config.endpoint + "/v3/accounts");

    url = url.replace(queryParameters: params);

    Response responseRaw = await _httpClient.get(url);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      throw ApiException(response);
    }

    List<Account> accounts =
        response["data"].map<Account>((task) => Account.fromMap(task)).toList();

    String? nextPage = response["nextPage"];

    if (nextPage != null && allPages) {
      print("nextPage: $nextPage");

      List<Account> moreAccounts = await all(
        updatedAfter: updatedAfter,
        allPages: allPages,
      );

      accounts.addAll(moreAccounts);

      print("accounts: ${accounts.length}");
    }

    return accounts;
  }

  Future<List<Account>> post(List<Account> unsynced) async {
    Uri url = Uri.parse(Config.endpoint + "/v3/accounts");

    List<Map<String, dynamic>> jsonList =
        unsynced.map((item) => item.toMap()).toList();

    String json = jsonEncode(jsonList);

    Response responseRaw = await _httpClient.post(url, body: json);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    if (response.containsKey("errors")) {
      throw ApiException(response);
    }

    List<Account> items =
        response["data"].map<Account>((task) => Account.fromMap(task)).toList();

    return items;
  }
}
