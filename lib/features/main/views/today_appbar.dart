import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:table_calendar/table_calendar.dart';

class TodayAppBar extends StatefulWidget {
  final String? leadingAsset;

  const TodayAppBar({
    Key? key,
    this.leadingAsset,
  }) : super(key: key);

  @override
  State<TodayAppBar> createState() => _TodayAppBarState();
}

class _TodayAppBarState extends State<TodayAppBar> {
  PageController? _pageController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBarComp(
          customTitle: InkWell(
            onTap: () => context.read<TodayCubit>().toggleCalendarFormat(),
            child: Row(
              children: [
                Text(
                  DateFormat('EEE, dd').format(DateTime.now()),
                  textAlign: TextAlign.start,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24, color: ColorsExt.grey2(context)),
                ),
                const SizedBox(width: 10),
                SvgPicture.asset(
                  "assets/images/icons/_common/chevron_down.svg",
                  width: 16,
                  height: 16,
                  color: ColorsExt.grey3(context),
                ),
              ],
            ),
          ),
          leading: _leading(context),
          actions: [
            IconButton(
              icon: SvgPicture.asset(
                "assets/images/icons/_common/ellipsis.svg",
                width: 26,
                height: 26,
                color: ColorsExt.grey2(context),
              ),
              onPressed: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        BlocBuilder<TodayCubit, TodayCubitState>(
          builder: (context, state) {
            DateTime now = DateTime.now();

            return TableCalendar(
              calendarFormat:
                  state.calendarFormat == CalendarFormatState.week ? CalendarFormat.week : CalendarFormat.month,
              onCalendarCreated: (pageController) {
                _pageController = pageController;
              },
              focusedDay: state.selectedDate ?? now,
              firstDay: now.subtract(const Duration(days: 365)),
              lastDay: now.add(const Duration(days: 365)),
              selectedDayPredicate: (day) {
                return isSameDay(state.selectedDate, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                context.read<TodayCubit>().onDateSelected(selectedDay);
              },
              headerVisible: false,
              daysOfWeekStyle: DaysOfWeekStyle(
                dowTextFormatter: (date, locale) {
                  return DateFormat("E").format(date).substring(0, 1);
                },
                weekdayStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColorsExt.grey3(context),
                ),
                weekendStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: ColorsExt.grey3(context),
                ),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Text(
                      DateFormat("d").format(day),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey2(context),
                      ),
                    ),
                  );
                },
                selectedBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Text(
                      DateFormat("d").format(day),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.akiflow(context),
                      ),
                    ),
                  );
                },
                todayBuilder: (context, day, focusedDay) {
                  return Center(
                    child: Container(
                      padding: const EdgeInsets.all(3.5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        DateFormat("d").format(day),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.background(context),
                        ),
                      ),
                    ),
                  );
                },
                headerTitleBuilder: (context, day) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            _pageController?.jumpToPage((_pageController!.page! - 1).toInt());
                          },
                          child: RotatedBox(
                            quarterTurns: 2,
                            child: SvgPicture.asset(
                              "assets/images/icons/_common/chevron_right.svg",
                              width: 20,
                              height: 20,
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Container(
                            constraints: const BoxConstraints(minWidth: 100),
                            child: Text(
                              DateFormat("MMMM").format(day),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w500,
                                color: ColorsExt.grey2(context),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () {
                            _pageController?.jumpToPage((_pageController!.page! + 1).toInt());
                          },
                          child: SvgPicture.asset(
                            "assets/images/icons/_common/chevron_right.svg",
                            width: 20,
                            height: 20,
                            color: ColorsExt.grey2(context),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _leading(BuildContext context) {
    bool selectMode = context.watch<TasksCubit>().state.tasks.any((element) => element.selected ?? false);

    if (selectMode) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          context.read<TasksCubit>().clearSelected();
        },
        child: SvgPicture.asset(
          "assets/images/icons/_common/arrow_left.svg",
          width: 26,
          height: 26,
          color: ColorsExt.grey2(context),
        ),
      );
    } else {
      if (widget.leadingAsset == null) {
        return const SizedBox();
      }

      return SvgPicture.asset(
        widget.leadingAsset!,
        width: 26,
        height: 26,
        color: ColorsExt.grey2(context),
      );
    }
  }
}
