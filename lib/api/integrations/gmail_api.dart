import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api/integrations/integration_base_api.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_import_task_modal.dart';
import 'package:models/account/account_token.dart';
import 'package:uuid/uuid.dart';

class GmailMessageMetadata {
  final String id;
  final String threadId;

  GmailMessageMetadata(this.id, this.threadId);
}

class GmailMessagesAndThreads {
  final List<String> messagesId;
  final List<String> threadsId;

  GmailMessagesAndThreads(this.messagesId, this.threadsId);
}

class GmailMessage {
  final String? id;
  final String? threadId;
  final String? internalDate;
  final String? subject;
  final String? from;
  final String? messageId;

  GmailMessage({
    this.id,
    this.threadId,
    this.internalDate,
    this.subject,
    this.from,
    this.messageId,
  });

  factory GmailMessage.fromMap(Map<String, dynamic> json) {
    return GmailMessage(
      id: json['id'] as String?,
      threadId: json['threadId'] as String?,
      internalDate: json['internalDate'] as String?,
      subject: json['subject'] as String?,
      from: json['from'] as String?,
      messageId: json['messageId'] as String?,
    );
  }
}

class GmailApi implements IIntegrationBaseApi {
  static const String authEndpoint = 'https://www.googleapis.com/oauth2/v1';
  static const String endpoint = 'https://www.googleapis.com/gmail/v1';
  static const String endpointBatch = 'https://www.googleapis.com/batch/gmail/v1';

  final AccountToken accountToken;

  GmailApi(this.accountToken);

  GmailSyncMode get gmailSyncMode =>
      accountToken.account!.details?['syncMode'] == 1 ? GmailSyncMode.useAkiflowLabel : GmailSyncMode.useStarToImport;

  @override
  Future<List<GmailMessage>> getItems() async {
    // TODO refresh token if expired

    // TODO create Akiflow label if not exists

    // this.syncMode = ((yield AccountsRepository.instance.getAccountByAccountId(this.accountData.accountId))?.details || {}).syncMode
    // if (this.syncMode === GmailConnector.syncModes.akiflowLabel) {
    //   yield this.createAkiflowLabelIfNotExists(signal)
    // }

    List<GmailMessageMetadata> messagesMetadata = await messagesId();

    GmailMessagesAndThreads gmailMessagesAndThreads = getMessageAndThreadIdsFromMetadata(messagesMetadata);

    List<GmailMessage> singleMessageContents = await getSingleMessageContents(gmailMessagesAndThreads.messagesId);

    List<GmailMessage> threadMessageContents = await getThreadMessageContents(gmailMessagesAndThreads.threadsId);

    List<GmailMessage> allMessageContents = [...singleMessageContents, ...threadMessageContents];

    return allMessageContents;
  }

  Future<List<GmailMessageMetadata>> messagesId() async {
    List<GmailMessageMetadata> messagesId = [];
    String? nextPageToken;

    do {
      Uri urlWithQueryParameters = Uri.parse('$endpoint/users/${accountToken.account!.identifier}/messages');

      Map<String, dynamic> queryParameters = {
        "pageToken": nextPageToken,
        "q": gmailSyncMode == GmailSyncMode.useAkiflowLabel ? "label:akiflow" : "is:starred",
      };

      urlWithQueryParameters = urlWithQueryParameters.replace(queryParameters: queryParameters);

      final response = await http.get(urlWithQueryParameters, headers: {
        'Authorization': 'Bearer ${accountToken.accessToken}',
      });

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      nextPageToken = data['nextPageToken'];

      if (data['messages']?.length != null) {
        List<GmailMessageMetadata> messageMetadata = data['messages']
            .map<GmailMessageMetadata>((message) => GmailMessageMetadata(message['id'], message['threadId']))
            .toList()
            .cast<GmailMessageMetadata>();

        messagesId.addAll(messageMetadata);
      } else if (data.containsKey("error") && data['error'] != null) {
        throw Exception("error ${data['error']}");
      }
    } while (nextPageToken != null);

    return messagesId;
  }

  GmailMessagesAndThreads getMessageAndThreadIdsFromMetadata(List<GmailMessageMetadata> messagesMetadata) {
    List<String> messageIds = [];
    List<String> threadIds = [];

    bool shouldUseThreadId = gmailSyncMode == GmailSyncMode.useAkiflowLabel;

    if (shouldUseThreadId) {
      for (GmailMessageMetadata messageMetadata in messagesMetadata) {
        GmailMessageMetadata? originalThreadMessageMetadata =
            messagesMetadata.firstWhere((msgMetadata) => msgMetadata.id == messageMetadata.threadId);

        if (!messageIds.contains(originalThreadMessageMetadata.threadId)) {
          // we found original message for this thread, we use its threadId as message id
          messageIds.add(originalThreadMessageMetadata.threadId);
        } else if (!threadIds.contains(messageMetadata.threadId)) {
          // we don't have original message for this thread, queue threadIds for fetching
          threadIds.add(messageMetadata.threadId);
        }
      }
    } else {
      messageIds = messagesMetadata.map((msgMetadata) => msgMetadata.id).toList();
    }

    return GmailMessagesAndThreads(messageIds, threadIds);
  }

