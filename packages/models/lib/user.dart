import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:models/base.dart';
import 'package:models/serializers.dart';

part 'user.g.dart';

abstract class User extends Object
    with Base
    implements Built<User, UserBuilder> {
  int? get id;

  @BuiltValueField(wireName: 'chargebee_id')
  String? get chargebeeId;
  String? get name;
  String? get email;
  String? get plan;

  @BuiltValueField(wireName: 'plan_expire_date')
  DateTime? get planExpireDate;

  String? get status;

  @BuiltValueField(wireName: 'has_payment_method')
  int? get hasPaymentMethod;

  String? get channel;
  String? get referral;

  @BuiltValueField(wireName: 'referral_url')
  String? get referralUrl;

  @BuiltValueField(wireName: 'last_updated_note')
  DateTime? get lastUpdatedNote;

  String? get autologin;
  String? get autologincode;

  @BuiltValueField(wireName: 'created_at')
  DateTime? get createdAt;

  @BuiltValueField(wireName: 'email_enabled')
  bool? get emailEnabled;

  @BuiltValueField(wireName: 'onboarding_answered_tools')
  List<String>? get onboardingAnsweredTools;

  @BuiltValueField(wireName: 'token_type')
  String? get tokenType;

  @BuiltValueField(wireName: 'expires_in')
  int? get expiresIn;

  @BuiltValueField(wireName: 'access_token')
  String? get accessToken;

  @BuiltValueField(wireName: 'refresh_token')
  String? get refreshToken;

  User._();

  factory User([void Function(UserBuilder) updates]) = _$User;

  @override
  User rebuild(void Function(UserBuilder) updates);

  @override
  UserBuilder toBuilder();

  @override
  Map<String, dynamic> toMap() {
    return serializers.serializeWith(User.serializer, this)
        as Map<String, dynamic>;
  }

  static User fromMap(Map<String, dynamic> json) {
    return serializers.deserializeWith(User.serializer, json)!;
  }

  @override
  Map<String, Object?> toSql() {
    return Map<String, Object?>.from(toMap());
  }

  static Serializer<User> get serializer => _$userSerializer;
}
