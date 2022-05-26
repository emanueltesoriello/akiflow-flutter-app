import 'package:mobile/api/integrations/integration_base_api.dart';

class GmailApi implements IIntegrationBaseApi {
  @override
  Future<List<dynamic>> getItems() async {
    // TODO List<Doc> gmailData = get from gmail api

    var gmailData = [
      {
        "messageId": "1",
        "title": "test1",
      }
    ];

    return gmailData;
  }
}
