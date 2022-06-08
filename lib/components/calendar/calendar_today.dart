import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/style/colors.dart';

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
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: ColorsExt.background(context),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
