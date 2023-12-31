import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list_menu.dart';
import 'package:mobile/src/home/ui/widgets/today/today_appbar.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/label/ui/widgets/label_appbar.dart';
import 'package:models/label/label.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar(
      {Key? key,
      required this.calendarTopMargin,
      required this.todayAppBarHeight,
      required this.homeViewType,
      required this.selectedLabel})
      : super(key: key);
  final double calendarTopMargin;
  final double todayAppBarHeight;
  final HomeViewType homeViewType;
  final Label? selectedLabel;
  @override
  Widget build(BuildContext context) {
    switch (homeViewType) {
      case HomeViewType.inbox:
        return AppBarComp(
          title: t.bottomBar.inbox,
          leading: SvgPicture.asset(
            Assets.images.icons.common.traySVG,
            width: 30,
            height: 30,
          ),
          actions: const [TaskListMenu()],
        );
      case HomeViewType.today:
        return TodayAppBar(preferredSizeHeight: todayAppBarHeight, calendarTopMargin: calendarTopMargin);
      case HomeViewType.calendar:
        return AppBarComp(title: t.bottomBar.calendar);
      case HomeViewType.label:
        bool showDone = context.watch<LabelsCubit>().state.showDone;
        return LabelAppBar(label: selectedLabel!, showDone: showDone);
      default:
        return const PreferredSize(preferredSize: Size.zero, child: SizedBox());
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
