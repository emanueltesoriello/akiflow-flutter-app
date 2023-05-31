import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class TodoistDoc extends DocBase {
  late final String? title;
  final String? url;
  final String? localUrl;
  final String? dueDate;
  final int? dueDateTime;
  final String? projectId;
  final String? projectName;
  final bool? isRecurring;
  final String? string;
  final String? timezone;
  final String? lang;
  final String? parentId;
  final String? parentTaskTitle;

  TodoistDoc({
    this.url,
    this.localUrl,
    this.dueDate,
    this.dueDateTime,
    this.projectId,
    this.projectName,
    this.isRecurring,
    this.string,
    this.timezone,
    this.lang,
    this.parentId,
    this.parentTaskTitle,
  });

  factory TodoistDoc.fromMap(Map<String, dynamic> json) => TodoistDoc(
        url: json['url'] as String?,
        localUrl: json['local_url'] as String?,
        dueDate: json['due_date'] as String?,
        dueDateTime: json['due_date_time'] as int?,
        projectId: json['project_id'] as String?,
        projectName: json['project_name'] as String?,
        isRecurring: json['is_recurring'] as bool?,
        string: json['string'] as String?,
        timezone: json['timezone'] as String?,
        lang: json['lang'] as String?,
        parentId: json['parent_id'] as String?,
        parentTaskTitle: json['parent_task_title'] as String?,
      );

  setTitle(String? title) {
    this.title = title;
  }

  @override
  String get getSummary {
    return parentTaskTitle ?? projectName ?? url ?? '';
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

  @override
  List<Object?> get props {
    return [
      title,
      url,
      localUrl,
      projectId,
      projectName,
      dueDate,
      dueDateTime,
      isRecurring,
      string,
      timezone,
      lang,
      parentId,
      parentTaskTitle,
    ];
  }
}
