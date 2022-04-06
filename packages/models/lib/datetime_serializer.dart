import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';

class DateTimeSerializer implements PrimitiveSerializer<DateTime?> {
  final bool structured = false;
  @override
  final Iterable<Type> types = BuiltList<Type>([DateTime]);
  @override
  final String wireName = 'DateTime';

  @override
  Object serialize(Serializers serializers, DateTime? date,
      {FullType specifiedType = FullType.unspecified}) {
    return date?.toIso8601String() as Object;
  }

  @override
  DateTime? deserialize(Serializers serializers, Object serialized,
      {FullType specifiedType = FullType.unspecified}) {
    if (serialized is String) {
      return DateTime?.tryParse(serialized);
    } else if (serialized is int) {
      return DateTime.fromMicrosecondsSinceEpoch(serialized);
    } else {
      return serialized as DateTime;
    }
  }
}
