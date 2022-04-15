// library settings;

// import 'package:built_value/built_value.dart';
// import 'package:built_value/serializer.dart';
// import 'package:models/base.dart';
// import 'package:models/serializers.dart';

// part 'settings.g.dart';

// abstract class Settings extends Object
//     with Base
//     implements Built<Settings, SettingsBuilder> {
//   Settings._();

//   factory Settings([Function(SettingsBuilder b) updates]) = _$Settings;

//   @BuiltValueField(wireName: 'visible')
//   bool? get visible;

//   @BuiltValueField(wireName: 'notifications_enabled')
//   bool? get notificationsEnabled;

//   static Serializer<Settings> get serializer => _$settingsSerializer;

//   @override
//   Map<String, dynamic> toMap() {
//     return serializers.serializeWith(Settings.serializer, this)
//         as Map<String, dynamic>;
//   }

//   static Settings fromMap(Map<String, dynamic> json) {
//     return serializers.deserializeWith(Settings.serializer, json)!;
//   }

//   @override
//   Map<String, Object?> toSql() {
//     Map<String?, dynamic> data = serializers.serializeWith(
//         Settings.serializer, this) as Map<String?, dynamic>;

//     for (var key in data.keys) {
//       if (data[key] is bool) {
//         data[key] = data[key] ? 1 : 0;
//       }
//     }

//     return Map<String, Object?>.from(data);
//   }

//   static Settings fromSql(Map<String?, dynamic> json) {
//     Map<String, Object?> data = Map<String, Object?>.from(json);

//     for (var key in data.keys) {
//       switch (key) {
//         case "visible":
//           data[key] = (data[key] == 1);
//           break;
//         case "notifications_enabled":
//           data[key] = (data[key] == 1);
//           break;
//         default:
//       }
//     }

//     return serializers.deserializeWith(Settings.serializer, data)!;
//   }
// }
