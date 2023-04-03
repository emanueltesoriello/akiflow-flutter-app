import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/availability/ui/navigator/navigator.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/calendar/ui/pages/calendar_view.dart';
import 'package:mobile/src/home/ui/pages/views/inbox_view.dart';
import 'package:mobile/src/home/ui/pages/views/today_view.dart';
import 'package:mobile/src/label/ui/pages/label_view.dart';

class HomePageNavigator extends StatelessWidget {
  const HomePageNavigator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    HomeViewType homeViewType = context.watch<MainCubit>().state.homeViewType;
    if (homeViewType == HomeViewType.inbox) {
      return const InboxView();
    }
    if (homeViewType == HomeViewType.today) {
      return const TodayView();
    }
    if (homeViewType == HomeViewType.calendar) {
      return const CalendarView();
    }
    if (homeViewType == HomeViewType.availability) {
      return const AvailabilityNavigatorPage();
    }
    if (homeViewType == HomeViewType.label) {
      return const LabelView();
    } else {
      return Container();
    }
  }
}
