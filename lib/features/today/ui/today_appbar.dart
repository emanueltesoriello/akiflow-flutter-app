import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/task/task_list_menu.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:table_calendar/table_calendar.dart';

class TodayAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final List<Widget> actions;
  final Function()? onBackClick;
  final bool showLogo;
  final Widget? leading;
  final Widget? customTitle;
  final Widget? child;

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
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(useMaterial3: false),
      child: AppBar(
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.3),
        leading: _leading(context),
        title: _buildTitle(context),
        titleSpacing: TaskExt.isSelectMode(context.watch<TasksCubit>().state) ? 0 : 16,
        actions: _buildActions(context),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return InkWell(
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      onTap: () => context.read<TodayCubit>().toggleCalendarFormat(),
      child: Row(
        children: [
          BlocBuilder<TodayCubit, TodayCubitState>(
            builder: (context, state) {
              bool isToday = isSameDay(state.selectedDate, DateTime.now());

              String text;
              Color color;

              if (isToday) {
                text = t.today.title;
                color = ColorsExt.akiflow(context);
              } else {
                text = DateFormat('EEE, dd').format(DateTime.now());
                color = ColorsExt.grey2(context);
              }

              return Text(
                text,
                textAlign: TextAlign.start,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24, color: color),
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
