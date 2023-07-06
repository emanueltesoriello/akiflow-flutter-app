import 'package:mobile/src/base/models/mark_as_done_type.dart';
import 'package:models/account/account.dart';
import 'package:models/task/task.dart';

class GmailDocAction {
  MarkAsDoneType markAsDoneType;
  Task task;
  Account account;

  GmailDocAction({required this.markAsDoneType, required this.task, required this.account});
}
