import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/core/services/sync_controller_service.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/button_selectable.dart';
import 'package:mobile/src/calendar/ui/widgets/settings/calendar_item.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:models/calendar/calendar.dart';
import 'package:syncfusion_calendar/calendar.dart';

class CalendarSettingsModal extends StatelessWidget {
  const CalendarSettingsModal({
    Key? key,
    required this.calendarController,
  }) : super(key: key);
  final CalendarController calendarController;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        bool isThreeDays = state.isCalendarThreeDays;
        bool isWeekendHidden = !state.isCalendarWeekendHidden;
        bool areDeclinedEventsHidden = !state.areDeclinedEventsHidden;
        bool areCalendarTasksHidden = !state.areCalendarTasksHidden;
        bool groupOverlappingTasks = state.groupOverlappingTasks;
        List<Calendar> calendars = context.watch<CalendarCubit>().state.calendars;

        List<Calendar> primaryCalendars = calendars.where((calendar) => calendar.primary ?? false == true).toList();
        DateTime now = DateTime.now().toLocal();
        return Material(
          color: ColorsExt.background(context),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radiusM),
          ),
          child: ScrollConfiguration(
            behavior: NoScrollBehav(),
            child: Column(
              children: [
                const SizedBox(height: Dimension.padding),
                const ScrollChip(),
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.all(Dimension.padding),
                    children: [
                      _calendarView(context, isThreeDays, now, isWeekendHidden),
                      const Separator(),
                      _refreshRow(context),
                      const Separator(),
                      const SizedBox(height: Dimension.padding),
                      _switchButtons(
                          context: context,
                          isWeekendHidden: isWeekendHidden,
                          groupOverlappingTasks: groupOverlappingTasks,
                          areCalendarTasksHidden: areCalendarTasksHidden,
                          areDeclinedEventsHidden: areDeclinedEventsHidden,
                          isThreeDays: isThreeDays),
                      const Separator(),
                      _calendars(context, primaryCalendars, calendars),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Column _calendarView(BuildContext context, bool isThreeDays, DateTime now, bool isWeekendHidden) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Dimension.paddingS, bottom: Dimension.paddingS),
          child: Text(t.calendar.calendarView.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w600)),
        ),
        _agenda(context, isThreeDays, now),
        const SizedBox(height: 2),
        _oneDay(context, isThreeDays, now),
        const SizedBox(height: 2),
        _threeDays(context, isThreeDays, now, isWeekendHidden),
        const SizedBox(height: 2),
        _week(context, isThreeDays, now, isWeekendHidden),
        const SizedBox(height: 2),
        _month(context, isThreeDays, now),
        const SizedBox(height: Dimension.paddingS),
      ],
    );
  }

  ButtonSelectable _agenda(BuildContext context, bool isThreeDays, DateTime now) {
    return ButtonSelectable(
      title: t.calendar.view.agenda,
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.agendaSVG,
          color: ColorsExt.grey800(context),
        ),
      ),
      trailing: const SizedBox(),
      selected: calendarController.view == CalendarView.schedule && !isThreeDays,
      onPressed: () {
        context.read<CalendarCubit>().setCalendarViewThreeDays(false);
        context.read<CalendarCubit>().changeCalendarView(CalendarView.schedule);
        calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
        calendarController.view = CalendarView.schedule;
        Navigator.pop(context);
      },
    );
  }

  ButtonSelectable _oneDay(BuildContext context, bool isThreeDays, DateTime now) {
    return ButtonSelectable(
      title: t.calendar.view.oneDay,
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.daySVG,
          color: ColorsExt.grey800(context),
        ),
      ),
      trailing: const SizedBox(),
      selected: calendarController.view == CalendarView.day && !isThreeDays,
      onPressed: () {
        context.read<CalendarCubit>().setCalendarViewThreeDays(false);
        context.read<CalendarCubit>().changeCalendarView(CalendarView.day);
        calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
        calendarController.view = CalendarView.day;
        Navigator.pop(context);
      },
    );
  }

  ButtonSelectable _threeDays(BuildContext context, bool isThreeDays, DateTime now, bool isWeekendHidden) {
    return ButtonSelectable(
      title: t.calendar.view.threeDays,
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.threeDaysSVG,
          color: ColorsExt.grey800(context),
        ),
      ),
      trailing: const SizedBox(),
      selected: isThreeDays,
      onPressed: () {
        calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
        if (!isWeekendHidden) {
          context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
          calendarController.view = CalendarView.workWeek;
        } else {
          context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
          calendarController.view = CalendarView.week;
        }
        context.read<CalendarCubit>().setCalendarViewThreeDays(true);
        Navigator.pop(context);
      },
    );
  }

  ButtonSelectable _week(BuildContext context, bool isThreeDays, DateTime now, bool isWeekendHidden) {
    return ButtonSelectable(
      title: t.calendar.view.week,
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.weekSVG,
          color: ColorsExt.grey800(context),
        ),
      ),
      trailing: const SizedBox(),
      selected: (calendarController.view == CalendarView.week || calendarController.view == CalendarView.workWeek) &&
          !isThreeDays,
      onPressed: () {
        calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
        if (!isWeekendHidden) {
          context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
          calendarController.view = CalendarView.workWeek;
        } else {
          context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
          calendarController.view = CalendarView.week;
        }
        context.read<CalendarCubit>().setCalendarViewThreeDays(false);
        Navigator.pop(context);
      },
    );
  }

  ButtonSelectable _month(BuildContext context, bool isThreeDays, DateTime now) {
    return ButtonSelectable(
      title: t.calendar.view.month,
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.monthSVG,
          color: ColorsExt.grey800(context),
        ),
      ),
      trailing: const SizedBox(),
      selected: calendarController.view == CalendarView.month && !isThreeDays,
      onPressed: () {
        context.read<CalendarCubit>().setCalendarViewThreeDays(false);
        context.read<CalendarCubit>().changeCalendarView(CalendarView.month);
        calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
        calendarController.view = CalendarView.month;
        Navigator.pop(context);
      },
    );
  }

  InkWell _refreshRow(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        context.read<SyncCubit>().sync(entities: [Entity.tasks, Entity.eventModifiers, Entity.events]).then((value) {
          context.read<EventsCubit>().refreshAllEvents(context);
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(left: Dimension.paddingS, top: Dimension.padding, bottom: Dimension.padding),
        child: Row(
          children: [
            SizedBox(
              height: Dimension.defaultIconSize,
              width: Dimension.defaultIconSize,
              child: SvgPicture.asset(
                Assets.images.icons.common.arrow2CirclepathSVG,
                color: ColorsExt.grey800(context),
              ),
            ),
            const SizedBox(width: Dimension.padding),
            Text(t.calendar.refresh,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context))),
          ],
        ),
      ),
    );
  }

  Padding _switchButtons(
      {required BuildContext context,
      required bool isWeekendHidden,
      required bool groupOverlappingTasks,
      required bool areCalendarTasksHidden,
      required bool areDeclinedEventsHidden,
      bool isThreeDays = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimension.paddingS, bottom: Dimension.padding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.calendar.hideWeekends,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context))),
              SwitchButton(
                value: isWeekendHidden,
                onToggle: (value) {
                  context.read<CalendarCubit>().setCalendarWeekendHidden(!value);
                  if (calendarController.view == CalendarView.week ||
                      calendarController.view == CalendarView.workWeek) {
                    if (!value) {
                      context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                      calendarController.view = CalendarView.workWeek;
                    } else {
                      context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                      calendarController.view = CalendarView.week;
                    }
                    if (isThreeDays) {
                      context.read<CalendarCubit>().setCalendarViewThreeDays(true);
                    }
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: Dimension.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.calendar.groupOverlappingTasks,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context))),
              SwitchButton(
                value: groupOverlappingTasks,
                onToggle: (value) {
                  context.read<CalendarCubit>().setGroupOverlappingTasks(value);
                },
              ),
            ],
          ),
          const SizedBox(height: Dimension.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.calendar.hideTasksFromCalendar,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context))),
              SwitchButton(
                value: areCalendarTasksHidden,
                onToggle: (value) {
                  context.read<CalendarCubit>().setCalendarTasksHidden(!value);
                },
              ),
            ],
          ),
          const SizedBox(height: Dimension.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.calendar.hideDeclinedEvents,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context))),
              SwitchButton(
                value: areDeclinedEventsHidden,
                onToggle: (value) {
                  context.read<CalendarCubit>().setDeclinedEventsHidden(!value);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Column _calendars(BuildContext context, List<Calendar> primaryCalendars, List<Calendar> calendars) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: Dimension.paddingS, top: Dimension.padding),
          child: Text(t.calendar.calendars.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: ColorsExt.grey600(context), fontWeight: FontWeight.w600)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: primaryCalendars.length,
          itemBuilder: (context, index) {
            return CalendarItem(
              title: primaryCalendars[index].originId!,
              calendars: calendars
                  .where((calendar) => calendar.originAccountId == primaryCalendars[index].originAccountId)
                  .toList(),
            );
          },
        ),
      ],
    );
  }
}

class SwitchButton extends StatelessWidget {
  final bool value;
  final void Function(bool) onToggle;
  const SwitchButton({
    Key? key,
    required this.value,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterSwitch(
        width: 48,
        height: 24,
        toggleSize: 20,
        activeColor: ColorsExt.akiflow500(context),
        inactiveColor: ColorsExt.grey200(context),
        value: value,
        borderRadius: 24,
        padding: 2,
        onToggle: onToggle);
  }
}
