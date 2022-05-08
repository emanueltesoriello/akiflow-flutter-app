// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:models/base.dart';
import 'package:models/date_parse.dart';
import 'package:models/nullable.dart';

class Task extends Equatable implements Base {
  final String? id;
  final String? title;
  final DateTime? date;
  final String? description;
  final int? duration;
  final int? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final bool? done;
  final DateTime? doneAt;
  final DateTime? datetime;
  final DateTime? readAt;
  final DateTime? globalUpdatedAt;
  final DateTime? globalCreatedAt;
  final DateTime? activationDatetime;
  final DateTime? dueDate;
  final DateTime? remoteUpdatedAt;
  final String? recurringId;
  final int? priority;
  final String? listId;
  final String? sectionId;
  final String? origin;
  final int? sorting;
  final int? sortingLabel;
  final bool? selected;
  final int? dailyGoal;
  final List<String>? links;
  final List<String>? recurrence;

  const Task({
    this.id,
    this.title,
    this.date,
    this.description,
    this.duration,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.done,
    this.doneAt,
    this.datetime,
    this.readAt,
    this.globalUpdatedAt,
    this.globalCreatedAt,
    this.activationDatetime,
    this.dueDate,
    this.remoteUpdatedAt,
    this.recurringId,
    this.priority,
    this.listId,
    this.sectionId,
    this.origin,
    this.sorting,
    this.sortingLabel,
    this.selected,
    this.dailyGoal,
    this.links,
    this.recurrence,
  });

