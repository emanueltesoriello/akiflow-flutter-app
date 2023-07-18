import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/availability/ui/navigator/navigator.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/calendar/ui/pages/calendar_view.dart';
import 'package:mobile/src/home/ui/pages/views/inbox_view.dart';
import 'package:mobile/src/home/ui/pages/views/today_view.dart';
import 'package:mobile/src/label/ui/pages/label_view.dart';
import 'package:mobile/src/settings/ui/pages/all_tasks_page.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

class HomePageNavigator extends StatefulWidget {
  const HomePageNavigator({
    Key? key,
  }) : super(key: key);

  @override
  State<HomePageNavigator> createState() => _HomePageNavigatorState();
}

class _HomePageNavigatorState extends State<HomePageNavigator> {
  bool visible = false;
  late Widget child;
  Widget? container = Container();

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    print('didChangeDependencies on HomePageNavigator');
    setState(() {
      container = Container();

      visible = false;
    });
    Timer(const Duration(milliseconds: 10), () {
      setState(() {
        container = null;
      });
    });
    Timer(const Duration(milliseconds: 100), () {
      setState(() {
        visible = true;
      });
    });

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    HomeViewType homeViewType = context.watch<MainCubit>().state.homeViewType;

    if (homeViewType != HomeViewType.allTasks) {
      context.read<TasksCubit>().clearAllTasksList();
    }

    if (homeViewType == HomeViewType.inbox) {
      return container ??
          AnimatedOpacity(
              key: const Key('InboxView'),
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: const InboxView());
    }
    if (homeViewType == HomeViewType.today) {
      return container ??
          AnimatedOpacity(
              key: const Key('TodayView'),
              opacity: visible ? 1 : 0,
              duration: const Duration(milliseconds: 100),
              child: const TodayView());
    }
    if (homeViewType == HomeViewType.calendar) {
      return AnimatedOpacity(
        key: const Key('CalendarView'),
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: const CalendarView(),
      );
    }
    if (homeViewType == HomeViewType.availability) {
      return AnimatedOpacity(
        key: const Key('AvailabilityNavigatorPage'),
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: const AvailabilityNavigatorPage(),
      );
    }
    if (homeViewType == HomeViewType.label) {
      return AnimatedOpacity(
        key: const Key('LabelView'),
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: const LabelView(),
      );
    }
    if (homeViewType == HomeViewType.allTasks) {
      return AnimatedOpacity(
        key: const Key('AllTasksPage'),
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 100),
        child: const AllTasksPage(),
      );
    }
    return Container();
  }
}
