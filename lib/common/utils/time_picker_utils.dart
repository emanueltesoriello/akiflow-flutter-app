import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/custom_time_picker.dart';

class TimePickerUtils {
  static Future<void> pick(
    BuildContext context, {
    required TimeOfDay initialTime,
    required Function(TimeOfDay?) onTimeSelected,
  }) async {

    // switch (theme.platform) {
    // case TargetPlatform.iOS:
    // case TargetPlatform.macOS:
    // _buildCupertinoDatePicker(context, initialTime, onTimeSelected: onTimeSelected);
    // onTimeSelected(selected);
    //    break;
    //   default:
    _buildMaterialDatePicker(context, initialTime, onTimeSelected: onTimeSelected);
    onTimeSelected(selected);
    //   break;
    // }
  }

  final _timePickerTheme = TimePickerThemeData(
    backgroundColor: Colors.blueGrey,
    hourMinuteShape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Colors.orange, width: 4),
    ),
    dayPeriodBorderSide: const BorderSide(color: Colors.orange, width: 4),
    dayPeriodColor: Colors.blueGrey.shade600,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Colors.orange, width: 4),
    ),
    dayPeriodTextColor: Colors.white,
    dayPeriodShape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      side: BorderSide(color: Colors.orange, width: 4),
    ),
    hourMinuteColor: MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.selected) ? Colors.orange : Colors.blueGrey.shade800),
    hourMinuteTextColor: MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.selected) ? Colors.white : Colors.orange),
    dialHandColor: Colors.blueGrey.shade700,
    dialBackgroundColor: Colors.blueGrey.shade800,
    hourMinuteTextStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    dayPeriodTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
    helpTextStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
    inputDecorationTheme: const InputDecorationTheme(
      border: InputBorder.none,
      contentPadding: EdgeInsets.all(0),
    ),
    dialTextColor: MaterialStateColor.resolveWith(
        (states) => states.contains(MaterialState.selected) ? Colors.orange : Colors.white),
    entryModeIconColor: Colors.orange,
  );

  /// create android date picker
  static _buildMaterialDatePicker(
    BuildContext context,
    TimeOfDay initialTime, {
    required Function(TimeOfDay?) onTimeSelected,
  }) async {
    TimeOfDay? selected = await customShowRoundedTimePicker(
      positiveBtn: 'Confirm',
      negativeBtn: 'No time',
      context: context,
      background: Colors.white,
      initialTime: initialTime, //leftBtn: 'Ciao', onLeftBtn: () {},
      borderRadius: 8,
      locale: const Locale("it", "IT"),
      theme: ThemeData(
        fontFamily: "Inter",
        primaryColor: Colors.white,
        colorScheme: ColorScheme.light(
          primary: ColorsExt.akiflow(context),
          secondary: ColorsExt.akiflow(context),
        ),
        dialogBackgroundColor: Colors.white,
        primarySwatch: MaterialColor(
          ColorsExt.akiflow(context).value,
          {
            50: ColorsExt.akiflow(context),
            100: ColorsExt.akiflow(context),
            200: ColorsExt.akiflow(context),
            300: ColorsExt.akiflow(context),
            400: ColorsExt.akiflow(context),
            500: ColorsExt.akiflow(context),
            600: ColorsExt.akiflow(context),
            700: ColorsExt.akiflow(context),
            800: ColorsExt.akiflow(context),
            900: ColorsExt.akiflow(context),
          },
        ),
      ),
    );

    onTimeSelected(selected);
  }

  static TimeOfDay? selected;

  /// create ios date picker
  static _buildCupertinoDatePicker(
    BuildContext context,
    TimeOfDay initialTime, {
    required Function(TimeOfDay?) onTimeSelected,
  }) async {
    selected = null;

    Timer? timer;

    await showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              use24hFormat: true,
              mode: CupertinoDatePickerMode.time,
              onDateTimeChanged: (date) {
                timer?.cancel();

                timer = Timer(const Duration(milliseconds: 500), () {
                  selected = TimeOfDay(hour: date.hour, minute: date.minute);
                });
              },
              initialDateTime: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                initialTime.hour,
                initialTime.minute,
              ),
            ),
          );
        });

    onTimeSelected(selected);
  }
}
