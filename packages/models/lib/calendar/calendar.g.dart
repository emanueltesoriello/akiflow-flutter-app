// GENERATED CODE - DO NOT MODIFY BY HAND

part of calendar;

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Calendar> _$calendarSerializer = new _$CalendarSerializer();

class _$CalendarSerializer implements StructuredSerializer<Calendar> {
  @override
  final Iterable<Type> types = const [Calendar, _$Calendar];
  @override
  final String wireName = 'Calendar';

  @override
  Iterable<Object?> serialize(Serializers serializers, Calendar object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.id;

    result
      ..add('id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.originId;

    result
      ..add('origin_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.connectorId;

    result
      ..add('connector_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.akiflowCalendarId;

    result
      ..add('akiflow_account_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.originCalendarId;

    result
      ..add('origin_account_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.title;

    result
      ..add('title')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.description;

    result
      ..add('description')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.akiflowAccountId;

    result
      ..add('akiflow_account_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.originAccountId;

    result
      ..add('origin_account_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.primary;

    result
      ..add('primary')
      ..add(serializers.serialize(value, specifiedType: const FullType(bool)));
    value = object.akiflowPrimary;

    result
      ..add('akiflow_primary')
      ..add(serializers.serialize(value, specifiedType: const FullType(bool)));
    value = object.readOnly;

    result
      ..add('read_only')
      ..add(serializers.serialize(value, specifiedType: const FullType(bool)));
    value = object.url;

    result
      ..add('url')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.color;

    result
      ..add('color')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.icon;

    result
      ..add('icon')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.isAkiflowCalendar;

    result
      ..add('is_akiflow_calendar')
      ..add(serializers.serialize(value, specifiedType: const FullType(bool)));
    value = object.globalUpdatedAt;

    result
      ..add('global_updated_at')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.globalCreatedAt;

    result
      ..add('global_created_at')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.createdAt;

    result
      ..add('created_at')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.updatedAt;

    result
      ..add('updated_at')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.deletedAt;

    result
      ..add('deleted_at')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.remoteUpdatedAt;

    result
      ..add('remote_updated_at')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));

    return result;
  }

  @override
  Calendar deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new CalendarBuilder();

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
        case 'origin_id':
          result.originId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'connector_id':
          result.connectorId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'akiflow_account_id':
          result.akiflowCalendarId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_account_id':
          result.originCalendarId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'title':
          result.title = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'description':
          result.description = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'akiflow_account_id':
          result.akiflowAccountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_account_id':
          result.originAccountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'primary':
          result.primary = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'akiflow_primary':
          result.akiflowPrimary = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'read_only':
          result.readOnly = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'url':
          result.url = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'color':
          result.color = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'icon':
          result.icon = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'is_akiflow_calendar':
          result.isAkiflowCalendar = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'global_updated_at':
          result.globalUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'global_created_at':
          result.globalCreatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
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
        case 'remote_updated_at':
          result.remoteUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
      }
    }

    return result.build();
  }
}

class _$Calendar extends Calendar {
  @override
  final String? id;
  @override
  final String? originId;
  @override
  final String? connectorId;
  @override
  final String? akiflowCalendarId;
  @override
  final String? originCalendarId;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? akiflowAccountId;
  @override
  final String? originAccountId;
  @override
  final bool? primary;
  @override
  final bool? akiflowPrimary;
  @override
  final bool? readOnly;
  @override
  final String? url;
  @override
  final String? color;
  @override
  final String? icon;
  @override
  final bool? isAkiflowCalendar;
  @override
  final DateTime? globalUpdatedAt;
  @override
  final DateTime? globalCreatedAt;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? remoteUpdatedAt;

  factory _$Calendar([void Function(CalendarBuilder)? updates]) =>
      (new CalendarBuilder()..update(updates)).build();

  _$Calendar._(
      {this.id,
      this.originId,
      this.connectorId,
      this.akiflowCalendarId,
      this.originCalendarId,
      this.title,
      this.description,
      this.akiflowAccountId,
      this.originAccountId,
      this.primary,
      this.akiflowPrimary,
      this.readOnly,
      this.url,
      this.color,
      this.icon,
      this.isAkiflowCalendar,
      this.globalUpdatedAt,
      this.globalCreatedAt,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.remoteUpdatedAt})
      : super._();

  @override
  Calendar rebuild(void Function(CalendarBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CalendarBuilder toBuilder() => new CalendarBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Calendar &&
        id == other.id &&
        originId == other.originId &&
        connectorId == other.connectorId &&
        akiflowCalendarId == other.akiflowCalendarId &&
        originCalendarId == other.originCalendarId &&
        title == other.title &&
        description == other.description &&
        akiflowAccountId == other.akiflowAccountId &&
        originAccountId == other.originAccountId &&
        primary == other.primary &&
        akiflowPrimary == other.akiflowPrimary &&
        readOnly == other.readOnly &&
        url == other.url &&
        color == other.color &&
        icon == other.icon &&
        isAkiflowCalendar == other.isAkiflowCalendar &&
        globalUpdatedAt == other.globalUpdatedAt &&
        globalCreatedAt == other.globalCreatedAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
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
                                                                            $jc($jc($jc($jc(0, id.hashCode), originId.hashCode), connectorId.hashCode),
                                                                                akiflowCalendarId.hashCode),
                                                                            originCalendarId.hashCode),
                                                                        title.hashCode),
                                                                    description.hashCode),
                                                                akiflowAccountId.hashCode),
                                                            originAccountId.hashCode),
                                                        primary.hashCode),
                                                    akiflowPrimary.hashCode),
                                                readOnly.hashCode),
                                            url.hashCode),
                                        color.hashCode),
                                    icon.hashCode),
                                isAkiflowCalendar.hashCode),
                            globalUpdatedAt.hashCode),
                        globalCreatedAt.hashCode),
                    createdAt.hashCode),
                updatedAt.hashCode),
            deletedAt.hashCode),
        remoteUpdatedAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Calendar')
          ..add('id', id)
          ..add('originId', originId)
          ..add('connectorId', connectorId)
          ..add('akiflowCalendarId', akiflowCalendarId)
          ..add('originCalendarId', originCalendarId)
          ..add('title', title)
          ..add('description', description)
          ..add('akiflowAccountId', akiflowAccountId)
          ..add('originAccountId', originAccountId)
          ..add('primary', primary)
          ..add('akiflowPrimary', akiflowPrimary)
          ..add('readOnly', readOnly)
          ..add('url', url)
          ..add('color', color)
          ..add('icon', icon)
          ..add('isAkiflowCalendar', isAkiflowCalendar)
          ..add('globalUpdatedAt', globalUpdatedAt)
          ..add('globalCreatedAt', globalCreatedAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('remoteUpdatedAt', remoteUpdatedAt))
        .toString();
  }
}

