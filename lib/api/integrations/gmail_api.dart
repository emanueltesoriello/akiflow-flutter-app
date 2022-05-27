import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:mobile/api/integrations/integration_base_api.dart';

class GmailApi implements IIntegrationBaseApi {
  @override
  Future<List<dynamic>> getItems() async {
    // this.syncMode = ((yield AccountsRepository.instance.getAccountByAccountId(this.accountData.accountId))?.details || {}).syncMode
    // if (this.syncMode === GmailConnector.syncModes.akiflowLabel) {
    //   yield this.createAkiflowLabelIfNotExists(signal)
    // }

    // const messagesMetadata: IGmailMessageMetadata[] = yield this.getMessagesMetadata(signal, this.syncMode)
    // const { messageIds, threadIds } = this.getMessageAndThreadIdsFromMetadata(messagesMetadata)
    // const singleMessageContents = yield this.getSingleMessageContents(signal, messageIds)
    // const threadMessageContents = yield this.getThreadMessageContents(signal, threadIds)

    // const messageContents = singleMessageContents.concat(threadMessageContents)

    // TODO List<Doc> gmailData = get from gmail api

    var gmailData = [
      {
        "messageId": "1",
        "title": "test1",
      }
    ];

    return gmailData;
  }

  Future<Map<String, dynamic>> accountData(String accessToken) async {
    Response response = await http.get(Uri.parse('https://www.googleapis.com/oauth2/v1/userinfo?alt=json'), headers: {
      'Authorization': 'Bearer $accessToken',
    });

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
