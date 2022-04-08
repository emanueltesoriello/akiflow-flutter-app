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
  @BuiltValueField(wireName: 'user_id')
  int? get userId;
  @BuiltValueField(wireName: 'created_at')
  String? get createdAt;
  @BuiltValueField(wireName: 'updated_at')
  String? get updatedAt;
  @BuiltValueField(wireName: 'deleted_at')
  String? get deletedAt;
  @BuiltValueField(wireName: 'content')
  Content? get content;
  @BuiltValueField(wireName: 'dailyGoal')
  int? get dailyGoal;
  @BuiltValueField(wireName: 'sorting')
  int? get sorting;
  @BuiltValueField(wireName: 'done')
  bool? get done;
  @BuiltValueField(wireName: 'done_at')
  String? get doneAt;
  @BuiltValueField(wireName: 'read_at')
  String? get readAt;
  @BuiltValueField(wireName: 'global_updated_at')
  String? get globalUpdatedAt;
  @BuiltValueField(wireName: 'global_created_at')
  String? get globalCreatedAt;
  @BuiltValueField(wireName: 'activation_datetime')
  String? get activationDatetime;
  @BuiltValueField(wireName: 'sorting_label')
  int? get sortingLabel;
  @BuiltValueField(wireName: 'due_date')
  String? get dueDate;

  Task._();

  factory Task([void Function(TaskBuilder) updates]) = _$Task;

  @override
  Task rebuild(void Function(TaskBuilder) updates);

  @override
  TaskBuilder toBuilder();

  Map<String?, dynamic> toMap() {
    return serializers.serializeWith(Task.serializer, this)
        as Map<String?, dynamic>;
  }

  static Task fromMap(Map<String?, dynamic> json) {
    return serializers.deserializeWith(Task.serializer, json)!;
  }

  static Serializer<Task> get serializer => _$taskSerializer;
}