  Task copyWith({
    String? id,
    String? title,
    Nullable<DateTime?>? date,
    String? description,
    Nullable<int?>? duration,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool? done,
    Nullable<DateTime?>? doneAt,
    DateTime? datetime,
    DateTime? readAt,
    DateTime? globalUpdatedAt,
    DateTime? globalCreatedAt,
    DateTime? activationDatetime,
    DateTime? dueDate,
    DateTime? remoteUpdatedAt,
    String? recurringId,
    int? priority,
    String? listId,
    String? sectionId,
    String? origin,
    int? sorting,
    int? sortingLabel,
    bool? selected,
    int? dailyGoal,
    List<String>? links,
    List<String>? recurrence,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date == null ? this.date : date.value,
      description: description ?? this.description,
      duration: duration == null ? this.duration : duration.value,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      done: done ?? this.done,
      doneAt: doneAt == null ? this.doneAt : doneAt.value,
      datetime: datetime ?? this.datetime,
      readAt: readAt ?? this.readAt,
      globalUpdatedAt: globalUpdatedAt ?? this.globalUpdatedAt,
      globalCreatedAt: globalCreatedAt ?? this.globalCreatedAt,
      activationDatetime: activationDatetime ?? this.activationDatetime,
      dueDate: dueDate ?? this.dueDate,
      remoteUpdatedAt: remoteUpdatedAt ?? this.remoteUpdatedAt,
      recurringId: recurringId ?? this.recurringId,
      priority: priority ?? this.priority,
      listId: listId ?? this.listId,
      sectionId: sectionId ?? this.sectionId,
      origin: origin ?? this.origin,
      sorting: sorting ?? this.sorting,
      sortingLabel: sortingLabel ?? this.sortingLabel,
      selected: selected ?? this.selected,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      links: links ?? this.links,
      recurrence: recurrence ?? this.recurrence,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'date': date != null ? DateFormat('yyyy-MM-dd').format(date!) : null,
      'description': description,
      'duration': duration,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'deleted_at': deletedAt?.toIso8601String(),
      'done': done,
      'done_at': doneAt?.toIso8601String(),
      'datetime': datetime?.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'global_updated_at': globalUpdatedAt?.toIso8601String(),
      'global_created_at': globalCreatedAt?.toIso8601String(),
      'activation_datetime': activationDatetime?.toIso8601String(),
      'due_date':
          dueDate != null ? DateFormat('yyyy-MM-dd').format(dueDate!) : null,
      'remote_updated_at': remoteUpdatedAt?.toIso8601String(),
      'recurring_id': recurringId,
      'priority': priority,
      'listId': listId,
      'section_id': sectionId,
      'origin': origin,
      'sorting': sorting,
      'sorting_label': sortingLabel,
      'selected': selected,
      'dailyGoal': dailyGoal,
      'links': links,
      'recurrence': recurrence,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] != null ? map['id'] as String : null,
      title: map['title'] != null ? map['title'] as String : null,
      date: map['date'] != null ? DateParse.parse(map['date']) : null,
      description:
          map['description'] != null ? map['description'] as String : null,
      duration: map['duration'] != null ? map['duration'] as int : null,
      status: map['status'] != null ? map['status'] as int : null,
      createdAt:
          map['created_at'] != null ? DateParse.parse(map['created_at']) : null,
      updatedAt:
          map['updated_at'] != null ? DateParse.parse(map['updated_at']) : null,
      deletedAt:
          map['deleted_at'] != null ? DateParse.parse(map['deleted_at']) : null,
      done: map['done'] != null ? map['done'] as bool : null,
      doneAt: map['done_at'] != null ? DateParse.parse(map['done_t']) : null,
      datetime:
          map['datetime'] != null ? DateParse.parse(map['datetime']) : null,
      readAt: map['read_at'] != null ? DateParse.parse(map['read_at']) : null,
      globalCreatedAt: map['global_created_at'] != null
          ? DateParse.parse(map['global_created_at'])
          : null,
      globalUpdatedAt: map['global_updated_at'] != null
          ? DateParse.parse(map['global_updated_at'])
          : null,
      activationDatetime: map['activation_datetime'] != null
          ? DateParse.parse(map['activation_datetime'])
          : null,
      dueDate:
          map['due_date'] != null ? DateParse.parse(map['due_date']) : null,
      remoteUpdatedAt: map['remote_updated_at'] != null
          ? DateParse.parse(map['remote_updated_at'])
          : null,
      recurringId:
          map['recurring_id'] != null ? map['recurring_id'] as String : null,
      priority: map['priority'] != null ? map['priority'] as int : null,
      listId: map['listId'] != null ? map['listId'] as String : null,
      sectionId: map['section_id'] != null ? map['section_id'] as String : null,
      origin: map['origin'] != null ? map['origin'] as String : null,
      sorting: map['sorting'] != null ? map['sorting'] as int : null,
      sortingLabel:
          map['sorting_label'] != null ? map['sorting_label'] as int : null,
      selected: map['selected'] != null ? map['selected'] as bool : null,
      dailyGoal: map['dailyGoal'] != null ? map['dailyGoal'] as int : null,
      links: map['links'] != null
          ? List<String>.from(map['links'] as List<dynamic>)
          : null,
      recurrence: map['recurrence'] != null
          ? List<String>.from(map['recurrence'] as List<dynamic>)
          : null,
    );
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
      "title": title,
      "description": description,
      "date": date?.toIso8601String(),
      "recurring_id": recurringId,
      "status": status,
      "duration": duration,
      "priority": priority,
      "list_id": listId,
      "section_id": sectionId,
      "done": done == true ? 1 : 0,
      "datetime": datetime?.toIso8601String(),
      "done_at": doneAt?.toIso8601String(),
      "read_at": readAt?.toIso8601String(),
      "due_date": dueDate?.toIso8601String(),
      "updated_at": updatedAt?.toIso8601String(),
      "created_at": createdAt?.toIso8601String(),
      "deleted_at": deletedAt?.toIso8601String(),
      "origin": origin,
      "remote_updated_at": remoteUpdatedAt?.toIso8601String(),
      "sorting": sorting,
      "sorting_label": sortingLabel,
      "links": links?.toList().join(','),
      "daily_goal": dailyGoal,
      "recurrence": recurrence?.toList().join(';'),
    };
  }

  static Task fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    if (data.containsKey("done") && data["done"] != null) {
      data["done"] = (data["done"] == 1);
    }

    data["listId"] = data["list_id"];
    data["dailyGoal"] = data["daily_goal"];

    List<String> linksList = [];

    if (data.containsKey("links") && data["links"] != null) {
      String links = data["links"] as String;
      linksList = links.split(',');
      data.remove("links");
    }

    List<String> recurrenceList = [];

    if (data.containsKey("recurrence") && data["recurrence"] != null) {
      String links = data["recurrence"] as String;
      linksList = links.split(';');
      data.remove("recurrence");
    }

    Task task = Task.fromMap(data);

    task = task.copyWith(links: linksList, recurrence: recurrenceList);

    return task;
  }

  @override
  List<Object?> get props {
    return [
      id,
      title,
      date,
      description,
      duration,
      status,
      createdAt,
      updatedAt,
      deletedAt,
      done,
      doneAt,
      datetime,
      readAt,
      globalUpdatedAt,
      globalCreatedAt,
      activationDatetime,
      dueDate,
      remoteUpdatedAt,
      recurringId,
      priority,
      listId,
      sectionId,
      origin,
      sorting,
      sortingLabel,
      selected,
      dailyGoal,
      links,
    ];
  }
}
