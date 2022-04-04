import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimePickerUtils {
  static void pickDate(
    BuildContext context, {
    required Function(TimeOfDay? date) picked,
  }) async {
    final ThemeData theme = Theme.of(context);

    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _buildCupertinoDatePicker(context, picked);
        break;
      default:
        _buildMaterialDatePicker(context, picked);
        break;
    }
  }

  /// create android date picker
  static _buildMaterialDatePicker(
    BuildContext context,
    Function(TimeOfDay? date) picked,
  ) async {
    final TimeOfDay? date = await showTimePicker(
      context: context,
      initialTime:
          TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
              secondary: Theme.of(context).colorScheme.secondary,
            ),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    picked(date);
  }

  /// create ios date picker
  static _buildCupertinoDatePicker(
    BuildContext context,
    Function(TimeOfDay? date) picked,
  ) {
    picked(TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute));

    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              use24hFormat: true,
              mode: CupertinoDatePickerMode.time,
              onDateTimeChanged: (date) {
                picked(TimeOfDay(hour: date.hour, minute: date.minute));
              },
              initialDateTime: DateTime.now(),
            ),
          );
        });
  }
}
