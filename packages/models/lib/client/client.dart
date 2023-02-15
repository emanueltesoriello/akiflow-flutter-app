import 'package:equatable/equatable.dart';
import 'package:models/base.dart';

class Client extends Equatable implements Base {
  const Client({
    this.id,
  });

  final String? id;

  factory Client.fromMap(Map<String, dynamic> json) => Client(
        id: json['id'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'id': id,
      };

  Client copyWith({
    String? id,
  }) {
    return Client(
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Object?> toSql() {
    return {
      "id": id,
    };
  }

  static Client fromSql(Map<String?, dynamic> json) {
    Map<String, Object?> data = Map<String, Object?>.from(json);
    return Client.fromMap(data);
  }

  @override
  List<Object?> get props {
    return [
      id,
    ];
  }
}
