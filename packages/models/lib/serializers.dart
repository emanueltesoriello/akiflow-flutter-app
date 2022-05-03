import 'package:built_collection/built_collection.dart';
import 'package:built_value/serializer.dart';
import 'package:built_value/standard_json_plugin.dart';
import 'package:models/account/account.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/content.dart';
import 'package:models/datetime_serializer.dart';
import 'package:models/doc/doc.dart';
import 'package:models/event/event.dart';
import 'package:models/label/label.dart';
import 'package:models/user.dart';

import 'task/task.dart';

part 'serializers.g.dart';

@SerializersFor([User, Task, Account, Calendar, Label, Event, Doc, Content])
final Serializers serializers = (_$serializers.toBuilder()
      ..add(DateTimeSerializer())
      ..addPlugin(StandardJsonPlugin()))
    .build();
