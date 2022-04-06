// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

Serializer<User> _$userSerializer = new _$UserSerializer();

class _$UserSerializer implements StructuredSerializer<User> {
  @override
  final Iterable<Type> types = const [User, _$User];
  @override
  final String wireName = 'User';

  @override
  Iterable<Object?> serialize(Serializers serializers, User object,
      {FullType specifiedType = FullType.unspecified}) {
    final result = <Object?>[];
    Object? value;
    value = object.id;
    if (value != null) {
      result
        ..add('id')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.chargebeeId;
    if (value != null) {
      result
        ..add('chargebee_id')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.name;
    if (value != null) {
      result
        ..add('name')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.email;
    if (value != null) {
      result
        ..add('email')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.plan;
    if (value != null) {
      result
        ..add('plan')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.planExpireDate;
    if (value != null) {
      result
        ..add('plan_expire_date')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.status;
    if (value != null) {
      result
        ..add('status')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.hasPaymentMethod;
    if (value != null) {
      result
        ..add('has_payment_method')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.channel;
    if (value != null) {
      result
        ..add('channel')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.referral;
    if (value != null) {
      result
        ..add('referral')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.referralUrl;
    if (value != null) {
      result
        ..add('referral_url')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.lastUpdatedNote;
    if (value != null) {
      result
        ..add('last_updated_note')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.autologin;
    if (value != null) {
      result
        ..add('autologin')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.autologincode;
    if (value != null) {
      result
        ..add('autologincode')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.createdAt;
    if (value != null) {
      result
        ..add('created_at')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(DateTime)));
    }
    value = object.emailEnabled;
    if (value != null) {
      result
        ..add('email_enabled')
        ..add(
            serializers.serialize(value, specifiedType: const FullType(bool)));
    }
    value = object.onboardingAnsweredTools;
    if (value != null) {
      result
        ..add('onboarding_answered_tools')
        ..add(serializers.serialize(value,
            specifiedType:
                const FullType(List, const [const FullType(String)])));
    }
    value = object.tokenType;
    if (value != null) {
      result
        ..add('token_type')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.expiresIn;
    if (value != null) {
      result
        ..add('expires_in')
        ..add(serializers.serialize(value, specifiedType: const FullType(int)));
    }
    value = object.accessToken;
    if (value != null) {
      result
        ..add('access_token')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    value = object.refreshToken;
    if (value != null) {
      result
        ..add('refresh_token')
        ..add(serializers.serialize(value,
            specifiedType: const FullType(String)));
    }
    return result;
  }

  @override
  User deserialize(Serializers serializers, Iterable<Object?> serialized,
      {FullType specifiedType = FullType.unspecified}) {
    final result = new UserBuilder();

    final iterator = serialized.iterator;
    while (iterator.moveNext()) {
      final key = iterator.current as String;
      iterator.moveNext();
      final Object? value = iterator.current;
      switch (key) {
        case 'id':
          result.id = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'chargebee_id':
          result.chargebeeId = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'name':
          result.name = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'email':
          result.email = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'plan':
          result.plan = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'plan_expire_date':
          result.planExpireDate = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'status':
          result.status = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'has_payment_method':
          result.hasPaymentMethod = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'channel':
          result.channel = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'referral':
          result.referral = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'referral_url':
          result.referralUrl = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'last_updated_note':
          result.lastUpdatedNote = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'autologin':
          result.autologin = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'autologincode':
          result.autologincode = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'created_at':
          result.createdAt = serializers.deserialize(value,
              specifiedType: const FullType(DateTime)) as DateTime?;
          break;
        case 'email_enabled':
          result.emailEnabled = serializers.deserialize(value,
              specifiedType: const FullType(bool)) as bool?;
          break;
        case 'onboarding_answered_tools':
          result.onboardingAnsweredTools = serializers.deserialize(value,
                  specifiedType:
                      const FullType(List, const [const FullType(String)]))
              as List<String>?;
          break;
        case 'token_type':
          result.tokenType = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'expires_in':
          result.expiresIn = serializers.deserialize(value,
              specifiedType: const FullType(int)) as int?;
          break;
        case 'access_token':
          result.accessToken = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
        case 'refresh_token':
          result.refreshToken = serializers.deserialize(value,
              specifiedType: const FullType(String)) as String?;
          break;
      }
    }

    return result.build();
  }
}

class _$User extends User {
  @override
  final int? id;
  @override
  final String? chargebeeId;
  @override
  final String? name;
  @override
  final String? email;
  @override
  final String? plan;
  @override
  final DateTime? planExpireDate;
  @override
  final String? status;
  @override
  final int? hasPaymentMethod;
  @override
  final String? channel;
  @override
  final String? referral;
  @override
  final String? referralUrl;
  @override
  final DateTime? lastUpdatedNote;
  @override
  final String? autologin;
  @override
  final String? autologincode;
  @override
  final DateTime? createdAt;
  @override
  final bool? emailEnabled;
  @override
  final List<String>? onboardingAnsweredTools;
  @override
  final String? tokenType;
  @override
  final int? expiresIn;
  @override
  final String? accessToken;
  @override
  final String? refreshToken;

  factory _$User([void Function(UserBuilder)? updates]) =>
      (new UserBuilder()..update(updates)).build();

  _$User._(
      {this.id,
      this.chargebeeId,
      this.name,
      this.email,
      this.plan,
      this.planExpireDate,
      this.status,
      this.hasPaymentMethod,
      this.channel,
      this.referral,
      this.referralUrl,
      this.lastUpdatedNote,
      this.autologin,
      this.autologincode,
      this.createdAt,
      this.emailEnabled,
      this.onboardingAnsweredTools,
      this.tokenType,
      this.expiresIn,
      this.accessToken,
      this.refreshToken})
      : super._();

  @override
  User rebuild(void Function(UserBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserBuilder toBuilder() => new UserBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is User &&
        id == other.id &&
        chargebeeId == other.chargebeeId &&
        name == other.name &&
        email == other.email &&
        plan == other.plan &&
        planExpireDate == other.planExpireDate &&
        status == other.status &&
        hasPaymentMethod == other.hasPaymentMethod &&
        channel == other.channel &&
        referral == other.referral &&
        referralUrl == other.referralUrl &&
        lastUpdatedNote == other.lastUpdatedNote &&
        autologin == other.autologin &&
        autologincode == other.autologincode &&
        createdAt == other.createdAt &&
        emailEnabled == other.emailEnabled &&
        onboardingAnsweredTools == other.onboardingAnsweredTools &&
        tokenType == other.tokenType &&
        expiresIn == other.expiresIn &&
        accessToken == other.accessToken &&
        refreshToken == other.refreshToken;
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
                                                                            $jc($jc($jc(0, id.hashCode), chargebeeId.hashCode),
                                                                                name.hashCode),
                                                                            email.hashCode),
                                                                        plan.hashCode),
                                                                    planExpireDate.hashCode),
                                                                status.hashCode),
                                                            hasPaymentMethod.hashCode),
                                                        channel.hashCode),
                                                    referral.hashCode),
                                                referralUrl.hashCode),
                                            lastUpdatedNote.hashCode),
                                        autologin.hashCode),
                                    autologincode.hashCode),
                                createdAt.hashCode),
                            emailEnabled.hashCode),
                        onboardingAnsweredTools.hashCode),
                    tokenType.hashCode),
                expiresIn.hashCode),
            accessToken.hashCode),
        refreshToken.hashCode));
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper('User')
          ..add('id', id)
          ..add('chargebeeId', chargebeeId)
          ..add('name', name)
          ..add('email', email)
          ..add('plan', plan)
          ..add('planExpireDate', planExpireDate)
          ..add('status', status)
          ..add('hasPaymentMethod', hasPaymentMethod)
          ..add('channel', channel)
          ..add('referral', referral)
          ..add('referralUrl', referralUrl)
          ..add('lastUpdatedNote', lastUpdatedNote)
          ..add('autologin', autologin)
          ..add('autologincode', autologincode)
          ..add('createdAt', createdAt)
          ..add('emailEnabled', emailEnabled)
          ..add('onboardingAnsweredTools', onboardingAnsweredTools)
          ..add('tokenType', tokenType)
          ..add('expiresIn', expiresIn)
          ..add('accessToken', accessToken)
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class UserBuilder implements Builder<User, UserBuilder> {
  _$User? _$v;

  int? _id;
  int? get id => _$this._id;
  set id(int? id) => _$this._id = id;

  String? _chargebeeId;
  String? get chargebeeId => _$this._chargebeeId;
  set chargebeeId(String? chargebeeId) => _$this._chargebeeId = chargebeeId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _plan;
  String? get plan => _$this._plan;
  set plan(String? plan) => _$this._plan = plan;

  DateTime? _planExpireDate;
  DateTime? get planExpireDate => _$this._planExpireDate;
  set planExpireDate(DateTime? planExpireDate) =>
      _$this._planExpireDate = planExpireDate;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  int? _hasPaymentMethod;
  int? get hasPaymentMethod => _$this._hasPaymentMethod;
  set hasPaymentMethod(int? hasPaymentMethod) =>
      _$this._hasPaymentMethod = hasPaymentMethod;

  String? _channel;
  String? get channel => _$this._channel;
  set channel(String? channel) => _$this._channel = channel;

  String? _referral;
  String? get referral => _$this._referral;
  set referral(String? referral) => _$this._referral = referral;

  String? _referralUrl;
  String? get referralUrl => _$this._referralUrl;
  set referralUrl(String? referralUrl) => _$this._referralUrl = referralUrl;

  DateTime? _lastUpdatedNote;
  DateTime? get lastUpdatedNote => _$this._lastUpdatedNote;
  set lastUpdatedNote(DateTime? lastUpdatedNote) =>
      _$this._lastUpdatedNote = lastUpdatedNote;

  String? _autologin;
  String? get autologin => _$this._autologin;
  set autologin(String? autologin) => _$this._autologin = autologin;

  String? _autologincode;
  String? get autologincode => _$this._autologincode;
  set autologincode(String? autologincode) =>
      _$this._autologincode = autologincode;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  bool? _emailEnabled;
  bool? get emailEnabled => _$this._emailEnabled;
  set emailEnabled(bool? emailEnabled) => _$this._emailEnabled = emailEnabled;

  List<String>? _onboardingAnsweredTools;
  List<String>? get onboardingAnsweredTools => _$this._onboardingAnsweredTools;
  set onboardingAnsweredTools(List<String>? onboardingAnsweredTools) =>
      _$this._onboardingAnsweredTools = onboardingAnsweredTools;

  String? _tokenType;
  String? get tokenType => _$this._tokenType;
  set tokenType(String? tokenType) => _$this._tokenType = tokenType;

  int? _expiresIn;
  int? get expiresIn => _$this._expiresIn;
  set expiresIn(int? expiresIn) => _$this._expiresIn = expiresIn;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  UserBuilder();

  UserBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _chargebeeId = $v.chargebeeId;
      _name = $v.name;
      _email = $v.email;
      _plan = $v.plan;
      _planExpireDate = $v.planExpireDate;
      _status = $v.status;
      _hasPaymentMethod = $v.hasPaymentMethod;
      _channel = $v.channel;
      _referral = $v.referral;
      _referralUrl = $v.referralUrl;
      _lastUpdatedNote = $v.lastUpdatedNote;
      _autologin = $v.autologin;
      _autologincode = $v.autologincode;
      _createdAt = $v.createdAt;
      _emailEnabled = $v.emailEnabled;
      _onboardingAnsweredTools = $v.onboardingAnsweredTools;
      _tokenType = $v.tokenType;
      _expiresIn = $v.expiresIn;
      _accessToken = $v.accessToken;
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(User other) {
    ArgumentError.checkNotNull(other, 'other');
    _$v = other as _$User;
  }

  @override
  void update(void Function(UserBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  _$User build() {
    final _$result = _$v ??
        new _$User._(
            id: id,
            chargebeeId: chargebeeId,
            name: name,
            email: email,
            plan: plan,
            planExpireDate: planExpireDate,
            status: status,
            hasPaymentMethod: hasPaymentMethod,
            channel: channel,
            referral: referral,
            referralUrl: referralUrl,
            lastUpdatedNote: lastUpdatedNote,
            autologin: autologin,
            autologincode: autologincode,
            createdAt: createdAt,
            emailEnabled: emailEnabled,
            onboardingAnsweredTools: onboardingAnsweredTools,
            tokenType: tokenType,
            expiresIn: expiresIn,
            accessToken: accessToken,
            refreshToken: refreshToken);
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: always_put_control_body_on_new_line,always_specify_types,annotate_overrides,avoid_annotating_with_dynamic,avoid_as,avoid_catches_without_on_clauses,avoid_returning_this,deprecated_member_use_from_same_package,lines_longer_than_80_chars,omit_local_variable_types,prefer_expression_function_bodies,sort_constructors_first,test_types_in_equals,unnecessary_const,unnecessary_new
