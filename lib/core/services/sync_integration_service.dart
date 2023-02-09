import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/api/integrations/integration_base_api.dart';
import 'package:mobile/core/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/exceptions/post_unsynced_exception.dart';
import 'package:mobile/core/repository/tasks_repository.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:models/doc/doc.dart';
import 'package:models/integrations/gmail.dart';
import 'package:models/task/task.dart';

import '../exceptions/api_exception.dart';

class SyncIntegrationService {
  final SentryService _sentryService = locator<SentryService>();
  final TaskApi _taskApi = locator<TaskApi>();
  final TasksRepository _taskRpository = locator<TasksRepository>();

  final IIntegrationBaseApi integrationApi;

  SyncIntegrationService({required this.integrationApi});

  Future<DateTime?> start(DateTime? lastSyncAt, {required Map<String, dynamic>? params}) async {
    addBreadcrumb("${integrationApi.runtimeType} start syncing");

    List<GmailMessage> messages = (await integrationApi.getItems()) as List<GmailMessage>;

    DocsFromGmailDataModel docsFromGmailDataModel = DocsFromGmailDataModel(
      messages: messages,
      accountId: params?['accountId'],
      connectorId: params?['connectorId'],
      originAccountId: params?['originAccountId'],
      syncMode: params?['syncMode'] ?? 0,
      email: params?['email'],
    );

    List<Doc> docs = await compute(payloadFromGmailData, docsFromGmailDataModel);

    List<Task> tasks = await _taskRpository.getAllDocs();

    List<Task> localGmailTasks = tasks.where((element) => element.doc?.value?.messageId != null).toList();

    List<String?> localMessageIds = localGmailTasks
        .where((element) => element.doc?.value?.messageId != null)
        .map((e) => e.doc?.value?.messageId)
        .toList();

    List<Doc> newTasks =
        docs.where((element) => localMessageIds.contains(element.messageId) == false).toList();

    if (docs.isEmpty) {
      return null;
    }

    addBreadcrumb("${integrationApi.runtimeType} posting to unsynced ${docs.length} items");
    if (newTasks.isNotEmpty) {
      try {
        List<dynamic> updated = await _taskApi
            .postUnsynced(unsynced: newTasks, customHeader: {"Akiflow-Connector-Sync": "gmail-sync v0.1.0"});

        if (newTasks.length != updated.length) {
          throw PostUnsyncedExcepotion(
            "${integrationApi.runtimeType} upserted ${newTasks.length} items, but ${updated.length} items were updated",
          );
        }

        addBreadcrumb("${integrationApi.runtimeType} posted to unsynced ${updated.length} items done");

        return DateTime.now();
      } catch (e) {
        throw ApiException({"message": "Server Error", "errors": []});
      }
    }
  }

  void addBreadcrumb(String message) {
    _sentryService.addBreadcrumb(category: "sync", message: message);
  }
}
