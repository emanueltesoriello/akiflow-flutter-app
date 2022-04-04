import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DatePickerUtils {
  static void pickDate(
    BuildContext context, {
    required Function(DateTime? date) picked,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    if (initialDate == null) {
      initialDate = DateTime.now().subtract(const Duration(seconds: 1));
    } else if (initialDate.isAfter(DateTime.now())) {
      initialDate = DateTime.now().subtract(const Duration(seconds: 1));
    }

    firstDate ??= DateTime.now().subtract(const Duration(days: 365 * 100));

    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }

    lastDate ??= DateTime.now().add(const Duration(days: 365));

    final ThemeData theme = Theme.of(context);

    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        _buildCupertinoDatePicker(
            context, picked, initialDate, firstDate, lastDate);
        break;
      default:
        _buildMaterialDatePicker(
            context, picked, initialDate, firstDate, lastDate);
        break;
    }
  }

  /// create android date picker
  static _buildMaterialDatePicker(
    BuildContext context,
    Function(DateTime? date) picked,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
  ) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (context, child) => Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Theme.of(context).primaryColor,
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.secondary,
              secondary: Theme.of(context).colorScheme.secondary,
            ),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!),
    );

    picked(date);
  }

  /// create ios date picker
  static _buildCupertinoDatePicker(
    BuildContext context,
    Function(DateTime? date) picked,
    DateTime initialDate,
    DateTime firstDate,
    DateTime lastDate,
  ) {
    picked(initialDate);

    showModalBottomSheet(
        context: context,
        builder: (BuildContext builder) {
          return Container(
            height: MediaQuery.of(context).copyWith().size.height / 3,
            color: Colors.white,
            child: CupertinoDatePicker(
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (date) {
                picked(date);
              },
              initialDateTime: initialDate,
              minimumDate: firstDate,
              maximumDate: lastDate,
            ),
          );
        });
  }
}