  Future<List<GmailMessage>> getSingleMessageContents(List<String> messageIds) async {
    List<GmailMessage> messagePages = [];
    while (messageIds.isNotEmpty) {
      List<String> messageIdsChunk;

      if (messageIds.length > 100) {
        messageIdsChunk = messageIds.sublist(0, 100);
        messageIds = messageIds.sublist(100);
      } else {
        messageIdsChunk = messageIds;
        messageIds = [];
      }

      String boundary = 'batch_${const Uuid().v4()}';

      String batchRequestString = buildGetMessageBatchRequestString(boundary, messageIdsChunk);

      final batchResult = await http.post(
        Uri.parse(endpointBatch),
        headers: {
          'Authorization': 'Bearer ${accountToken.accessToken}',
          'Content-Type': 'multipart/mixed; boundary=$boundary'
        },
        body: batchRequestString,
      );

      List<Map<String, dynamic>> messagesBatch = parseBatchResults(batchResult);

      List<GmailMessage> messagePage = [];
      for (Map<String, dynamic> message in messagesBatch) {
        GmailMessage? messageContent = getMessageContentFromMessageResult(message);
        if (messageContent != null) {
          messagePage.add(messageContent);
        }
      }
      messagePages.addAll(messagePage);
    }

    return messagePages;
  }

  Future<List<GmailMessage>> getThreadMessageContents(List<String> threadIds) async {
    List<GmailMessage> messagePages = [];
    while (threadIds.isNotEmpty) {
      List<String> threadIdsChunk;

      if (threadIds.length > 100) {
        threadIdsChunk = threadIds.sublist(0, 100);
        threadIds = threadIds.sublist(100);
      } else {
        threadIdsChunk = threadIds;
        threadIds = [];
      }

      String boundary = 'batch_${const Uuid().v4()}';

      String batchRequestString = buildGetMessageBatchRequestString(boundary, threadIdsChunk);

      final batchResult = await http.post(
        Uri.parse(endpointBatch),
        headers: {
          'Authorization': 'Bearer ${accountToken.accessToken}',
          'Content-Type': 'multipart/mixed; boundary=$boundary'
        },
        body: batchRequestString,
      );

      List<Map<String, dynamic>> threadsBatch = parseBatchResults(batchResult);

      List<GmailMessage> threadPage = [];
      for (dynamic thread in threadsBatch) {
        List<Map<String, dynamic>> threadMessages = (thread['messages'] ?? []).filter(
            (Map<String, dynamic> messageResult) =>
                !(messageResult['labelIds'] ?? []).contains('TRASH') &&
                !(messageResult['labelIds'] ?? []).any((element) => element.contains('SPAM')));
        if (threadMessages.isNotEmpty) {
          Map<String, dynamic> firstThreadMessage = threadMessages[0];
          GmailMessage? messageContent = getMessageContentFromMessageResult(firstThreadMessage);
          if (messageContent != null) {
            messagePages.add(messageContent);
          }
        }
      }
      messagePages.addAll(threadPage);
    }
    return messagePages;
  }

  GmailMessage? getMessageContentFromMessageResult(Map<String, dynamic> messageResult) {
    if (messageResult['error'] != null) {
      print(messageResult['error']);
      return null;
    }

    Map<String, dynamic>? payload = messageResult['payload'];
    String? subject = payload?['headers'].firstWhere((header) => header?['name'] == 'Subject')?['value'];
    String? from = payload?['headers'].firstWhere((header) => header?['name'] == 'From')?['value'];

    return GmailMessage(
      id: messageResult['id'],
      threadId: messageResult['threadId'],
      internalDate: messageResult['internalDate'],
      subject: subject,
      from: from,
      messageId: messageResult['id'],
    );
  }

  String buildGetMessageBatchRequestString(String boundary, List<String> messageIds) {
    List<String> batchRequests = [];

    for (String messageId in messageIds) {
      batchRequests.add("""
--$boundary
Content-Type: application/json
Content-ID: gmail-$messageId
Accept: application/json

GET /gmail/v1/users/${accountToken.account?.identifier}/messages/$messageId?format=metadata&metadataHeaders=subject&metadataHeaders=From

{}
""");
    }

    return "${batchRequests.join('\n')}\n\n--$boundary--";
  }

  List<Map<String, dynamic>> parseBatchResults(Response axiosResult) {
    List<Map<String, dynamic>> items = [];

    String boundary = getBatchSeparator(axiosResult);

    String responseBody = axiosResult.body;

    List<String> responseLines = responseBody.split('--$boundary');

    for (var response in responseLines) {
      int startJson = response.indexOf('{');
      int endJson = response.lastIndexOf('}');

      if (startJson < 0 || endJson < 0) {
        continue;
      }

      String responseJson = response.substring(startJson, endJson + 1);

      Map<String, dynamic> item = jsonDecode(responseJson);
      items.add(item);
    }

    return items;
  }

  String getBatchSeparator(axiosResult) {
    if (axiosResult.headers['content-type'] == null) {
      return '';
    }
    List<String> components = axiosResult.headers['content-type'].split(';');
    String boundary = components.firstWhere((component) => component.trim().startsWith('boundary='));
    boundary = boundary.replaceAll('boundary=', '').trim();
    return boundary;
  }
}