class CalendarBuilder implements Builder<Calendar, CalendarBuilder> {
  _$Calendar? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _originId;
  String? get originId => _$this._originId;
  set originId(String? originId) => _$this._originId = originId;

  String? _connectorId;
  String? get connectorId => _$this._connectorId;
  set connectorId(String? connectorId) => _$this._connectorId = connectorId;

  String? _akiflowCalendarId;
  String? get akiflowCalendarId => _$this._akiflowCalendarId;
  set akiflowCalendarId(String? akiflowCalendarId) =>
      _$this._akiflowCalendarId = akiflowCalendarId;

  String? _originCalendarId;
  String? get originCalendarId => _$this._originCalendarId;
  set originCalendarId(String? originCalendarId) =>
      _$this._originCalendarId = originCalendarId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _akiflowAccountId;
  String? get akiflowAccountId => _$this._akiflowAccountId;
  set akiflowAccountId(String? akiflowAccountId) =>
      _$this._akiflowAccountId = akiflowAccountId;

  String? _originAccountId;
  String? get originAccountId => _$this._originAccountId;
  set originAccountId(String? originAccountId) =>
      _$this._originAccountId = originAccountId;

  bool? _primary;
  bool? get primary => _$this._primary;
  set primary(bool? primary) => _$this._primary = primary;

  bool? _akiflowPrimary;
  bool? get akiflowPrimary => _$this._akiflowPrimary;
  set akiflowPrimary(bool? akiflowPrimary) =>
      _$this._akiflowPrimary = akiflowPrimary;

  bool? _readOnly;
  bool? get readOnly => _$this._readOnly;
  set readOnly(bool? readOnly) => _$this._readOnly = readOnly;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _color;
  String? get color => _$this._color;
  set color(String? color) => _$this._color = color;

  String? _icon;
  String? get icon => _$this._icon;
  set icon(String? icon) => _$this._icon = icon;

  bool? _isAkiflowCalendar;
  bool? get isAkiflowCalendar => _$this._isAkiflowCalendar;
  set isAkiflowCalendar(bool? isAkiflowCalendar) =>
      _$this._isAkiflowCalendar = isAkiflowCalendar;

  DateTime? _globalUpdatedAt;
  DateTime? get globalUpdatedAt => _$this._globalUpdatedAt;
  set globalUpdatedAt(DateTime? globalUpdatedAt) =>
      _$this._globalUpdatedAt = globalUpdatedAt;

  DateTime? _globalCreatedAt;
  DateTime? get globalCreatedAt => _$this._globalCreatedAt;
  set globalCreatedAt(DateTime? globalCreatedAt) =>
      _$this._globalCreatedAt = globalCreatedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _remoteUpdatedAt;
  DateTime? get remoteUpdatedAt => _$this._remoteUpdatedAt;
  set remoteUpdatedAt(DateTime? remoteUpdatedAt) =>
      _$this._remoteUpdatedAt = remoteUpdatedAt;

  CalendarBuilder();

  CalendarBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _originId = $v.originId;
      _connectorId = $v.connectorId;
      _akiflowCalendarId = $v.akiflowCalendarId;
      _originCalendarId = $v.originCalendarId;
      _title = $v.title;
      _description = $v.description;
      _akiflowAccountId = $v.akiflowAccountId;
      _originAccountId = $v.originAccountId;
      _primary = $v.primary;
      _akiflowPrimary = $v.akiflowPrimary;
      _readOnly = $v.readOnly;
      _url = $v.url;
      _color = $v.color;
      _icon = $v.icon;
      _isAkiflowCalendar = $v.isAkiflowCalendar;
      _globalUpdatedAt = $v.globalUpdatedAt;
      _globalCreatedAt = $v.globalCreatedAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _remoteUpdatedAt = $v.remoteUpdatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Calendar other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Calendar;
  }

  @override
  void update(void Function(CalendarBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Calendar build() {
    final _$result = _$v ??
        new _$Calendar._(
            id: id,
            originId: originId,
            connectorId: connectorId,
            akiflowCalendarId: akiflowCalendarId,
            originCalendarId: originCalendarId,
            title: title,
            description: description,
            akiflowAccountId: akiflowAccountId,
            originAccountId: originAccountId,
            primary: primary,
            akiflowPrimary: akiflowPrimary,
            readOnly: readOnly,
            url: url,
            color: color,
            icon: icon,
            isAkiflowCalendar: isAkiflowCalendar,
            globalUpdatedAt: globalUpdatedAt,
            globalCreatedAt: globalCreatedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            remoteUpdatedAt: remoteUpdatedAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
