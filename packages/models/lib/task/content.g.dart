// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'content.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Content> _$contentSerializer = new _$ContentSerializer();

class _$ContentSerializer implements StructuredSerializer<Content> {
  @override
  final Iterable<Type> types = const [Content, _$Content];
  @override
  final String wireName = 'Content';

  @override
  Iterable<Object?> serialize(Serializers serializers, Content object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.eventLockInCalendar;
    if (value != null) {
      result
        ..add('eventLockInCalendar')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.shouldRemoveCalendarEvent;
    if (value != null) {
      result
        ..add('shouldRemoveCalendarEvent')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.expiredSnooze;
    if (value != null) {
      result
        ..add('expiredSnooze')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.overdue;
    if (value != null) {
      result
        ..add('overdue')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    return result;
  }

  @override
  Content deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new ContentBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'eventLockInCalendar':
          result.eventLockInCalendar = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'shouldRemoveCalendarEvent':
          result.shouldRemoveCalendarEvent = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'expiredSnooze':
          result.expiredSnooze = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'overdue':
          result.overdue = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
      }
    }

    return result.build();
  }
}

class _$Content extends Content {
  @override
  final String? eventLockInCalendar;
  @override
  final bool? shouldRemoveCalendarEvent;
  @override
  final bool? expiredSnooze;
  @override
  final bool? overdue;

  factory _$Content([void Function(ContentBuilder)? updates]) =>
      (new ContentBuilder()..update(updates)).build();

  _$Content._(
      {this.eventLockInCalendar,
      this.shouldRemoveCalendarEvent,
      this.expiredSnooze,
      this.overdue})
      : super._();

  @override
  Content rebuild(void Function(ContentBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ContentBuilder toBuilder() => new ContentBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Content &&
        eventLockInCalendar == other.eventLockInCalendar &&
        shouldRemoveCalendarEvent == other.shouldRemoveCalendarEvent &&
        expiredSnooze == other.expiredSnooze &&
        overdue == other.overdue;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc($jc(0, eventLockInCalendar.hashCode),
                shouldRemoveCalendarEvent.hashCode),
            expiredSnooze.hashCode),
        overdue.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Content')
          ..add('eventLockInCalendar', eventLockInCalendar)
          ..add('shouldRemoveCalendarEvent', shouldRemoveCalendarEvent)
          ..add('expiredSnooze', expiredSnooze)
          ..add('overdue', overdue))
        .toString();
  }
}

class ContentBuilder implements Builder<Content, ContentBuilder> {
  _$Content? _$v;

  String? _eventLockInCalendar;
  String? get eventLockInCalendar => _$this._eventLockInCalendar;
  set eventLockInCalendar(String? eventLockInCalendar) =>
      _$this._eventLockInCalendar = eventLockInCalendar;

  bool? _shouldRemoveCalendarEvent;
  bool? get shouldRemoveCalendarEvent => _$this._shouldRemoveCalendarEvent;
  set shouldRemoveCalendarEvent(bool? shouldRemoveCalendarEvent) =>
      _$this._shouldRemoveCalendarEvent = shouldRemoveCalendarEvent;

  bool? _expiredSnooze;
  bool? get expiredSnooze => _$this._expiredSnooze;
  set expiredSnooze(bool? expiredSnooze) =>
      _$this._expiredSnooze = expiredSnooze;

  bool? _overdue;
  bool? get overdue => _$this._overdue;
  set overdue(bool? overdue) => _$this._overdue = overdue;

  ContentBuilder();

  ContentBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _eventLockInCalendar = $v.eventLockInCalendar;
      _shouldRemoveCalendarEvent = $v.shouldRemoveCalendarEvent;
      _expiredSnooze = $v.expiredSnooze;
      _overdue = $v.overdue;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Content other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Content;
  }

  @override
  void update(void Function(ContentBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Content build() {
    final _$result = _$v ??
        new _$Content._(
            eventLockInCalendar: eventLockInCalendar,
            shouldRemoveCalendarEvent: shouldRemoveCalendarEvent,
            expiredSnooze: expiredSnooze,
            overdue: overdue);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
