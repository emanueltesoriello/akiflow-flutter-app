import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/availability/ui/widgets/imported_from_material/chevron_icon.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list_menu.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/viewed_month_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/animated_chevron.dart';
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
    required this.preferredSizeHeight,
    required this.calendarTopMargin,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(preferredSizeHeight);

  @override
  State<TodayAppBar> createState() => _TodayAppBarState();
}

class _TodayAppBarState extends State<TodayAppBar> {
  bool isPanelOpen = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    TodayCubit todayCubit = context.read<TodayCubit>();
    todayCubit.panelStateStream.listen((PanelState panelState) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        switch (panelState) {
          case PanelState.opened:
            isPanelOpen = true;
            break;
          case PanelState.closed:
            isPanelOpen = false;
            break;
        }
      });
    });
    super.initState();
  }

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
      onTap: () {
        context.read<TodayCubit>().tapAppBarTextDate();
      },
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
                  try {
                    if (isPanelOpen && monthNum != null) {
                      print('case 0');
                      String monthName = DateFormat('MMMM').format(DateTime(0, viewedMonthState.viewedMonth!));
                      text = monthName;
                      color = ColorsExt.grey2(context);
                    } else if (isToday) {
                      print('case 1');
                      text = t.today.title;
                      color = ColorsExt.akiflow(context);
                    } else if (state.selectedDate.month != DateTime.now().month) {
                      print('case 2');
                      text = DateFormat('MMMM dd').format(state.selectedDate);
                      color = ColorsExt.grey2(context);
                    } else {
                      print('case 3');
                      text = DateFormat('EEE, dd').format(state.selectedDate);
                      color = ColorsExt.grey2(context);
                    }
                  } catch (e) {
                    print('case 4 - exception handling');
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
          const SizedBox(width: Dimension.paddingS),
          BlocBuilder<TodayCubit, TodayCubitState>(
            builder: (context, state) {
              return AnimatedChevron(iconUp: !isPanelOpen);
            },
          )
        ],
      ),
    );
  }

  Widget? _leading(BuildContext context) {
    if (TaskExt.isSelectMode(context.watch<TasksCubit>().state)) {
      return InkWell(
        borderRadius: BorderRadius.circular(Dimension.radius),
        onTap: () {
          context.read<TasksCubit>().clearSelected();
        },
        child: Center(
          child: SvgPicture.asset(
            Assets.images.icons.common.arrowLeftSVG,
            width: Dimension.appBarLeadingIcon,
            height: Dimension.appBarLeadingIcon,
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
