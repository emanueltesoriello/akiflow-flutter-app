import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/serializers.dart';
import 'package:models/task/content.dart';

part 'task.g.dart';

abstract class Task implements Built<Task, TaskBuilder> {
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

  Map<String, dynamic> toMap() {
    return serializers.serializeWith(Task.serializer, this)
        as Map<String, dynamic>;
  }

  static Task fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(Task.serializer, json)!;
  }

  Map<String, Object?> toSql() {
    Map<String?, dynamic> data = serializers.serializeWith(
        Task.serializer, this) as Map<String?, dynamic>;

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
    }

    return serializers.deserializeWith(Task.serializer, data)!;
  }

  static Serializer<Task> get serializer => _$taskSerializer;
}
