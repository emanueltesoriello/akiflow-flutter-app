import 'package:intercom_flutter/intercom_flutter.dart';

class IntercomService {

  void authenticate(String? email) async {
    await Intercom.instance.loginIdentifiedUser(email: email);
    Intercom.instance.setInAppMessagesVisibility(IntercomVisibility.gone);
  }
}
