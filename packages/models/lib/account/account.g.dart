// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<Account> _$accountSerializer = new _$AccountSerializer();

class _$AccountSerializer implements StructuredSerializer<Account> {
  @override
  final Iterable<Type> types = const [Account, _$Account];
  @override
  final String wireName = 'Account';

  @override
  Iterable<Object?> serialize(Serializers serializers, Account object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.id;

    result
      ..add('id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.connectorId;

    result
      ..add('connector_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.accountId;

    result
      ..add('account_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.originAccountId;

    result
      ..add('origin_account_id')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.shortName;

    result
      ..add('short_name')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.fullName;

    result
      ..add('full_name')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.picture;

    result
      ..add('picture')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.identifier;

    result
      ..add('identifier')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.autologinToken;

    result
      ..add('autologin_token')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.status;

    result
      ..add('status')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
    value = object.syncStatus;

    result
      ..add('sync_status')
      ..add(
          serializers.serialize(value, specifiedType: const FullType(String)));
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

    return result;
  }

  @override
  Account deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new AccountBuilder();

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
        case 'connector_id':
          result.connectorId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'account_id':
          result.accountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'origin_account_id':
          result.originAccountId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'short_name':
          result.shortName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'full_name':
          result.fullName = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'picture':
          result.picture = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'identifier':
          result.identifier = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'autologin_token':
          result.autologinToken = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'sync_status':
          result.syncStatus = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
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
      }
    }

    return result.build();
  }
}

class _$Account extends Account {
  @override
  final String? id;
  @override
  final String? connectorId;
  @override
  final String? accountId;
  @override
  final String? originAccountId;
  @override
  final String? shortName;
  @override
  final String? fullName;
  @override
  final String? picture;
  @override
  final String? identifier;
  @override
  final String? autologinToken;
  @override
  final String? status;
  @override
  final String? syncStatus;
  @override
  final DateTime? createdAt;
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

  factory _$Account([void Function(AccountBuilder)? updates]) =>
      (new AccountBuilder()..update(updates)).build();

  _$Account._(
      {this.id,
      this.connectorId,
      this.accountId,
      this.originAccountId,
      this.shortName,
      this.fullName,
      this.picture,
      this.identifier,
      this.autologinToken,
      this.status,
      this.syncStatus,
      this.createdAt,
      this.updatedAt,
      this.deletedAt,
      this.globalUpdatedAt,
      this.globalCreatedAt,
      this.remoteUpdatedAt})
      : super._();

  @override
  Account rebuild(void Function(AccountBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AccountBuilder toBuilder() => new AccountBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Account &&
        id == other.id &&
        connectorId == other.connectorId &&
        accountId == other.accountId &&
        originAccountId == other.originAccountId &&
        shortName == other.shortName &&
        fullName == other.fullName &&
        picture == other.picture &&
        identifier == other.identifier &&
        autologinToken == other.autologinToken &&
        status == other.status &&
        syncStatus == other.syncStatus &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        globalUpdatedAt == other.globalUpdatedAt &&
        globalCreatedAt == other.globalCreatedAt &&
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
                                                                        0,
                                                                        id
                                                                            .hashCode),
                                                                    connectorId
                                                                        .hashCode),
                                                                accountId
                                                                    .hashCode),
                                                            originAccountId
                                                                .hashCode),
                                                        shortName.hashCode),
                                                    fullName.hashCode),
                                                picture.hashCode),
                                            identifier.hashCode),
                                        autologinToken.hashCode),
                                    status.hashCode),
                                syncStatus.hashCode),
                            createdAt.hashCode),
                        updatedAt.hashCode),
                    deletedAt.hashCode),
                globalUpdatedAt.hashCode),
            globalCreatedAt.hashCode),
        remoteUpdatedAt.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('Account')
          ..add('id', id)
          ..add('connectorId', connectorId)
          ..add('accountId', accountId)
          ..add('originAccountId', originAccountId)
          ..add('shortName', shortName)
          ..add('fullName', fullName)
          ..add('picture', picture)
          ..add('identifier', identifier)
          ..add('autologinToken', autologinToken)
          ..add('status', status)
          ..add('syncStatus', syncStatus)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('deletedAt', deletedAt)
          ..add('globalUpdatedAt', globalUpdatedAt)
          ..add('globalCreatedAt', globalCreatedAt)
          ..add('remoteUpdatedAt', remoteUpdatedAt))
        .toString();
  }
}

class AccountBuilder implements Builder<Account, AccountBuilder> {
  _$Account? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _connectorId;
  String? get connectorId => _$this._connectorId;
  set connectorId(String? connectorId) => _$this._connectorId = connectorId;

  String? _accountId;
  String? get accountId => _$this._accountId;
  set accountId(String? accountId) => _$this._accountId = accountId;

  String? _originAccountId;
  String? get originAccountId => _$this._originAccountId;
  set originAccountId(String? originAccountId) =>
      _$this._originAccountId = originAccountId;

  String? _shortName;
  String? get shortName => _$this._shortName;
  set shortName(String? shortName) => _$this._shortName = shortName;

  String? _fullName;
  String? get fullName => _$this._fullName;
  set fullName(String? fullName) => _$this._fullName = fullName;

  String? _picture;
  String? get picture => _$this._picture;
  set picture(String? picture) => _$this._picture = picture;

  String? _identifier;
  String? get identifier => _$this._identifier;
  set identifier(String? identifier) => _$this._identifier = identifier;

  String? _autologinToken;
  String? get autologinToken => _$this._autologinToken;
  set autologinToken(String? autologinToken) =>
      _$this._autologinToken = autologinToken;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _syncStatus;
  String? get syncStatus => _$this._syncStatus;
  set syncStatus(String? syncStatus) => _$this._syncStatus = syncStatus;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

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

  AccountBuilder();

  AccountBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _connectorId = $v.connectorId;
      _accountId = $v.accountId;
      _originAccountId = $v.originAccountId;
      _shortName = $v.shortName;
      _fullName = $v.fullName;
      _picture = $v.picture;
      _identifier = $v.identifier;
      _autologinToken = $v.autologinToken;
      _status = $v.status;
      _syncStatus = $v.syncStatus;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _deletedAt = $v.deletedAt;
      _globalUpdatedAt = $v.globalUpdatedAt;
      _globalCreatedAt = $v.globalCreatedAt;
      _remoteUpdatedAt = $v.remoteUpdatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Account other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$Account;
  }

  @override
  void update(void Function(AccountBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$Account build() {
    final _$result = _$v ??
        new _$Account._(
            id: id,
            connectorId: connectorId,
            accountId: accountId,
            originAccountId: originAccountId,
            shortName: shortName,
            fullName: fullName,
            picture: picture,
            identifier: identifier,
            autologinToken: autologinToken,
            status: status,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            deletedAt: deletedAt,
            globalUpdatedAt: globalUpdatedAt,
            globalCreatedAt: globalCreatedAt,
            remoteUpdatedAt: remoteUpdatedAt);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
