import 'package:mobile/src/base/models/gmail_mark_as_done_type.dart';
import 'package:models/account/account.dart';
import 'package:models/task/task.dart';

class GmailDocAction {
  GmailMarkAsDoneType markAsDoneType;
  Task task;
  Account account;

  GmailDocAction({required this.markAsDoneType, required this.task, required this.account});
}
