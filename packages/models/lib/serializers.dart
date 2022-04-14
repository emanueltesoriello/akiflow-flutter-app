import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:models/account/account.dart';
import 'package:models/account/local_details.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/calendar/settings.dart';
import 'package:models/datetime_serializer.dart';
import 'package:models/label/label.dart';
import 'package:models/task/content.dart';
import 'package:models/user.dart';

import 'task/task.dart';

part 'serializers.g.dart';

@SerializersFor(
    [User, Task, Content, Account, LocalDetails, Calendar, Settings, Label])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
