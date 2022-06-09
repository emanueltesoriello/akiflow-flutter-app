import 'package:mobile/features/settings/ui/gmail/gmail_mark_done_modal.dart';
import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class GmailDocAction {
  GmailMarkAsDoneType markAsDoneType;
  Task task;
  Doc doc;
  Account account;

  GmailDocAction({required this.markAsDoneType, required this.task, required this.doc, required this.account});
}
