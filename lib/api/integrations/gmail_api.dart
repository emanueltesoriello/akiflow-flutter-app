import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:http/http.dart';
import 'package:mobile/api/integrations/gmail_client.dart';
import 'package:mobile/api/integrations/integration_base_api.dart';
import 'package:mobile/exceptions/integrations/gmail.dart';
import 'package:models/account/account.dart';
import 'package:models/account/account_token.dart';
import 'package:models/doc/doc.dart';
import 'package:models/extensions/account_ext.dart';
import 'package:models/integrations/gmail.dart';
import 'package:uuid/uuid.dart';

class GmailApi implements IIntegrationBaseApi {
  static const String authEndpoint = 'https://www.googleapis.com/oauth2/v1';
  static const String endpoint = 'https://www.googleapis.com/gmail/v1';
  static const String endpointBatch = 'https://www.googleapis.com/batch/gmail/v1';

  late final GmailClient _client;

  final Account account;
  final Function(String labelId) saveAkiflowLabelId;

  GmailApi(this.account, {required AccountToken accountToken, required this.saveAkiflowLabelId}) {
    _client = GmailClient(accountToken, account: account);
  }

  @override
  Future<List<GmailMessage>> getItems() async {
    if (account.gmailSyncMode == GmailSyncMode.useAkiflowLabel) {
      await createAkiflowLabelIfNotExists();
    }

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
      Uri urlWithQueryParameters = Uri.parse('$endpoint/users/${account.identifier}/messages');

      Map<String, dynamic> queryParameters = {
        "pageToken": nextPageToken,
        "q": account.gmailSyncMode == GmailSyncMode.useAkiflowLabel ? "label:akiflow" : "is:starred",
      };

      urlWithQueryParameters = urlWithQueryParameters.replace(queryParameters: queryParameters);

      print('urlWithQueryParameters: $urlWithQueryParameters');

      final response = await _client.get(urlWithQueryParameters, headers: {'Content-Type': 'application/json'});

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

    bool shouldUseThreadId = account.gmailSyncMode == GmailSyncMode.useAkiflowLabel;

    if (shouldUseThreadId) {
      for (GmailMessageMetadata messageMetadata in messagesMetadata) {
        GmailMessageMetadata? originalThreadMessageMetadata =
            messagesMetadata.firstWhereOrNull((msgMetadata) => msgMetadata.id == messageMetadata.threadId);

        if (originalThreadMessageMetadata != null && !messageIds.contains(originalThreadMessageMetadata.threadId)) {
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

      final batchResult = await _client.post(
        Uri.parse(endpointBatch),
        headers: {'Content-Type': 'multipart/mixed; boundary=$boundary'},
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

      String batchRequestString = buildGetThreadBatchRequestString(boundary, threadIdsChunk);

      Response batchResult = await _client.post(
        Uri.parse(endpointBatch),
        headers: {'Content-Type': 'multipart/mixed; boundary=$boundary'},
        body: batchRequestString,
      );

      List<Map<String, dynamic>> threadsBatch = parseBatchResults(batchResult);

      List<GmailMessage> threadPage = [];
      for (dynamic thread in threadsBatch) {
        List<dynamic>? messages = thread['messages'] as List<dynamic>?;

        List<dynamic> threadMessages = (messages ?? [])
            .where((messageResult) =>
                !messageResult?['labelIds']?.contains('TRASH') && !messageResult?['labelIds']?.contains('SPAM'))
            .toList();

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

GET /gmail/v1/users/${account.identifier}/messages/$messageId?format=metadata&metadataHeaders=subject&metadataHeaders=From

{}
""");
    }

    return "${batchRequests.join('\n')}\n\n--$boundary--";
  }

  String buildGetThreadBatchRequestString(String boundary, List<String> threadIds) {
    List<String> batchRequests = [];

    for (String threadId in threadIds) {
      batchRequests.add("""
--$boundary
Content-Type: application/json
Content-ID: gmail-$threadId
Accept: application/json

GET /gmail/v1/users/${account.identifier}/threads/$threadId?format=metadata&metadataHeaders=subject&metadataHeaders=From

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

  Future<void> createAkiflowLabelIfNotExists() async {
    Uri uri = Uri.parse('$endpoint/users/${account.identifier}/labels');

    Response result = await _client.get(uri, headers: {'Content-Type': 'application/json'});

    List<dynamic> currentLabels = jsonDecode(result.body)['labels'];

    var akiflowLabel = currentLabels.firstWhereOrNull((label) => label['name']?.toLowerCase() == 'akiflow');

    if (akiflowLabel?['id'] != null) {
      await saveAkiflowLabelId(akiflowLabel!['id']);
    } else {
      Uri uri = Uri.parse('$endpoint/users/${account.identifier}/labels');

      Map<String, dynamic> label = {
        "name": 'Akiflow',
        "labelListVisibility": 'labelHide',
        "messageListVisibility": 'show',
        "color": {"backgroundColor": '#8e63ce', "textColor": '#ffffff'}
      };

      Response result = await _client.post(uri, body: jsonEncode(label), headers: {'Content-Type': 'application/json'});

      await saveAkiflowLabelId(jsonDecode(result.body)?['id']);
    }
  }

  Future<void> unstar(Doc doc) async {
    Uri uri;

    if (account.gmailSyncMode == GmailSyncMode.useAkiflowLabel) {
      uri = Uri.parse("$endpoint/users/${account.identifier}/messages/${doc.originId}/modify");
    } else {
      uri = Uri.parse("$endpoint/users/${account.identifier}/messages/${doc.originId}/modify");
    }

    String? labelId = account.details?['akiflowLabelId'];

    Map<String, dynamic> requestBody = {
      "removeLabelIds": account.gmailSyncMode == GmailSyncMode.useAkiflowLabel ? [labelId] : ['STARRED']
    };

    Response response =
        await _client.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode(requestBody));

    Map<String, dynamic> data = jsonDecode(response.body);

    if (!data.containsKey("id") || data["id"] == null) {
      throw GmailUnstarException("Unstar failed for doc ${doc.originId} account ${account.identifier}",
          jsonEncode(requestBody), response.body);
    } else {
      print("Unstar successful for doc ${doc.originId} result id ${data['id']}");
    }
  }
}
