// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class AccountToken extends Equatable {
  final String? id;
  final String? accessToken;
  final String? refreshToken;
  final DateTime? accessTokenExpirationDateTime;
  final String? idToken;
  final String? tokenType;

  const AccountToken({
    this.id,
    this.accessToken,
    this.refreshToken,
    this.accessTokenExpirationDateTime,
    this.idToken,
    this.tokenType,
  });

  AccountToken copyWith({
    String? id,
    String? accessToken,
    String? refreshToken,
    DateTime? accessTokenExpirationDateTime,
    String? idToken,
    String? tokenType,
  }) {
    return AccountToken(
      id: id ?? this.id,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      accessTokenExpirationDateTime:
          accessTokenExpirationDateTime ?? this.accessTokenExpirationDateTime,
      idToken: idToken ?? this.idToken,
      tokenType: tokenType ?? this.tokenType,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpirationDateTime':
          accessTokenExpirationDateTime?.millisecondsSinceEpoch,
      'idToken': idToken,
      'tokenType': tokenType,
    };
  }

  factory AccountToken.fromMap(Map<String, dynamic> map) {
    return AccountToken(
      id: map['id'] != null ? map['id'] as String : null,
      accessToken:
          map['accessToken'] != null ? map['accessToken'] as String : null,
      refreshToken:
          map['refreshToken'] != null ? map['refreshToken'] as String : null,
      accessTokenExpirationDateTime:
          map['accessTokenExpirationDateTime'] != null
              ? DateTime.fromMillisecondsSinceEpoch(
                  map['accessTokenExpirationDateTime'] as int)
              : null,
      idToken: map['idToken'] != null ? map['idToken'] as String : null,
      tokenType: map['tokenType'] != null ? map['tokenType'] as String : null,
    );
  }

  @override
  List<Object?> get props {
    return [
      id,
      accessToken,
      refreshToken,
      accessTokenExpirationDateTime,
      idToken,
      tokenType,
    ];
  }
}
