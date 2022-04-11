// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Task> _$taskSerializer = new _$TaskSerializer();

class _$TaskSerializer implements StructuredSerializer<Task> {
  @override
  final Iterable<Type> types = const [Task, _$Task];
  @override
  final String wireName = 'Task';

  @override
  Iterable<Object?> serialize(Serializers serializers, Task object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.title;
    if (value != null) {
      result
        ..add('title')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.date;
    if (value != null) {
      result
        ..add('date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.description;
    if (value != null) {
      result
        ..add('description')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.duration;
    if (value != null) {
      result
        ..add('duration')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('created_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.updatedAt;
    if (value != null) {
      result
        ..add('updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.deletedAt;
    if (value != null) {
      result
        ..add('deleted_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.dailyGoal;
    if (value != null) {
      result
        ..add('daily_goal')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.sorting;
    if (value != null) {
      result
        ..add('sorting')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.done;
    if (value != null) {
      result
        ..add('done')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.doneAt;
    if (value != null) {
      result
        ..add('done_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.readAt;
    if (value != null) {
      result
        ..add('read_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.globalUpdatedAt;
    if (value != null) {
      result
        ..add('global_updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.globalCreatedAt;
    if (value != null) {
      result
        ..add('global_created_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.activationDatetime;
    if (value != null) {
      result
        ..add('activation_datetime')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.sortingLabel;
    if (value != null) {
      result
        ..add('sorting_label')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.dueDate;
    if (value != null) {
      result
        ..add('due_date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.remoteUpdatedAt;
    if (value != null) {
      result
        ..add('remote_updated_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    return result;
  }

  @override
  Task deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new TaskBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'date':
          result.date = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'duration':
          result.duration = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'created_at':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'updated_at':
          result.updatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'deleted_at':
          result.deletedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'daily_goal':
          result.dailyGoal = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'sorting':
          result.sorting = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'done':
          result.done = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'done_at':
          result.doneAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'read_at':
          result.readAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'global_updated_at':
          result.globalUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'global_created_at':
          result.globalCreatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'activation_datetime':
          result.activationDatetime = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'sorting_label':
          result.sortingLabel = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'due_date':
          result.dueDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'remote_updated_at':
          result.remoteUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
      }
    }

    return result.build();
  }
}

class _$Task extends Task {
  @override
  final String? id;
  @override
  final String? title;
  @override
  final DateTime? date;
  @override
  final String? description;
  @override
  final int? duration;
  @override
  final int? status;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final Content? content;
  @override
  final int? dailyGoal;
  @override
  final int? sorting;
  @override
  final bool? done;
  @override
  final DateTime? doneAt;
  @override
  final DateTime? readAt;
  @override
  final DateTime? globalUpdatedAt;
  @override
  final DateTime? globalCreatedAt;
  @override
  final DateTime? activationDatetime;
  @override
  final int? sortingLabel;
  @override
  final DateTime? dueDate;
  @override
  final DateTime? remoteUpdatedAt;

  factory _$Task([void Function(TaskBuilder)? updates]) =>
      (new TaskBuilder()..update(updates)).build();

  _$Task._(
      {this.id,
      this.title,
      this.date,
      this.description,
      this.duration,
      this.status,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.content,
      this.dailyGoal,
      this.sorting,
      this.done,
      this.doneAt,
      this.readAt,
      this.globalUpdatedAt,
      this.globalCreatedAt,
      this.activationDatetime,
      this.sortingLabel,
      this.dueDate,
      this.remoteUpdatedAt})
      : super._();

  @override
  Task rebuild(void Function(TaskBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TaskBuilder toBuilder() => new TaskBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Task &&
        id == other.id &&
        title == other.title &&
        date == other.date &&
        description == other.description &&
        duration == other.duration &&
        status == other.status &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        content == other.content &&
        dailyGoal == other.dailyGoal &&
        sorting == other.sorting &&
        done == other.done &&
        doneAt == other.doneAt &&
        readAt == other.readAt &&
        globalUpdatedAt == other.globalUpdatedAt &&
        globalCreatedAt == other.globalCreatedAt &&
        activationDatetime == other.activationDatetime &&
        sortingLabel == other.sortingLabel &&
        dueDate == other.dueDate &&
        remoteUpdatedAt == other.remoteUpdatedAt;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc(
                        $jc(
                            $jc(
                                $jc(
                                    $jc(
                                        $jc(
                                            $jc(
                                                $jc(
                                                    $jc(
                                                        $jc(
                                                            $jc(
                                                                $jc(
                                                                    $jc(
                                                                        $jc(
                                                                            $jc($jc($jc(0, id.hashCode), title.hashCode),
                                                                                date.hashCode),
                                                                            description.hashCode),
                                                                        duration.hashCode),
                                                                    status.hashCode),
                                                                createdAt.hashCode),
                                                            updatedAt.hashCode),
                                                        deletedAt.hashCode),
                                                    content.hashCode),
                                                dailyGoal.hashCode),
                                            sorting.hashCode),
                                        done.hashCode),
                                    doneAt.hashCode),
                                readAt.hashCode),
                            globalUpdatedAt.hashCode),
                        globalCreatedAt.hashCode),
                    activationDatetime.hashCode),
                sortingLabel.hashCode),
            dueDate.hashCode),
        remoteUpdatedAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Task')
          ..add('id', id)
          ..add('title', title)
          ..add('date', date)
          ..add('description', description)
          ..add('duration', duration)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('content', content)
          ..add('dailyGoal', dailyGoal)
          ..add('sorting', sorting)
          ..add('done', done)
          ..add('doneAt', doneAt)
          ..add('readAt', readAt)
          ..add('globalUpdatedAt', globalUpdatedAt)
          ..add('globalCreatedAt', globalCreatedAt)
          ..add('activationDatetime', activationDatetime)
          ..add('sortingLabel', sortingLabel)
          ..add('dueDate', dueDate)
          ..add('remoteUpdatedAt', remoteUpdatedAt))
        .toString();
  }
}

class TaskBuilder implements Builder<Task, TaskBuilder> {
  _$Task? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _date;
  DateTime? get date => _$this._date;
  set date(DateTime? date) => _$this._date = date;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  int? _duration;
  int? get duration => _$this._duration;
  set duration(int? duration) => _$this._duration = duration;

  int? _status;
  int? get status => _$this._status;
  set status(int? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  ContentBuilder? _content;
  ContentBuilder get content => _$this._content ??= new ContentBuilder();
  set content(ContentBuilder? content) => _$this._content = content;

  int? _dailyGoal;
  int? get dailyGoal => _$this._dailyGoal;
  set dailyGoal(int? dailyGoal) => _$this._dailyGoal = dailyGoal;

  int? _sorting;
  int? get sorting => _$this._sorting;
  set sorting(int? sorting) => _$this._sorting = sorting;

  bool? _done;
  bool? get done => _$this._done;
  set done(bool? done) => _$this._done = done;

  DateTime? _doneAt;
  DateTime? get doneAt => _$this._doneAt;
  set doneAt(DateTime? doneAt) => _$this._doneAt = doneAt;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  DateTime? _globalUpdatedAt;
  DateTime? get globalUpdatedAt => _$this._globalUpdatedAt;
  set globalUpdatedAt(DateTime? globalUpdatedAt) =>
      _$this._globalUpdatedAt = globalUpdatedAt;

  DateTime? _globalCreatedAt;
  DateTime? get globalCreatedAt => _$this._globalCreatedAt;
  set globalCreatedAt(DateTime? globalCreatedAt) =>
      _$this._globalCreatedAt = globalCreatedAt;

  DateTime? _activationDatetime;
  DateTime? get activationDatetime => _$this._activationDatetime;
  set activationDatetime(DateTime? activationDatetime) =>
      _$this._activationDatetime = activationDatetime;

  int? _sortingLabel;
  int? get sortingLabel => _$this._sortingLabel;
  set sortingLabel(int? sortingLabel) => _$this._sortingLabel = sortingLabel;

  DateTime? _dueDate;
  DateTime? get dueDate => _$this._dueDate;
  set dueDate(DateTime? dueDate) => _$this._dueDate = dueDate;

  DateTime? _remoteUpdatedAt;
  DateTime? get remoteUpdatedAt => _$this._remoteUpdatedAt;
  set remoteUpdatedAt(DateTime? remoteUpdatedAt) =>
      _$this._remoteUpdatedAt = remoteUpdatedAt;

  TaskBuilder();

  TaskBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _date = $v.date;
      _description = $v.description;
      _duration = $v.duration;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _content = $v.content?.toBuilder();
      _dailyGoal = $v.dailyGoal;
      _sorting = $v.sorting;
      _done = $v.done;
      _doneAt = $v.doneAt;
      _readAt = $v.readAt;
      _globalUpdatedAt = $v.globalUpdatedAt;
      _globalCreatedAt = $v.globalCreatedAt;
      _activationDatetime = $v.activationDatetime;
      _sortingLabel = $v.sortingLabel;
      _dueDate = $v.dueDate;
      _remoteUpdatedAt = $v.remoteUpdatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Task other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Task;
  }

  @override
  void update(void Function(TaskBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Task build() {
    _$Task _$result;
    try {
      _$result = _$v ??
          new _$Task._(
              id: id,
              title: title,
              date: date,
              description: description,
              duration: duration,
              status: status,
              createdAt: createdAt,
              updatedAt: updatedAt,
              deletedAt: deletedAt,
              content: _content?.build(),
              dailyGoal: dailyGoal,
              sorting: sorting,
              done: done,
              doneAt: doneAt,
              readAt: readAt,
              globalUpdatedAt: globalUpdatedAt,
              globalCreatedAt: globalCreatedAt,
              activationDatetime: activationDatetime,
              sortingLabel: sortingLabel,
              dueDate: dueDate,
              remoteUpdatedAt: remoteUpdatedAt);
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        _content?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Task', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
