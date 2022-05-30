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
import 'package:models/integrations/gmail.dart';

class SyncIntegrationService {
  final SentryService _sentryService = locator<SentryService>();
  final DocsApi _docsApi = locator<DocsApi>();
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
