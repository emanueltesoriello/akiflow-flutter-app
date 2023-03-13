import 'package:flutter/material.dart';

class NLPDateTime {
  String? textWithDate;
  String? textWithoutDate;
  bool? hasTime;
  bool? hasDate;
  bool? hasMeridiem;
  int? day;
  int? month;
  int? year;
  int? hour;
  int? minute;

  NLPDateTime(
      {this.textWithDate,
      this.textWithoutDate,
      this.hasTime,
      this.hasDate,
      this.hasMeridiem,
      this.day,
      this.month,
      this.year,
      this.hour,
      this.minute});

  factory NLPDateTime.fromMap(Map<dynamic, dynamic> json) => NLPDateTime(
        textWithDate: json['parseResult']?['text'],
        textWithoutDate: json['textWithoutDate'] as String?,
        hasTime: json['hasTime'] as bool?,
        hasDate: json['hasDate'] as bool?,
        hasMeridiem: json['hasMeridiem'] as bool?,
        day: json['parseResult']?['start']?['knownValues']?['day'] as int?,
        month: json['parseResult']?['start']?['knownValues']?['month'] as int?,
        year: json['parseResult']?['start']?['knownValues']?['year'] as int?,
        hour: json['parseResult']?['start']?['knownValues']?['hour'] as int?,
        minute: json['parseResult']?['start']?['knownValues']?['minute'] as int?,
      );

  Map<dynamic, dynamic> toMap() => {
        'textWithDate': textWithDate,
        'textWithoutDate': textWithoutDate,
        'hasTime': hasTime,
        'hasDate': hasDate,
        'hasMeridiem': hasMeridiem,
        'day': day,
        'month': month,
        'year': year,
        'hour': hour,
        'minute': minute
      };

  DateTime? getDate() {
    DateTime? dateTime;
    try {
      if (hasDate ?? false) {
        dateTime = DateTime(year!, month!, day!);
      }
    } catch (e) {
      print('No date');
    }
    return dateTime;
  }

  TimeOfDay? getTime() {
    TimeOfDay? timeOfDay;
    try {
      if (hasTime ?? false) {
        timeOfDay = TimeOfDay(hour: hour!, minute: minute!);
      }
    } catch (e) {
      print('No time');
    }
    return timeOfDay;
  }

  NLPDateTime copyWith({
    String? textWithDate,
    String? textWithoutDate,
    bool? hasTime,
    bool? hasDate,
    bool? hasMeridiem,
    int? day,
    int? month,
    int? year,
    int? hour,
    int? minute,
  }) {
    return NLPDateTime(
        textWithDate: textWithDate ?? this.textWithDate,
        textWithoutDate: textWithoutDate ?? this.textWithoutDate,
        day: day ?? this.day,
        hasDate: hasDate ?? this.hasDate,
        hasMeridiem: hasMeridiem ?? this.hasMeridiem,
        hasTime: hasTime ?? this.hasTime,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        month: month ?? this.month,
        year: year ?? this.year);
  }
}
