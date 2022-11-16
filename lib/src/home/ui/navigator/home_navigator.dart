import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/calendar/ui/navigator/navigator.dart';
import 'package:mobile/src/home/ui/pages/inbox_view.dart';
import 'package:mobile/src/home/ui/pages/views/today_view.dart';
import 'package:mobile/src/label/ui/pages/label_view.dart';

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
          CalendarNavigatorPage(),
        ],
      );
    }
    return const LabelView();
  }
}
