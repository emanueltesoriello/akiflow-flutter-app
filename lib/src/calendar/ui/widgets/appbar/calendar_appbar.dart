import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/animated_chevron.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/widgets/settings/calendar_settings_modal.dart';
import 'package:mobile/src/home/ui/cubit/today/viewed_month_cubit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:syncfusion_calendar/calendar.dart';

class CalendarAppBar extends StatefulWidget implements PreferredSizeWidget {
  final CalendarController calendarController;

  const CalendarAppBar({
    Key? key,
    required this.calendarController,
  }) : super(key: key);

  @override
  State<CalendarAppBar> createState() => _CalendarAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

class _CalendarAppBarState extends State<CalendarAppBar> {
  bool isPanelOpen = false;
  DateTime? agendaViewedMonth = DateTime.now().toLocal();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    CalendarCubit calendarCubit = context.read<CalendarCubit>();
    calendarCubit.panelStateStream.listen((PanelState panelState) {
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
    DateTime now = DateTime.now().toLocal();
    return AppBarComp(
      showLinearProgress: false,
      leading: SvgPicture.asset(
        Assets.images.icons.common.calendarSVG,
        width: 26,
        height: 26,
      ),
      titleWidget: _buildTitle(context, now),
      actions: _buildActions(now),
      shadow: false,
      showSyncButton: true,
      elevation: 0,
    );
  }

  Widget _buildTitle(BuildContext context, DateTime now) {
    widget.calendarController.addPropertyChangedListener(
      (property) {
        if (property == 'agendaViewedMonth') {
          setState(() {
            agendaViewedMonth = widget.calendarController.agendaViewedMonth!;
          });
        }
      },
    );
    return InkWell(
      overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
      onTap: () {
        context.read<CalendarCubit>().tapAppBarTextDate();
      },
      child: Row(
        children: [
          BlocBuilder<ViewedMonthCubit, ViewedMonthState>(
            builder: (context, viewedMonthState) {
              return BlocBuilder<CalendarCubit, CalendarCubitState>(
                builder: (context, state) {
                  String text;
                  int? monthNum = viewedMonthState.viewedMonth;
                  try {
                    if (isPanelOpen && monthNum != null) {
                      String monthName = DateFormat('MMMM').format(DateTime(0, viewedMonthState.viewedMonth!));
                      text = monthName;
                    } else {
                      text = getHeaderText(state, now);
                    }
                  } catch (e) {
                    text = getHeaderText(state, now);
                  }

                  return Text(
                    text,
                    textAlign: TextAlign.start,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: ColorsExt.grey800(context), fontWeight: FontWeight.w500),
                  );
                },
              );
            },
          ),
          const SizedBox(width: Dimension.paddingS),
          AnimatedChevron(iconUp: !isPanelOpen),
        ],
      ),
    );
  }

  String getHeaderText(CalendarCubitState state, DateTime now) {
    return widget.calendarController.view == CalendarView.schedule
        ? DateFormat('MMMM').format(agendaViewedMonth == null ? now : agendaViewedMonth!)
        : DateFormat('MMMM').format(state.visibleDates.isEmpty
            ? now
            : state.visibleDates.length > 29
                ? state.visibleDates.elementAt(7)
                : state.visibleDates.first);
  }

  List<Widget> _buildActions(DateTime now) {
    DateTime today = DateTime(now.year, now.month, now.day);
    return [
      if (!context.read<CalendarCubit>().state.visibleDates.contains(today))
        TextButton(
          onPressed: () {
            widget.calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
            context.read<CalendarCubit>().closePanel();
            setState(() {
              agendaViewedMonth = now;
            });
          },
          style: ButtonStyle(
            overlayColor: MaterialStateProperty.all<Color>(Colors.transparent),
          ),
          child: Text(
            t.bottomBar.today,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: ColorsExt.akiflow500(context), fontWeight: FontWeight.w600),
          ),
        ),
      IconButton(
        icon: SvgPicture.asset(
          Assets.images.icons.common.ellipsisSVG,
          width: 24,
          height: 24,
          color: ColorsExt.grey800(context),
        ),
        onPressed: () {
          showCupertinoModalBottomSheet(
            context: context,
            builder: (context) => CalendarSettingsModal(calendarController: widget.calendarController),
          );
          context.read<CalendarCubit>().closePanel();
        },
      )
    ];
  }
}
