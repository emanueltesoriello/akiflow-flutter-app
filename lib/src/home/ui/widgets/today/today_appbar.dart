import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list_menu.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/viewed_month_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:table_calendar/table_calendar.dart';

class TodayAppBar extends StatefulWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final List<Widget> actions;
  final Function()? onBackClick;
  final bool showLogo;
  final Widget? leading;
  final Widget? customTitle;
  final Widget? child;
  final double preferredSizeHeight;
  final double calendarTopMargin;
  final PanelController? panelController;

  const TodayAppBar({
    Key? key,
    this.title,
    this.showBack = false,
    this.actions = const [],
    this.onBackClick,
    this.showLogo = false,
    this.leading,
    this.customTitle,
    this.child,
    this.panelController,
    required this.preferredSizeHeight,
    required this.calendarTopMargin,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(preferredSizeHeight);

  @override
  State<TodayAppBar> createState() => _TodayAppBarState();
}

class _TodayAppBarState extends State<TodayAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      leading: _leading(context),
      titleWidget: _buildTitle(context),
      actions: _buildActions(context),
      shadow: false,
      showSyncButton: true,
    );
  }

  Widget _buildTitle(BuildContext context) {
    return InkWell(
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      onTap: () => context.read<TodayCubit>().tapAppBarTextDate(),
      child: Row(
        children: [
          BlocBuilder<ViewedMonthCubit, ViewedMonthState>(
            builder: (context, viewedMonthState) {
              return BlocBuilder<TodayCubit, TodayCubitState>(
                builder: (context, state) {
                  bool isToday = isSameDay(state.selectedDate, DateTime.now());

                  String text;
                  Color color;
                  int? monthNum = viewedMonthState.viewedMonth;

                  if (!widget.panelController!.isPanelClosed && monthNum != null) {
                    String monthName = DateFormat('MMMM').format(DateTime(0, viewedMonthState.viewedMonth!));
                    text = monthName;
                    color = ColorsExt.akiflow(context);
                  } else if (isToday) {
                    text = t.today.title;
                    color = ColorsExt.akiflow(context);
                  } else {
                    text = DateFormat('EEE, dd').format(state.selectedDate);
                    color = ColorsExt.grey2(context);
                  }

                  return Text(
                    text,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, color: color),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 10),
          BlocBuilder<TodayCubit, TodayCubitState>(
            builder: (context, state) {
              return SvgPicture.asset(
                state.calendarFormat == CalendarFormatState.month
                    ? "assets/images/icons/_common/chevron_up.svg"
                    : "assets/images/icons/_common/chevron_down.svg",
                width: 16,
                height: 16,
                color: ColorsExt.grey3(context),
              );
            },
          )
        ],
      ),
    );
  }

  Widget? _leading(BuildContext context) {
    if (TaskExt.isSelectMode(context.watch<TasksCubit>().state)) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          context.read<TasksCubit>().clearSelected();
        },
        child: Center(
          child: SvgPicture.asset(
            "assets/images/icons/_common/arrow_left.svg",
            width: 26,
            height: 26,
            color: ColorsExt.grey2(context),
          ),
        ),
      );
    } else {
      return null;
    }
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      BlocBuilder<TodayCubit, TodayCubitState>(
        builder: (context, state) {
          bool isToday = isSameDay(state.selectedDate, DateTime.now());

          if (isToday) {
            return const SizedBox();
          }

          return InkWell(
            onTap: () => context.read<TodayCubit>().todayClick(),
            child: Center(
              child: Text(t.bottomBar.today,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: ColorsExt.akiflow(context))),
            ),
          );
        },
      ),
      const TaskListMenu(),
    ];
  }
}
