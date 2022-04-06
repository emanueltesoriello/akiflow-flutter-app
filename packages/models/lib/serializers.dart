import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:models/datetime_serializer.dart';
import 'package:models/user.dart';

part 'serializers.g.dart';

@SerializersFor([User])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
