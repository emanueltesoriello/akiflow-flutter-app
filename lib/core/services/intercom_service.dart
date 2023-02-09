/*import 'dart:io';

import 'package:intercom_flutter/intercom_flutter.dart';

class IntercomService {
  final Intercom _intercom = Intercom.instance;

  Future<void> authenticate({
    String? email,
    String? intercomHashAndroid,
    String? intercomHashIos,
  }) async {
    if (Platform.isIOS) {
      await _intercom.setUserHash(intercomHashIos!);
    } else if (Platform.isAndroid) {
      await _intercom.setUserHash(intercomHashAndroid!);
    }
    await _intercom.loginIdentifiedUser(email: email);
    _intercom.setInAppMessagesVisibility(IntercomVisibility.gone);
  }
}*/
