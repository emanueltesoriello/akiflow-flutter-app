// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_details.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<LocalDetails> _$localDetailsSerializer =
    new _$LocalDetailsSerializer();

class _$LocalDetailsSerializer implements StructuredSerializer<LocalDetails> {
  @override
  final Iterable<Type> types = const [LocalDetails, _$LocalDetails];
  @override
  final String wireName = 'LocalDetails';

  @override
  Iterable<Object?> serialize(Serializers serializers, LocalDetails object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.firstSyncExecuted;
    if (value != null) {
      result
        ..add('firstSyncExecuted')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.lastAccountsSyncAt;
    if (value != null) {
      result
        ..add('lastAccountsSyncAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.lastLabelsSyncAt;
    if (value != null) {
      result
        ..add('lastLabelsSyncAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.lastTasksSyncAt;
    if (value != null) {
      result
        ..add('lastTasksSyncAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.lastCalendarsSyncAt;
    if (value != null) {
      result
        ..add('lastCalendarsSyncAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.lastEventsSyncAt;
    if (value != null) {
      result
        ..add('lastEventsSyncAt')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    return result;
  }

  @override
  LocalDetails deserialize(
      Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new LocalDetailsBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'firstSyncExecuted':
          result.firstSyncExecuted = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'lastAccountsSyncAt':
          result.lastAccountsSyncAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'lastLabelsSyncAt':
          result.lastLabelsSyncAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'lastTasksSyncAt':
          result.lastTasksSyncAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'lastCalendarsSyncAt':
          result.lastCalendarsSyncAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'lastEventsSyncAt':
          result.lastEventsSyncAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
      }
    }

    return result.build();
  }
}

class _$LocalDetails extends LocalDetails {
  @override
  final bool? firstSyncExecuted;
  @override
  final DateTime? lastAccountsSyncAt;
  @override
  final DateTime? lastLabelsSyncAt;
  @override
  final DateTime? lastTasksSyncAt;
  @override
  final DateTime? lastCalendarsSyncAt;
  @override
  final DateTime? lastEventsSyncAt;

  factory _$LocalDetails([void Function(LocalDetailsBuilder)? updates]) =>
      (new LocalDetailsBuilder()..update(updates)).build();

  _$LocalDetails._(
      {this.firstSyncExecuted,
      this.lastAccountsSyncAt,
      this.lastLabelsSyncAt,
      this.lastTasksSyncAt,
      this.lastCalendarsSyncAt,
      this.lastEventsSyncAt})
      : super._();

  @override
  LocalDetails rebuild(void Function(LocalDetailsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LocalDetailsBuilder toBuilder() => new LocalDetailsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LocalDetails &&
        firstSyncExecuted == other.firstSyncExecuted &&
        lastAccountsSyncAt == other.lastAccountsSyncAt &&
        lastLabelsSyncAt == other.lastLabelsSyncAt &&
        lastTasksSyncAt == other.lastTasksSyncAt &&
        lastCalendarsSyncAt == other.lastCalendarsSyncAt &&
        lastEventsSyncAt == other.lastEventsSyncAt;
  }

  @override
  int get hashCode {
    return $jf($jc(
        $jc(
            $jc(
                $jc(
                    $jc($jc(0, firstSyncExecuted.hashCode),
                        lastAccountsSyncAt.hashCode),
                    lastLabelsSyncAt.hashCode),
                lastTasksSyncAt.hashCode),
            lastCalendarsSyncAt.hashCode),
        lastEventsSyncAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('LocalDetails')
          ..add('firstSyncExecuted', firstSyncExecuted)
          ..add('lastAccountsSyncAt', lastAccountsSyncAt)
          ..add('lastLabelsSyncAt', lastLabelsSyncAt)
          ..add('lastTasksSyncAt', lastTasksSyncAt)
          ..add('lastCalendarsSyncAt', lastCalendarsSyncAt)
          ..add('lastEventsSyncAt', lastEventsSyncAt))
        .toString();
  }
}

class LocalDetailsBuilder
    implements Builder<LocalDetails, LocalDetailsBuilder> {
  _$LocalDetails? _$v;

  bool? _firstSyncExecuted;
  bool? get firstSyncExecuted => _$this._firstSyncExecuted;
  set firstSyncExecuted(bool? firstSyncExecuted) =>
      _$this._firstSyncExecuted = firstSyncExecuted;

  DateTime? _lastAccountsSyncAt;
  DateTime? get lastAccountsSyncAt => _$this._lastAccountsSyncAt;
  set lastAccountsSyncAt(DateTime? lastAccountsSyncAt) =>
      _$this._lastAccountsSyncAt = lastAccountsSyncAt;

  DateTime? _lastLabelsSyncAt;
  DateTime? get lastLabelsSyncAt => _$this._lastLabelsSyncAt;
  set lastLabelsSyncAt(DateTime? lastLabelsSyncAt) =>
      _$this._lastLabelsSyncAt = lastLabelsSyncAt;

  DateTime? _lastTasksSyncAt;
  DateTime? get lastTasksSyncAt => _$this._lastTasksSyncAt;
  set lastTasksSyncAt(DateTime? lastTasksSyncAt) =>
      _$this._lastTasksSyncAt = lastTasksSyncAt;

  DateTime? _lastCalendarsSyncAt;
  DateTime? get lastCalendarsSyncAt => _$this._lastCalendarsSyncAt;
  set lastCalendarsSyncAt(DateTime? lastCalendarsSyncAt) =>
      _$this._lastCalendarsSyncAt = lastCalendarsSyncAt;

  DateTime? _lastEventsSyncAt;
  DateTime? get lastEventsSyncAt => _$this._lastEventsSyncAt;
  set lastEventsSyncAt(DateTime? lastEventsSyncAt) =>
      _$this._lastEventsSyncAt = lastEventsSyncAt;

  LocalDetailsBuilder();

  LocalDetailsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _firstSyncExecuted = $v.firstSyncExecuted;
      _lastAccountsSyncAt = $v.lastAccountsSyncAt;
      _lastLabelsSyncAt = $v.lastLabelsSyncAt;
      _lastTasksSyncAt = $v.lastTasksSyncAt;
      _lastCalendarsSyncAt = $v.lastCalendarsSyncAt;
      _lastEventsSyncAt = $v.lastEventsSyncAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LocalDetails other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$LocalDetails;
  }

  @override
  void update(void Function(LocalDetailsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$LocalDetails build() {
    final _$result = _$v ??
        new _$LocalDetails._(
            firstSyncExecuted: firstSyncExecuted,
            lastAccountsSyncAt: lastAccountsSyncAt,
            lastLabelsSyncAt: lastLabelsSyncAt,
            lastTasksSyncAt: lastTasksSyncAt,
            lastCalendarsSyncAt: lastCalendarsSyncAt,
            lastEventsSyncAt: lastEventsSyncAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
