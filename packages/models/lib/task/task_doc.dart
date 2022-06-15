import 'package:equatable/equatable.dart';

class TaskDoc extends Equatable {
  final String? url;
  final String? localUrl;
  final String? dueDate;
  final int? dueDateTime;
  final String? projectName;
  final String? projectId;
  final bool? isRecurring;
  final String? string;
  final dynamic timezone;
  final String? lang;
  final String? parentId;
  final String? parentTaskTitle;

  const TaskDoc({
    required this.url,
    required this.localUrl,
    required this.dueDate,
    required this.dueDateTime,
    required this.projectName,
    required this.projectId,
    required this.isRecurring,
    required this.string,
    required this.timezone,
    required this.lang,
    required this.parentId,
    required this.parentTaskTitle,
  });

  TaskDoc copyWith({
    String? url,
    String? localUrl,
    String? dueDate,
    int? dueDateTime,
    String? projectName,
    String? projectId,
    bool? isRecurring,
    String? string,
    String? timezone,
    String? lang,
    String? parentId,
    String? parentTaskTitle,
  }) {
    return TaskDoc(
      url: url ?? this.url,
      localUrl: localUrl ?? this.localUrl,
      dueDate: dueDate ?? this.dueDate,
      dueDateTime: dueDateTime ?? this.dueDateTime,
      projectName: projectName ?? this.projectName,
      projectId: projectId ?? this.projectId,
      isRecurring: isRecurring ?? this.isRecurring,
      string: string ?? this.string,
      timezone: timezone ?? this.timezone,
      lang: lang ?? this.lang,
      parentId: parentId ?? this.parentId,
      parentTaskTitle: parentTaskTitle ?? this.parentTaskTitle,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'url': url,
      'local_url': localUrl,
      'due_date': dueDate,
      'due_date_time': dueDateTime,
      'project_name': projectName,
      'project_id': projectId,
      'is_recurring': isRecurring,
      'string': string,
      'timezone': timezone,
      'lang': lang,
      'parent_id': parentId,
      'parent_task_title': parentTaskTitle,
    };
  }

  factory TaskDoc.fromMap(Map<String, dynamic> map) {
    return TaskDoc(
      url: map['url'] as String?,
      localUrl: map['local_url'] as String?,
      dueDate: map['due_date'] as String?,
      dueDateTime: map['due_date_time'] as int?,
      projectName: map['project_name'] as String?,
      projectId: map['project_id'] as String?,
      isRecurring: map['is_recurring'] as bool?,
      string: map['string'] as String?,
      timezone: map['timezone'],
      lang: map['lang'] as String?,
      parentId: map['parent_id'] as String?,
      parentTaskTitle: map['parent_task_title'] as String?,
    );
  }

  @override
  List<Object?> get props {
    return [
      url,
      localUrl,
      dueDate,
      dueDateTime,
      projectName,
      projectId,
      isRecurring,
      string,
      timezone,
      lang,
      parentId,
      parentTaskTitle,
    ];
  }
}
