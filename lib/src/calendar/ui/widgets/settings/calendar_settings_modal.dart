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
import 'package:syncfusion_flutter_calendar/calendar.dart';

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
        bool isWeekendHidden = state.isCalendarWeekendHidden;
        bool areDeclinedEventsHidden = state.areDeclinedEventsHidden;
        bool areCalendarTasksHidden = state.areCalendarTasksHidden;
        List<Calendar> calendars = context.watch<CalendarCubit>().state.calendars;

        List<Calendar> primaryCalendars = calendars.where((calendar) => calendar.primary ?? false == true).toList();
        DateTime now = DateTime.now().toLocal();
        return Material(
          color: Colors.transparent,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.radius),
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
                      Padding(
                        padding: const EdgeInsets.only(left: Dimension.paddingS, bottom: Dimension.paddingS),
                        child: Text(
                          t.calendar.calendarView.toUpperCase(),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                        ),
                      ),
                      ButtonSelectable(
                        title: t.calendar.view.agenda,
                        leading: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            Assets.images.icons.common.agendaSVG,
                            color: ColorsExt.grey2(context),
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
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
                        title: t.calendar.view.oneDay,
                        leading: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            Assets.images.icons.common.daySVG,
                            color: ColorsExt.grey2(context),
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
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
                        title: t.calendar.view.threeDays,
                        leading: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            Assets.images.icons.common.threeDaysSVG,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                        trailing: const SizedBox(),
                        selected: isThreeDays,
                        onPressed: () {
                          context.read<CalendarCubit>().setCalendarViewThreeDays(true);
                          calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
                          if (isWeekendHidden) {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                            calendarController.view = CalendarView.workWeek;
                          } else {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                            calendarController.view = CalendarView.week;
                          }
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
                        title: t.calendar.view.week,
                        leading: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            Assets.images.icons.common.weekSVG,
                            color: ColorsExt.grey2(context),
                          ),
                        ),
                        trailing: const SizedBox(),
                        selected: (calendarController.view == CalendarView.week ||
                                calendarController.view == CalendarView.workWeek) &&
                            !isThreeDays,
                        onPressed: () {
                          calendarController.displayDate = now.hour > 2 ? now.subtract(const Duration(hours: 2)) : now;
                          if (isWeekendHidden) {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                            calendarController.view = CalendarView.workWeek;
                          } else {
                            context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                            calendarController.view = CalendarView.week;
                          }
                          context.read<CalendarCubit>().setCalendarViewThreeDays(false);
                          Navigator.pop(context);
                        },
                      ),
                      const SizedBox(height: 2),
                      ButtonSelectable(
                        title: t.calendar.view.month,
                        leading: SizedBox(
                          height: 20,
                          width: 20,
                          child: SvgPicture.asset(
                            Assets.images.icons.common.monthSVG,
                            color: ColorsExt.grey2(context),
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
                      ),
                      const SizedBox(height: 12),
                      const Separator(),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          context
                              .read<SyncCubit>()
                              .sync(entities: [Entity.tasks, Entity.eventModifiers, Entity.events]).then((value) {
                            context
                                .read<EventsCubit>()
                                .refreshAllEvents(context)
                                .then((value) => context.read<SyncCubit>().showLoadingIcon(true));
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16),
                          child: Row(
                            children: [
                              SizedBox(
                                height: 20,
                                width: 20,
                                child: SvgPicture.asset(
                                  Assets.images.icons.common.arrow2CirclepathSVG,
                                  color: ColorsExt.grey2(context),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Refresh',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: ColorsExt.grey2(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Separator(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, bottom: 16),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.calendar.hideWeekends,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: ColorsExt.grey2(context),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 48,
                                  height: 24,
                                  toggleSize: 20,
                                  activeColor: ColorsExt.akiflow(context),
                                  inactiveColor: ColorsExt.grey5(context),
                                  value: isWeekendHidden,
                                  borderRadius: 24,
                                  padding: 2,
                                  onToggle: (value) {
                                    context.read<CalendarCubit>().setCalendarWeekendHidden(value);
                                    if (calendarController.view == CalendarView.week ||
                                        calendarController.view == CalendarView.workWeek) {
                                      if (value) {
                                        context.read<CalendarCubit>().changeCalendarView(CalendarView.workWeek);
                                        calendarController.view = CalendarView.workWeek;
                                      } else {
                                        context.read<CalendarCubit>().changeCalendarView(CalendarView.week);
                                        calendarController.view = CalendarView.week;
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.calendar.hideDeclinedEvents,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: ColorsExt.grey2(context),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 48,
                                  height: 24,
                                  toggleSize: 20,
                                  activeColor: ColorsExt.akiflow(context),
                                  inactiveColor: ColorsExt.grey5(context),
                                  value: areDeclinedEventsHidden,
                                  borderRadius: 24,
                                  padding: 2,
                                  onToggle: (value) {
                                    context.read<CalendarCubit>().setDeclinedEventsHidden(value);
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  t.calendar.hideTasksFromCalendar,
                                  style: TextStyle(
                                    fontSize: 17,
                                    color: ColorsExt.grey2(context),
                                  ),
                                ),
                                FlutterSwitch(
                                  width: 48,
                                  height: 24,
                                  toggleSize: 20,
                                  activeColor: ColorsExt.akiflow(context),
                                  inactiveColor: ColorsExt.grey5(context),
                                  value: areCalendarTasksHidden,
                                  borderRadius: 24,
                                  padding: 2,
                                  onToggle: (value) {
                                    context.read<CalendarCubit>().setCalendarTasksHidden(value);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Separator(),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, top: 10.0),
                        child: Text(
                          t.calendar.calendars.toUpperCase(),
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: primaryCalendars.length,
                        itemBuilder: (context, index) {
                          return CalendarItem(
                            title: primaryCalendars[index].originId!,
                            calendars: calendars
                                .where(
                                    (calendar) => calendar.originAccountId == primaryCalendars[index].originAccountId)
                                .toList(),
                          );
                        },
                      ),
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
}
