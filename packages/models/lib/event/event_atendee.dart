import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

class EventAtendee extends Equatable implements Base {
  const EventAtendee({this.email, this.responseStatus, this.self, this.organizer, this.displayName});

  final String? email;
  final String? responseStatus;
  final bool? self;
  final bool? organizer;
  final String? displayName;

  EventAtendee copyWith({
    final String? email,
    final String? responseStatus,
    final bool? self,
    final bool? organizer,
    final String? displayName,
  }) {
    return EventAtendee(
      email: email ?? this.email,
      responseStatus: responseStatus ?? this.responseStatus,
      self: self ?? this.self,
      organizer: organizer ?? this.organizer,
      displayName: displayName ?? this.displayName,
    );
  }

  factory EventAtendee.fromMap(Map<String, dynamic> map) => EventAtendee(
        email: map['email'] as String?,
        responseStatus: map['responseStatus'] as String?,
        self: map['self'] as bool?,
        organizer: map['organizer'] as bool?,
        displayName: map['displayName'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'responseStatus': responseStatus,
        'self': self,
        'organizer':organizer,
        'displayName': displayName,
      };

  @override
  Map<String, Object?> toSql() {
    return {
      "email": email,
      "responseStatus": responseStatus,
      "self": self,
      "displayName": displayName,
    };
  }

  static EventAtendee fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);

    return EventAtendee.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [email, responseStatus, self, displayName];
  }
}
