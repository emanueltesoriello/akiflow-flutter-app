// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int? id;
  final String? chargebeeId;
  final String? name;
  final String? email;
  final String? plan;
  final DateTime? planExpireDate;
  final String? status;
  final int? hasPaymentMethod;
  final String? channel;
  final String? referral;
  final String? referralUrl;
  final DateTime? lastUpdatedNote;
  final String? autologin;
  final String? autologincode;
  final DateTime? createdAt;
  final bool? emailEnabled;
  final List<String>? onboardingAnsweredTools;
  final String? tokenType;
  final int? expiresIn;
  final String? accessToken;
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

  User copyWith({
    int? id,
    String? chargebeeId,
    String? name,
    String? email,
    String? plan,
    DateTime? planExpireDate,
    String? status,
    int? hasPaymentMethod,
    String? channel,
    String? referral,
    String? referralUrl,
    DateTime? lastUpdatedNote,
    String? autologin,
    String? autologincode,
    DateTime? createdAt,
    bool? emailEnabled,
    List<String>? onboardingAnsweredTools,
    String? tokenType,
    int? expiresIn,
    String? accessToken,
    String? refreshToken,
  }) {
    return User(
      id: id ?? this.id,
      chargebeeId: chargebeeId ?? this.chargebeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      planExpireDate: planExpireDate ?? this.planExpireDate,
      status: status ?? this.status,
      hasPaymentMethod: hasPaymentMethod ?? this.hasPaymentMethod,
      channel: channel ?? this.channel,
      referral: referral ?? this.referral,
      referralUrl: referralUrl ?? this.referralUrl,
      lastUpdatedNote: lastUpdatedNote ?? this.lastUpdatedNote,
      autologin: autologin ?? this.autologin,
      autologincode: autologincode ?? this.autologincode,
      createdAt: createdAt ?? this.createdAt,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      onboardingAnsweredTools:
          onboardingAnsweredTools ?? this.onboardingAnsweredTools,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'chargebee_id': chargebeeId,
      'name': name,
      'email': email,
      'plan': plan,
      'plan_expire_date': planExpireDate?.millisecondsSinceEpoch,
      'status': status,
      'has_payment_method': hasPaymentMethod,
      'channel': channel,
      'referral': referral,
      'referral_url': referralUrl,
      'last_updated_note': lastUpdatedNote?.millisecondsSinceEpoch,
      'autologin': autologin,
      'autologincode': autologincode,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'email_enabled': emailEnabled,
      'onboarding_answered_tools': onboardingAnsweredTools,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'access_token': accessToken,
      'refresh_token': refreshToken,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] != null ? map['id'] as int : null,
      chargebeeId:
          map['chargebee_id'] != null ? map['chargebee_id'] as String : null,
      name: map['name'] != null ? map['name'] as String : null,
      email: map['email'] != null ? map['email'] as String : null,
      plan: map['plan'] != null ? map['plan'] as String : null,
      planExpireDate:
          map['plan_expire_date'] != null && map['plan_expire_date'] is String
              ? DateTime.tryParse(map['plan_expire_date'] as String)
              : null,
      status: map['status'] != null ? map['status'] as String : null,
      hasPaymentMethod: map['has_payment_method'] != null
          ? map['has_payment_method'] as int
          : null,
      channel: map['channel'] != null ? map['channel'] as String : null,
      referral: map['referral'] != null ? map['referral'] as String : null,
      referralUrl:
          map['referral_url'] != null ? map['referral_url'] as String : null,
      lastUpdatedNote:
          map['last_updated_note'] != null && map['last_updated_note'] is String
              ? DateTime.tryParse(map['last_updated_note'] as String)
              : null,
      autologin: map['autologin'] != null ? map['autologin'] as String : null,
      autologincode:
          map['autologincode'] != null ? map['autologincode'] as String : null,
      createdAt: map['created_at'] != null && map['created_at'] is String
          ? DateTime.tryParse(map['created_at'] as String)
          : null,
      emailEnabled:
          map['email_enabled'] != null ? map['email_enabled'] as bool : null,
      onboardingAnsweredTools: map['onboarding_answered_tools'] != null
          ? List<String>.from(
              (map['onboarding_answered_tools'] as List<String>))
          : null,
      tokenType: map['token_type'] != null ? map['token_type'] as String : null,
      expiresIn: map['expires_in'] != null ? map['expires_in'] as int : null,
      accessToken:
          map['access_token'] != null ? map['access_token'] as String : null,
      refreshToken:
          map['refresh_token'] != null ? map['refresh_token'] as String : null,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      chargebeeId,
      name,
      email,
      plan,
      planExpireDate,
      status,
      hasPaymentMethod,
      channel,
      referral,
      referralUrl,
      lastUpdatedNote,
      autologin,
      autologincode,
      createdAt,
      emailEnabled,
      onboardingAnsweredTools,
      tokenType,
      expiresIn,
      accessToken,
      refreshToken,
    ];
  }
}
