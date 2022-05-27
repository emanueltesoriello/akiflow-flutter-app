import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api/integrations/integration_base_api.dart';
import 'package:mobile/features/settings/ui/gmail/gmail_import_task_modal.dart';
import 'package:models/account/account.dart';
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

class GmailApi implements IIntegrationBaseApi {
  static const String authEndpoint = 'https://www.googleapis.com/oauth2/v1';
  static const String endpoint = 'https://www.googleapis.com/gmail/v1';
  static const String endpointBatch = 'https://www.googleapis.com/batch/gmail/v1';

  String? accessToken;
  Account? account;

  void setAccessToken(String? accessToken) {
    this.accessToken = accessToken;
  }

  void setAccount(Account? account) {
    this.account = account;
  }

  Future<Map<String, dynamic>> accountData() async {
    Response response = await http.get(Uri.parse("$authEndpoint/userinfo?alt=json"), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  GmailSyncMode get gmailSyncMode =>
      account?.details?['syncMode'] == 1 ? GmailSyncMode.useAkiflowLabel : GmailSyncMode.useStarToImport;

  @override
  Future<List<dynamic>> getItems() async {
    // TODO refresh token if expired

    // TODO create Akiflow label if not exists

    // this.syncMode = ((yield AccountsRepository.instance.getAccountByAccountId(this.accountData.accountId))?.details || {}).syncMode
    // if (this.syncMode === GmailConnector.syncModes.akiflowLabel) {
    //   yield this.createAkiflowLabelIfNotExists(signal)
    // }

    List<GmailMessageMetadata> messagesMetadata = await messagesId();
    print("1 messagesMetadata: ${messagesMetadata.length}");

    GmailMessagesAndThreads gmailMessagesAndThreads = getMessageAndThreadIdsFromMetadata(messagesMetadata);
    print("2 gmailMessagesAndThreads: ${gmailMessagesAndThreads.messagesId.length}");

    List<dynamic> singleMessageContents = await getSingleMessageContents(gmailMessagesAndThreads.messagesId);
    print("3 singleMessageContents: ${singleMessageContents.length}");

    List<dynamic> threadMessageContents = await getThreadMessageContents(gmailMessagesAndThreads.threadsId);
    print("4 threadMessageContents: ${threadMessageContents.length}");

    return [...singleMessageContents, ...threadMessageContents];
  }

  Future<List<GmailMessageMetadata>> messagesId() async {
    List<GmailMessageMetadata> messagesId = [];
    String? nextPageToken;

    do {
      Uri urlWithQueryParameters = Uri.parse('$endpoint/users/${account!.identifier}/messages');

      Map<String, dynamic> queryParameters = {
        "pageToken": nextPageToken,
        "q": gmailSyncMode == GmailSyncMode.useAkiflowLabel ? "label:akiflow" : "is:starred",
      };

      urlWithQueryParameters = urlWithQueryParameters.replace(queryParameters: queryParameters);

      final response = await http.get(urlWithQueryParameters, headers: {
        'Authorization': 'Bearer $accessToken',
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

  Future<List<Map<String, dynamic>>> getSingleMessageContents(List<String> messageIds) async {
    List<Map<String, dynamic>> messagePages = [];
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
        headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'multipart/mixed; boundary=$boundary'},
        body: batchRequestString,
      );

      List<Map<String, dynamic>> messagesBatch = parseBatchResults(batchResult);

      List<Map<String, dynamic>> messagePage = [];
      for (Map<String, dynamic> message in messagesBatch) {
        Map<String, dynamic>? messageContent = getMessageContentFromMessageResult(message);
        if (messageContent != null) {
          messagePage.add(messageContent);
        }
      }
      messagePages.addAll(messagePage);
    }

    return messagePages;
  }

  Future<List<Map<String, dynamic>>> getThreadMessageContents(List<String> threadIds) async {
    List<Map<String, dynamic>> messagePages = [];
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
        headers: {'Authorization': 'Bearer $accessToken', 'Content-Type': 'multipart/mixed; boundary=$boundary'},
        body: batchRequestString,
      );

      List<Map<String, dynamic>> threadsBatch = parseBatchResults(batchResult);

      List<Map<String, dynamic>> threadPage = [];
      for (dynamic thread in threadsBatch) {
        List<Map<String, dynamic>> threadMessages = (thread['messages'] ?? []).filter(
            (Map<String, dynamic> messageResult) =>
                !(messageResult['labelIds'] ?? []).contains('TRASH') &&
                !(messageResult['labelIds'] ?? []).any((element) => element.contains('SPAM')));
        if (threadMessages.isNotEmpty) {
          Map<String, dynamic> firstThreadMessage = threadMessages[0];
          Map<String, dynamic>? messageContent = getMessageContentFromMessageResult(firstThreadMessage);
          if (messageContent != null) {
            messagePages.add(messageContent);
          }
        }
      }
      messagePages.addAll(threadPage);
    }
    return messagePages;
  }

  Map<String, dynamic>? getMessageContentFromMessageResult(Map<String, dynamic> messageResult) {
    if (messageResult['error'] != null) {
      print(messageResult['error']);
      return null;
    }

    Map<String, dynamic>? payload = messageResult['payload'];
    String? subject = payload?['headers'].firstWhere((header) => header?['name'] == 'Subject')?['value'];
    String? from = payload?['headers'].firstWhere((header) => header?['name'] == 'From')?['value'];

    return Map<String, dynamic>.from({
      "id": messageResult['id'],
      "threadId": messageResult['threadId'],
      "internalDate": messageResult['internalDate'],
      "subject": subject,
      "from": from,
      "messageId": messageResult['id'],
    });
  }

  String buildGetMessageBatchRequestString(String boundary, List<String> messageIds) {
    List<String> batchRequests = [];

    for (String messageId in messageIds) {
      batchRequests.add("""
--$boundary
Content-Type: application/json
Content-ID: gmail-$messageId
Accept: application/json

GET /gmail/v1/users/${account?.identifier}/messages/$messageId?format=metadata&metadataHeaders=subject&metadataHeaders=From

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
