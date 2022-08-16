import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';

class CalendarToday extends StatelessWidget {
  final DateTime day;

  const CalendarToday(this.day, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        DateFormat("d").format(day),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: ColorsExt.akiflow(context),
        ),
      ),
    );
  }
}
