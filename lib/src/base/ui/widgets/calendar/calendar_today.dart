import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';

class CalendarSelectedDay extends StatelessWidget {
  final DateTime day;

  const CalendarSelectedDay(this.day, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          DateFormat("d").format(day),
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                fontWeight: FontWeight.w500,
                color: ColorsExt.background(context),
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
