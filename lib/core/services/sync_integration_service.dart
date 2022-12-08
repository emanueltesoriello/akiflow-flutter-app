import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/core/api/docs_api.dart';
import 'package:mobile/core/api/integrations/integration_base_api.dart';
import 'package:mobile/core/api/task_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/core/exceptions/post_unsynced_exception.dart';
import 'package:mobile/core/repository/docs_repository.dart';
import 'package:mobile/core/services/sentry_service.dart';
import 'package:mobile/common/utils/converters_isolate.dart';
import 'package:models/doc/doc.dart';
import 'package:models/integrations/gmail.dart';

import '../exceptions/api_exception.dart';

class SyncIntegrationService {
  final SentryService _sentryService = locator<SentryService>();
  final TaskApi _taskApi = locator<TaskApi>();
  final DocsRepository _docsRepository = locator<DocsRepository>();

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

    List<Doc> docs = await compute(docsFromGmailData, docsFromGmailDataModel);

    if (docs.isEmpty) {
      return null;
    }

    List<Doc> localDocs = await getExistingDocs(docs);

    addBreadcrumb("${integrationApi.runtimeType} localDocs length: ${localDocs.length}");

    List<Doc> unsynced =
        await compute(prepareDocsForRemote, PrepareDocForRemoteModel(remoteItems: docs, existingItems: localDocs));

    addBreadcrumb("${integrationApi.runtimeType} posting to unsynced ${unsynced.length} items");
    try {
      List<dynamic> updated = await _taskApi.postUnsynced(unsynced: unsynced);

      if (unsynced.length != updated.length) {
        throw PostUnsyncedExcepotion(
          "${integrationApi.runtimeType} upserted ${unsynced.length} items, but ${updated.length} items were updated",
        );
      }

      addBreadcrumb("${integrationApi.runtimeType} posted to unsynced ${updated.length} items done");

      return DateTime.now();
    } catch (e) {
      throw ApiException({"message": "Server Error", "errors": []});
    }
  }

  Future<List<Doc>> getExistingDocs(List<Doc> remoteItems) async {
    addBreadcrumb("${integrationApi.runtimeType} remoteItems length: ${remoteItems.length}");

    List<Doc> existingModels = [];

    for (Doc remoteItem in remoteItems) {
      Doc? localItem = await _docsRepository.getDocByConnectorIdAndOriginId(
        connectorId: remoteItem.connectorId ?? '',
        originId: remoteItem.originId ?? '',
      );

      if (localItem != null) {
        existingModels.add(localItem);
      }
    }

    return existingModels;
  }

  void addBreadcrumb(String message) {
    _sentryService.addBreadcrumb(category: "sync", message: message);
  }
}
