import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';

class DateDisplay extends StatelessWidget {
  const DateDisplay({
    Key? key,
    required this.date,
  }) : super(key: key);
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        constraints: const BoxConstraints(minWidth: 100),
        child: Text(DateFormat("MMMM").format(date),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey800(context),
                )),
      ),
    );
  }
}
