import 'package:mobile/core/api/api.dart';
import 'package:mobile/core/config.dart';
import 'package:models/contact/contact.dart';

class ContactsApi extends ApiClient {
  ContactsApi({String? endpoint})
      : super(
          Uri.parse("${endpoint ?? Config.endpoint}/v3/contacts"),
          fromMap: Contact.fromMap,
        );
}
