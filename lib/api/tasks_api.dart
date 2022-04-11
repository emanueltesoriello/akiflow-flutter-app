import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:models/task/task.dart';

abstract class ITasksApi {
  Future<List<Task>> all({
    int perPage,
    bool withDeleted,
    required DateTime updatedAfter,
  });
}

class TasksApi implements ITasksApi {
  final HttpClient _httpClient = locator<HttpClient>();

  TasksApi();

  @override
  Future<List<Task>> all({
    int perPage = 2500,
    bool withDeleted = true,
    required DateTime updatedAfter,
  }) async {
    Map<String, dynamic> params = {
      "perPage": perPage.toString(),
      "withDeleted": withDeleted.toString(),
      "updatedAfter": updatedAfter.toIso8601String(),
    };

    Uri url = Uri.parse(Config.endpoint + "/tasks");

    url = url.replace(queryParameters: params);

    Response responseRaw = await _httpClient.get(url);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    List<Task> tasks =
        response["data"].map<Task>((task) => Task.fromMap(task)).toList();

    return tasks;
  }

  Future<List<Task>> post(List<Task> unsynced) async {
    Uri url = Uri.parse(Config.endpoint + "/tasks");

    // json list
    List<Map<String, dynamic>> jsonList =
        unsynced.map((task) => task.toMap()).toList();

    String json = jsonEncode(jsonList);

    Response responseRaw = await _httpClient.post(url, body: json);

    if (responseRaw.body == "[]") {
      return [];
    }

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    List<Task> tasks =
        response["data"].map<Task>((task) => Task.fromMap(task)).toList();

    return tasks;
  }
}
