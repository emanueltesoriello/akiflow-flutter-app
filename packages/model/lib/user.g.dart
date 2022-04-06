// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as int?,
      chargebeeId: json['chargebee_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      plan: json['plan'] as String?,
      planExpireDate: json['plan_expire_date'] == null
          ? null
          : DateTime.parse(json['plan_expire_date'] as String),
      status: json['status'] as String?,
      hasPaymentMethod: json['has_payment_method'] as int?,
      channel: json['channel'] as String?,
      referral: json['referral'] as String?,
      referralUrl: json['referral_url'] as String?,
      lastUpdatedNote: json['last_updated_note'] == null
          ? null
          : DateTime.parse(json['last_updated_note'] as String),
      autologin: json['autologin'] as String?,
      autologincode: json['autologincode'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      emailEnabled: json['email_enabled'] as bool?,
      onboardingAnsweredTools:
          (json['onboarding_answered_tools'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
      accessToken: json['access_token'] as String?,
      refreshToken: json['refresh_token'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'chargebee_id': instance.chargebeeId,
      'name': instance.name,
      'email': instance.email,
      'plan': instance.plan,
      'plan_expire_date': instance.planExpireDate?.toIso8601String(),
      'status': instance.status,
      'has_payment_method': instance.hasPaymentMethod,
      'channel': instance.channel,
      'referral': instance.referral,
      'referral_url': instance.referralUrl,
      'last_updated_note': instance.lastUpdatedNote?.toIso8601String(),
      'autologin': instance.autologin,
      'autologincode': instance.autologincode,
      'created_at': instance.createdAt?.toIso8601String(),
      'email_enabled': instance.emailEnabled,
      'onboarding_answered_tools': instance.onboardingAnsweredTools,
      'token_type': instance.tokenType,
      'expires_in': instance.expiresIn,
      'access_token': instance.accessToken,
      'refresh_token': instance.refreshToken,
    };
