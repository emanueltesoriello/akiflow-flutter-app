import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/features/main/views/tasks_list_appbar.dart';

class TodayAppBar extends TasksListAppBar {
  TodayAppBar({Key? key})
      : super(key: key, title: DateFormat('EEE, dd').format(DateTime.now()));
}
