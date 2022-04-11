import 'dart:convert';

import 'package:http/http.dart';
import 'package:mobile/core/config.dart';
import 'package:mobile/core/http_client.dart';
import 'package:mobile/core/locator.dart';
import 'package:models/task/task.dart';

abstract class ITasksApi {
  Future<List<Task>> all();
}

class TasksApi implements ITasksApi {
  final HttpClient _httpClient = locator<HttpClient>();

  TasksApi();

  @override
  Future<List<Task>> all() async {
    Uri url = Uri.parse(Config.endpoint + "/tasks");

    Response responseRaw = await _httpClient.get(url);

    Map<String, dynamic> response = jsonDecode(responseRaw.body);

    List<Task> tasks =
        response["data"].map<Task>((task) => Task.fromMap(task)).toList();

    return tasks;
  }
}
