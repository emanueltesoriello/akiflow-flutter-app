// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

class User extends Equatable implements Base {
  final int? id;
  final String? chargebeeId;
  final String? name;
  final String? surname;
  final String? email;
  final String? intercomHashAndroid;
  final String? intercomHashIos;
  final String? plan;
  final String? planExpireDate;
  final String? status;
  final int? hasPaymentMethod;
  final String? channel;
  final String? referral;
  final String? referralUrl;
  final String? autologin;
  final String? autologincode;
  final String? createdAt;
  final bool? emailEnabled;
  final List<String>? onboardingAnsweredTools;
  final String? tokenType;
  final int? expiresIn;
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic>? settings;

  const User({
    this.id,
    this.chargebeeId,
    this.name,
    this.surname,
    this.email,
    this.intercomHashAndroid,
    this.intercomHashIos,
    this.plan,
    this.planExpireDate,
    this.status,
    this.hasPaymentMethod,
    this.channel,
    this.referral,
    this.referralUrl,
    this.autologin,
    this.autologincode,
    this.createdAt,
    this.emailEnabled,
    this.onboardingAnsweredTools,
    this.tokenType,
    this.expiresIn,
    this.accessToken,
    this.refreshToken,
    this.settings,
  });

  User copyWith({
    int? id,
    String? chargebeeId,
    String? name,
    String? surname,
    String? email,
    String? intercomHashAndroid,
    String? intercomHashIos,
    String? plan,
    String? planExpireDate,
    String? status,
    int? hasPaymentMethod,
    String? channel,
    String? referral,
    String? referralUrl,
    String? lastUpdatedNote,
    String? autologin,
    String? autologincode,
    String? createdAt,
    bool? emailEnabled,
    List<String>? onboardingAnsweredTools,
    String? tokenType,
    int? expiresIn,
    String? accessToken,
    String? refreshToken,
    Map<String, dynamic>? settings,
  }) {
    return User(
      id: id ?? this.id,
      chargebeeId: chargebeeId ?? this.chargebeeId,
      name: name ?? this.name,
      surname: surname ?? this.surname,
      email: email ?? this.email,
      intercomHashAndroid: intercomHashAndroid ?? this.intercomHashAndroid,
      intercomHashIos: intercomHashIos ?? this.intercomHashIos,
      plan: plan ?? this.plan,
      planExpireDate: planExpireDate ?? this.planExpireDate,
      status: status ?? this.status,
      hasPaymentMethod: hasPaymentMethod ?? this.hasPaymentMethod,
      channel: channel ?? this.channel,
      referral: referral ?? this.referral,
      referralUrl: referralUrl ?? this.referralUrl,
      autologin: autologin ?? this.autologin,
      autologincode: autologincode ?? this.autologincode,
      createdAt: createdAt ?? this.createdAt,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      onboardingAnsweredTools: onboardingAnsweredTools ?? this.onboardingAnsweredTools,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      settings: settings ?? this.settings,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chargebee_id': chargebeeId,
      'name': name,
      'surname': surname,
      'email': email,
      'intercom_hash_android': intercomHashAndroid,
      'intercom_hash_ios': intercomHashIos,
      'plan': plan,
      'plan_expire_date': planExpireDate,
      'status': status,
      'has_payment_method': hasPaymentMethod,
      'channel': channel,
      'referral': referral,
      'referral_url': referralUrl,
      'autologin': autologin,
      'autologincode': autologincode,
      'created_at': createdAt,
      'email_enabled': emailEnabled,
      'onboarding_answered_tools': onboardingAnsweredTools,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'settings': settings,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      chargebeeId: map['chargebee_id'] != null ? map['chargebee_id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      surname: map['surname'] != null ? map['surname'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      intercomHashAndroid: map['intercom_hash_android'] != null ? map['intercom_hash_android'] as String : null,
      intercomHashIos: map['intercom_hash_ios'] != null ? map['intercom_hash_ios'] as String : null,
      plan: map['plan'] != null ? map['plan'] as String : null,
      planExpireDate: map['plan_expire_date'] != null ? map['plan_expire_date'] as String : null,
      status: map['status'] != null ? map['status'] as String : null,
      hasPaymentMethod: map['has_payment_method'] != null ? map['has_payment_method'] as int : null,
      channel: map['channel'] != null ? map['channel'] as String : null,
      referral: map['referral'] != null ? map['referral'] as String : null,
      referralUrl: map['referral_url'] != null ? map['referral_url'] as String : null,
      autologin: map['autologin'] != null ? map['autologin'] as String : null,
      autologincode: map['autologincode'] != null ? map['autologincode'] as String : null,
      createdAt: map['created_at'] != null ? map['created_at'] as String : null,
      emailEnabled: map['email_enabled'] != null ? map['email_enabled'] as bool : null,
      onboardingAnsweredTools: map['onboarding_answered_tools'] != null
          ? List<String>.from((map['onboarding_answered_tools'] as List<String>))
          : null,
      tokenType: map['tokenType'] != null ? map['tokenType'] as String : null,
      expiresIn: map['expires_in'] != null ? map['expires_in'] as int : null,
      accessToken: map['access_token'] != null ? map['access_token'] as String : null,
      refreshToken: map['refresh_token'] != null ? map['refresh_token'] as String : null,
      settings: map['settings'],
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      chargebeeId,
      name,
      surname,
      email,
      intercomHashAndroid,
      intercomHashIos,
      plan,
      planExpireDate,
      status,
      hasPaymentMethod,
      channel,
      referral,
      referralUrl,
      autologin,
      autologincode,
      createdAt,
      emailEnabled,
      onboardingAnsweredTools,
      tokenType,
      expiresIn,
      accessToken,
      refreshToken,
      settings,
    ];
  }

  @override
  Map<String, Object?> toSql() {
    return Map<String, Object?>.from(toMap());
  }
}
