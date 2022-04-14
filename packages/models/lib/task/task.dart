import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:intl/intl.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';
import 'package:models/task/content.dart';

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

  @BuiltValueField(wireName: 'content', serialize: false)
  Content? get content;

  @BuiltValueField(wireName: 'daily_goal')
  int? get dailyGoal;

  @BuiltValueField(wireName: 'sorting')
  int? get sorting;

  @BuiltValueField(wireName: 'done')
  bool? get done;

  @BuiltValueField(wireName: 'done_at')
  DateTime? get doneAt;

  @BuiltValueField(wireName: 'read_at')
  DateTime? get readAt;

  @BuiltValueField(wireName: 'global_updated_at')
  DateTime? get globalUpdatedAt;

  @BuiltValueField(wireName: 'global_created_at')
  DateTime? get globalCreatedAt;

  @BuiltValueField(wireName: 'activation_datetime')
  DateTime? get activationDatetime;

  @BuiltValueField(wireName: 'sorting_label')
  int? get sortingLabel;

  @BuiltValueField(wireName: 'due_date')
  DateTime? get dueDate;

  @BuiltValueField(wireName: 'remote_updated_at')
  DateTime? get remoteUpdatedAt;

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

    return data;
  }

  static Map<String, dynamic> toMapS(data) {
    return data.toMap();
  }

  static Task fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Task.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    Map<String?, dynamic> data = serializers.serializeWith(
        Task.serializer, this) as Map<String?, dynamic>;

    data.remove("global_created_at");
    data.remove("global_updated_at");

    for (var key in data.keys) {
      if (data[key] is bool) {
        data[key] = data[key] ? 1 : 0;
      }
    }

    return Map<String, Object?>.from(data);
  }

  static Task fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    for (var key in data.keys) {
      if (key == "done" && data[key] != null) {
        data[key] = (data[key] == 1);
      }

      if ((key == "sorting" || key == "sorting_label") && data[key] != null) {
        data[key] = (int.parse(data[key] as String));
      }
    }

    return serializers.deserializeWith(Task.serializer, data)!;
  }

  static Serializer<Task> get serializer => _$taskSerializer;
}
