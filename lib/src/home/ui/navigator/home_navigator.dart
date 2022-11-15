import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/calendar/ui/calendar_view.dart';
import 'package:mobile/features/label/ui/label_view.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/home/ui/pages/inbox_view.dart';
import 'package:mobile/src/home/ui/pages/views/today_view.dart';

class HomePageNavigator extends StatelessWidget {
  const HomePageNavigator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int homeViewType = context.watch<MainCubit>().state.homeViewType.index;

    if (homeViewType < 4) {
      return IndexedStack(
        index: homeViewType,
        children: const [
          InboxView(),
          TodayView(),
          CalendarView(),
        ],
      );
    }
    return const LabelView();
  }
}
