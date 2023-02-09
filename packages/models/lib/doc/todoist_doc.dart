import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class TodoistDoc extends Doc implements DocBase {
  final String? title;
  TodoistDoc(Doc doc, this.title)
      : super(
            url: doc.url,
            localUrl: doc.localUrl,
            dueDate: doc.dueDate,
            dueDateTime: doc.dueDateTime,
            projectId: doc.projectId,
            projectName: doc.projectName,
            isRecurring: doc.isRecurring,
            string: doc.string,
            timezone: doc.timezone,
            lang: doc.lang,
            parentId: doc.parentId,
            parentTaskTitle: doc.parentTaskTitle);

  @override
  String get getSummary {
    return parentTaskTitle ?? projectName ?? super.getSummary;
  }

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];

    if (projectName != null && projectName!.isNotEmpty) {
      summaryPieces.add(projectName);
    }

    if (title != null && title != '') {
      summaryPieces.add(title);
    }

    if (title != null && title!.isNotEmpty) {
      summaryPieces.add(title);
    }

    return summaryPieces.join(' - ');
  }
}
