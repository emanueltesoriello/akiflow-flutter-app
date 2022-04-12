import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:models/account/account.dart';

abstract class IAccountApi {
  Future<List<Account>> all();
}

class AccountApi implements IAccountApi {
  final HttpClient _httpClient = locator<HttpClient>();

  AccountApi();

  @override
  Future<List<Account>> all() async {
    Uri url = Uri.parse(Config.endpoint + "/v3/accounts");

    Response responseRaw = await _httpClient.get(url);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    List<Account> items =
        response["data"].map<Account>((task) => Account.fromMap(task)).toList();

    return items;
  }

  Future<List<Account>> post(List<Account> unsynced) async {
    Uri url = Uri.parse(Config.endpoint + "/v3/accounts");

    // json list
    List<Map<String, dynamic>> jsonList =
        unsynced.map((item) => item.toMap()).toList();

    String json = jsonEncode(jsonList);

    Response responseRaw = await _httpClient.post(url, body: json);

    if (responseRaw.body == "[]") {
      return [];
    }

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    List<Account> items =
        response["data"].map<Account>((task) => Account.fromMap(task)).toList();

    return items;
  }
}
