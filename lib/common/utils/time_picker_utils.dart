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
    _buildMaterialDatePicker(context, initialTime, onTimeSelected: onTimeSelected);
    onTimeSelected(selected);
  }

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
      initialTime: initialTime,
      borderRadius: 8,
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
