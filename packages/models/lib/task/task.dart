import 'dart:convert';

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:intl/intl.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';

part 'task.g.dart';

abstract class Task extends Object
    with Base
    implements Built<Task, TaskBuilder> {
  @BuiltValueField(wireName: 'id')
  String? get id;

  @BuiltValueField(wireName: 'title')
  String? get title;

  @BuiltValueField(wireName: 'date')
  DateTime? get date;

  @BuiltValueField(wireName: 'description')
  String? get description;

  @BuiltValueField(wireName: 'duration')
  int? get duration;

  @BuiltValueField(wireName: 'status')
  int? get status;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'updated_at')
  DateTime? get updatedAt;

  @BuiltValueField(wireName: 'deleted_at')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: 'done')
  bool? get done;

  @BuiltValueField(wireName: 'done_at')
  DateTime? get doneAt;

  @BuiltValueField(wireName: 'datetime')
  DateTime? get datetime;

  @BuiltValueField(wireName: 'read_at')
  DateTime? get readAt;

  @BuiltValueField(wireName: 'global_updated_at')
  DateTime? get globalUpdatedAt;

  @BuiltValueField(wireName: 'global_created_at')
  DateTime? get globalCreatedAt;

  @BuiltValueField(wireName: 'activation_datetime')
  DateTime? get activationDatetime;

  @BuiltValueField(wireName: 'due_date')
  DateTime? get dueDate;

  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

  @BuiltValueField(wireName: 'recurring_id')
  String? get recurringId;

  @BuiltValueField(wireName: 'priority')
  int? get priority;

  @BuiltValueField(wireName: 'listId')
  String? get listId;

  @BuiltValueField(wireName: 'section_id')
  String? get sectionId;

  @BuiltValueField(wireName: 'origin')
  String? get origin;

  @BuiltValueField(wireName: 'sorting')
  int? get sorting;

  @BuiltValueField(wireName: 'sorting_label')
  int? get sortingLabel;

  @BuiltValueField(serialize: false)
  bool? get selected;

  Task._();

  factory Task([void Function(TaskBuilder) updates]) = _$Task;

  @override
  Task rebuild(void Function(TaskBuilder) updates);

  @override
  TaskBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = serializers.serializeWith(Task.serializer, this)
        as Map<String, dynamic>;

    if (date != null) {
      data['date'] = DateFormat('yyyy-MM-dd').format(date!);
    }

    if (dueDate != null) {
      data['due_date'] = DateFormat('yyyy-MM-dd').format(dueDate!);
    }

    return data;
  }

  static Task fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Task.serializer, json)!;
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
    };
  }

  static Task fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    List<String> keys = data.keys.toList();

    for (var key in keys) {
      if (key == "done" && data[key] != null) {
        data[key] = (data[key] == 1);
      }

      if (key == "links") {
        data[key] = data["links"] is String
            ? jsonDecode(data["links"] as String)
            : null;
      }

      if (key == "list_id") {
        data["listId"] = data["list_id"];
      }
    }

    return serializers.deserializeWith(Task.serializer, data)!;
  }

  @BuiltValueSerializer(serializeNulls: true)
  static Serializer<Task> get serializer => _$taskSerializer;
}
