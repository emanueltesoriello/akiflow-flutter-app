import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mobile/api/docs_api.dart';
import 'package:mobile/api/integrations/integration_base_api.dart';
import 'package:mobile/core/locator.dart';
import 'package:mobile/exceptions/post_unsynced_exception.dart';
import 'package:mobile/repository/docs_repository.dart';
import 'package:mobile/services/sentry_service.dart';
import 'package:mobile/utils/converters_isolate.dart';
import 'package:models/doc/doc.dart';

class SyncIntegrationService {
  final SentryService _sentryService = locator<SentryService>();
  final DocsApi _docsApi = locator<DocsApi>();
  final DocsRepository _docsRepository = locator<DocsRepository>();

  final IIntegrationBaseApi integrationApi;

  SyncIntegrationService({required this.integrationApi});

  Future<DateTime?> start(DateTime? lastSyncAt, {required Map<String, dynamic>? params}) async {
    addBreadcrumb("${integrationApi.runtimeType} start syncing");

    List<dynamic> data = await integrationApi.getItems();

    DocsFromGmailDataModel docsFromGmailDataModel = DocsFromGmailDataModel(
      gmailData: data,
      accountId: params?['accountId'],
      connectorId: params?['connectorId'],
      originAccountId: params?['originAccountId'],
      syncMode: params?['syncMode'] ?? 0,
      email: params?['email'],
    );

    List<Doc> docs = await compute(docsFromGmailData, docsFromGmailDataModel);

    if (docs.isEmpty) {
      return DateTime.now();
    }

    List<Doc> localDocs = await getExistingDocs(docs);

    addBreadcrumb("${integrationApi.runtimeType} localDocs length: ${localDocs.length}");

    List<Doc> unsynced =
        await compute(prepareDocsForRemote, PrepareDocForRemoteModel(remoteItems: docs, existingItems: localDocs));

    addBreadcrumb("${integrationApi.runtimeType} posting to unsynced ${unsynced.length} items");

    List<dynamic> updated = await _docsApi.postUnsynced(unsynced: unsynced);

    if (unsynced.length != updated.length) {
      throw PostUnsyncedExcepotion(
        "${integrationApi.runtimeType} upserted ${unsynced.length} items, but ${updated.length} items were updated",
      );
    }

    addBreadcrumb("${integrationApi.runtimeType} posted to unsynced ${updated.length} items done");

    return DateTime.now();
  }

  Future<List<Doc>> getExistingDocs(List<Doc> remoteItems) async {
    List<dynamic> localIds = remoteItems.map((remoteItem) => remoteItem.id).toList();

    addBreadcrumb("${integrationApi.runtimeType} localIds length: ${localIds.length}");

    List<Doc> existingModels = [];

    int sqlMaxVariableNumber = 999;

    if (localIds.length > sqlMaxVariableNumber) {
      List<List<dynamic>> chunks = [];

      for (var i = 0; i < localIds.length; i += sqlMaxVariableNumber) {
        List<dynamic> sublistWithMaxVariables = localIds.sublist(
            i, i + sqlMaxVariableNumber > localIds.length ? localIds.length : i + sqlMaxVariableNumber);
        chunks.add(sublistWithMaxVariables);
      }

      for (var chunk in chunks) {
        List<Doc> existingModelsChunk = await _docsRepository.getByIds(chunk);
        existingModels.addAll(existingModelsChunk);
      }
    } else {
      existingModels = await _docsRepository.getByIds(localIds);
    }

    return existingModels;
  }

  void addBreadcrumb(String message) {
    _sentryService.addBreadcrumb(category: "sync", message: message);
  }
}
