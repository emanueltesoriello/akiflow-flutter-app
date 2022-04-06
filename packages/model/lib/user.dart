// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;

  @JsonKey(name: 'chargebee_id')
  final String? chargebeeId;
  final String? name;
  final String? email;
  final String? plan;

  @JsonKey(name: 'plan_expire_date')
  final DateTime? planExpireDate;

  final String? status;

  @JsonKey(name: 'has_payment_method')
  final int? hasPaymentMethod;

  final String? channel;
  final String? referral;

  @JsonKey(name: 'referral_url')
  final String? referralUrl;

  @JsonKey(name: 'last_updated_note')
  final DateTime? lastUpdatedNote;
  final String? autologin;
  final String? autologincode;

  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  @JsonKey(name: 'email_enabled')
  final bool? emailEnabled;

  @JsonKey(name: 'onboarding_answered_tools')
  final List<String>? onboardingAnsweredTools;

  @JsonKey(name: 'token_type')
  final String? tokenType;

  @JsonKey(name: 'expires_in')
  final int? expiresIn;

  @JsonKey(name: 'access_token')
  final String? accessToken;

  @JsonKey(name: 'refresh_token')
  final String? refreshToken;

  const User({
    this.id,
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
    this.refreshToken,
  });

  factory User.fromMap(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toMap() => _$UserToJson(this);
}
