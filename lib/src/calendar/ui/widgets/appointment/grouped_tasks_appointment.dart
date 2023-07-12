import 'package:flutter/material.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/calendar/ui/models/calendar_grouped_tasks.dart';
import 'package:mobile/src/calendar/ui/models/grouped_tasks.dart';
import 'package:syncfusion_calendar/calendar.dart';

class GroupedTasksAppointment extends StatelessWidget {
  const GroupedTasksAppointment({
    Key? key,
    required this.calendarController,
    required this.appointment,
    required this.calendarAppointmentDetails,
    required this.groupedTasks,
    required this.context,
  }) : super(key: key);

  final CalendarController calendarController;
  final CalendarGroupedTasks appointment;
  final CalendarAppointmentDetails calendarAppointmentDetails;
  final GroupedTasks groupedTasks;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    double boxHeight = calendarAppointmentDetails.bounds.height;
    double boxWidth = calendarAppointmentDetails.bounds.width;
    String? duration;
    double hours = (groupedTasks.endTime.difference(groupedTasks.startTime).inSeconds) / 3600;
    double minutes = (hours - hours.floor()) * 60;
    if (minutes.floor() == 0) {
      duration = '${hours.floor()}h';
    } else if (hours.floor() == 0) {
      duration = '${minutes.floor()}m';
    } else {
      duration = '${hours.floor()}h ${minutes.floor()}m';
    }
    bool tasksDone = !groupedTasks.taskList.any((task) => task.done! == false);

    return Container(
      key: ObjectKey(appointment),
      width: boxWidth,
      height: boxHeight,
      decoration: BoxDecoration(
        color: ColorsExt.grey50(context),
        borderRadius: const BorderRadius.all(
          Radius.circular(4.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            spreadRadius: 1,
            blurRadius: 1,
            offset: const Offset(1, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.only(top: calendarController.view == CalendarView.month ? 1 : 2, left: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: calendarController.view == CalendarView.month
                            ? 9.0
                            : boxHeight < 15.0 && groupedTasks.taskList.length < 10
                                ? 12.0
                                : 14.0,
                        height: calendarController.view == CalendarView.month
                            ? 9.0
                            : boxHeight < 15.0
                                ? 12.0
                                : 14.0,
                        decoration: BoxDecoration(
                          color: tasksDone ? ColorsExt.yorkGreen400(context) : ColorsExt.grey200(context),
                          borderRadius: const BorderRadius.all(
                            Radius.circular(3.0),
                          ),
                        ),
                        child: FittedBox(
                          child: Text('${groupedTasks.taskList.length}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    height: boxHeight < 15.0 ? 1.1 : 1.2,
                                    fontSize: calendarController.view == CalendarView.month
                                        ? 8.0
                                        : boxHeight < 15.0
                                            ? 11.0
                                            : 13.0,
                                    fontWeight: FontWeight.w500,
                                    color: tasksDone ? ColorsExt.grey50(context) : ColorsExt.grey900(context),
                                  )),
                        ),
                      ),
                      const SizedBox(width: Dimension.paddingXS),
                      Expanded(
                        child: Text(appointment.subject,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  height: boxHeight < 15.0 ? 1.1 : 1.3,
                                  fontSize: calendarController.view == CalendarView.month
                                      ? 8.0
                                      : boxHeight < 15.0
                                          ? 11.0
                                          : 13.0,
                                  fontWeight: FontWeight.w500,
                                  color: tasksDone ? ColorsExt.grey700(context) : ColorsExt.grey900(context),
                                )),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: boxHeight < 15.0 ? 0 : 2, right: 2),
              child: Row(
                children: [
                  if (boxWidth > 92 && calendarController.view == CalendarView.day)
                    Text(
                      duration,
                      style: TextStyle(
                        height: boxHeight < 15 ? 1.0 : 1.3,
                        fontSize: boxHeight < 12.0 ? 9.0 : 11.0,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey600(context),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
