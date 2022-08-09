import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;

class GoogleApi {
  static const String authEndpoint = 'https://www.googleapis.com/oauth2/v1';

  Future<Map<String, dynamic>> accountData(String accessToken) async {
    Response response = await http.get(Uri.parse("$authEndpoint/userinfo?alt=json"), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
