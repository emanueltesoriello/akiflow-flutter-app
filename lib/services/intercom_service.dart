import 'package:intercom_flutter/intercom_flutter.dart';

class IntercomService {

  void authenticate(String? email) async {
    await Intercom.instance.initialize('hqlby49q',
        iosApiKey: 'ios_sdk-c80c16999ffce9cb6988a6478b18de09a932c4ed',
        androidApiKey: 'android_sdk-02d22b9bbde45e6ca6419ac5af05878bae1a74c6');
    //TODO: configure once user_hash is returned 
    // await Intercom.instance.setUserHash(userHash);
    await Intercom.instance.loginIdentifiedUser(email: email);
    Intercom.instance.setInAppMessagesVisibility(IntercomVisibility.gone);
  }
}
