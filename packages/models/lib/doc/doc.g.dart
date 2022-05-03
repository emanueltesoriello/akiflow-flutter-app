// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doc.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Doc> _$docSerializer = new _$DocSerializer();

class _$DocSerializer implements StructuredSerializer<Doc> {
  @override
  final Iterable<Type> types = const [Doc, _$Doc];
  @override
  final String wireName = 'Doc';

  @override
  Iterable<Object?> serialize(Serializers serializers, Doc object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.id;

    result
      ..add('id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.taskId;

    result
      ..add('task_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.connectorId;

    result
      ..add('connector_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.originId;

    result
      ..add('origin_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.accountId;

    result
      ..add('account_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.url;

    result
      ..add('url')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.localUrl;

    result
      ..add('local_url')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.type;

    result
      ..add('type')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.icon;

    result
      ..add('icon')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
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
    value = object.remoteUpdatedAt;

    result
      ..add('remote_updated_at')
      ..add(serializers.serialize(value,
          specifiedType: const FullType(DateTime)));
    value = object.content;

    result
      ..add('content')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(Content)));

    return result;
  }

  @override
  Doc deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new DocBuilder();

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
        case 'task_id':
          result.taskId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'connector_id':
          result.connectorId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_id':
          result.originId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'account_id':
          result.accountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'url':
          result.url = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'local_url':
          result.localUrl = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'type':
          result.type = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'icon':
          result.icon = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'updated_at':
          result.updatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'deleted_at':
          result.deletedAt = serializers.deserialize(value,
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
        case 'remote_updated_at':
          result.remoteUpdatedAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'content':
          result.content.replace(serializers.deserialize(value,
              specifiedType: const FullType(Content))! as Content);
          break;
      }
    }

    return result.build();
  }
}

class _$Doc extends Doc {
  @override
  final String? id;
  @override
  final String? taskId;
  @override
  final String? connectorId;
  @override
  final String? originId;
  @override
  final String? accountId;
  @override
  final String? url;
  @override
  final String? localUrl;
  @override
  final String? type;
  @override
  final String? icon;
  @override
  final DateTime? updatedAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime? globalUpdatedAt;
  @override
  final DateTime? globalCreatedAt;
  @override
  final DateTime? remoteUpdatedAt;
  @override
  final Content? content;

  factory _$Doc([void Function(DocBuilder)? updates]) =>
      (new DocBuilder()..update(updates)).build();

  _$Doc._(
      {this.id,
      this.taskId,
      this.connectorId,
      this.originId,
      this.accountId,
      this.url,
      this.localUrl,
      this.type,
      this.icon,
      this.updatedAt,
      this.deletedAt,
      this.globalUpdatedAt,
      this.globalCreatedAt,
      this.remoteUpdatedAt,
      this.content})
      : super._();

  @override
  Doc rebuild(void Function(DocBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DocBuilder toBuilder() => new DocBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Doc &&
        id == other.id &&
        taskId == other.taskId &&
        connectorId == other.connectorId &&
        originId == other.originId &&
        accountId == other.accountId &&
        url == other.url &&
        localUrl == other.localUrl &&
        type == other.type &&
        icon == other.icon &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        globalUpdatedAt == other.globalUpdatedAt &&
        globalCreatedAt == other.globalCreatedAt &&
        remoteUpdatedAt == other.remoteUpdatedAt &&
        content == other.content;
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
                                                        $jc($jc(0, id.hashCode),
                                                            taskId.hashCode),
                                                        connectorId.hashCode),
                                                    originId.hashCode),
                                                accountId.hashCode),
                                            url.hashCode),
                                        localUrl.hashCode),
                                    type.hashCode),
                                icon.hashCode),
                            updatedAt.hashCode),
                        deletedAt.hashCode),
                    globalUpdatedAt.hashCode),
                globalCreatedAt.hashCode),
            remoteUpdatedAt.hashCode),
        content.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Doc')
          ..add('id', id)
          ..add('taskId', taskId)
          ..add('connectorId', connectorId)
          ..add('originId', originId)
          ..add('accountId', accountId)
          ..add('url', url)
          ..add('localUrl', localUrl)
          ..add('type', type)
          ..add('icon', icon)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('globalUpdatedAt', globalUpdatedAt)
          ..add('globalCreatedAt', globalCreatedAt)
          ..add('remoteUpdatedAt', remoteUpdatedAt)
          ..add('content', content))
        .toString();
  }
}

class DocBuilder implements Builder<Doc, DocBuilder> {
  _$Doc? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _taskId;
  String? get taskId => _$this._taskId;
  set taskId(String? taskId) => _$this._taskId = taskId;

  String? _connectorId;
  String? get connectorId => _$this._connectorId;
  set connectorId(String? connectorId) => _$this._connectorId = connectorId;

  String? _originId;
  String? get originId => _$this._originId;
  set originId(String? originId) => _$this._originId = originId;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _localUrl;
  String? get localUrl => _$this._localUrl;
  set localUrl(String? localUrl) => _$this._localUrl = localUrl;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  String? _icon;
  String? get icon => _$this._icon;
  set icon(String? icon) => _$this._icon = icon;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _globalUpdatedAt;
  DateTime? get globalUpdatedAt => _$this._globalUpdatedAt;
  set globalUpdatedAt(DateTime? globalUpdatedAt) =>
      _$this._globalUpdatedAt = globalUpdatedAt;

  DateTime? _globalCreatedAt;
  DateTime? get globalCreatedAt => _$this._globalCreatedAt;
  set globalCreatedAt(DateTime? globalCreatedAt) =>
      _$this._globalCreatedAt = globalCreatedAt;

  DateTime? _remoteUpdatedAt;
  DateTime? get remoteUpdatedAt => _$this._remoteUpdatedAt;
  set remoteUpdatedAt(DateTime? remoteUpdatedAt) =>
      _$this._remoteUpdatedAt = remoteUpdatedAt;

  ContentBuilder? _content;
  ContentBuilder get content => _$this._content ??= new ContentBuilder();
  set content(ContentBuilder? content) => _$this._content = content;

  DocBuilder();

  DocBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _taskId = $v.taskId;
      _connectorId = $v.connectorId;
      _originId = $v.originId;
      _accountId = $v.accountId;
      _url = $v.url;
      _localUrl = $v.localUrl;
      _type = $v.type;
      _icon = $v.icon;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _globalUpdatedAt = $v.globalUpdatedAt;
      _globalCreatedAt = $v.globalCreatedAt;
      _remoteUpdatedAt = $v.remoteUpdatedAt;
      _content = $v.content?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Doc other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Doc;
  }

  @override
  void update(void Function(DocBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Doc build() {
    _$Doc _$result;
    try {
      _$result = _$v ??
          new _$Doc._(
              id: id,
              taskId: taskId,
              connectorId: connectorId,
              originId: originId,
              accountId: accountId,
              url: url,
              localUrl: localUrl,
              type: type,
              icon: icon,
              updatedAt: updatedAt,
              deletedAt: deletedAt,
              globalUpdatedAt: globalUpdatedAt,
              globalCreatedAt: globalCreatedAt,
              remoteUpdatedAt: remoteUpdatedAt,
              content: _content?.build());
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'content';
        _content?.build();
      } catch (e) {
        throw new BuiltValueNestedFieldError(
            'Doc', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
