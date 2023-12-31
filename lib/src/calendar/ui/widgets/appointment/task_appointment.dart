import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/task/checkbox_animated.dart';
import 'package:mobile/src/calendar/ui/models/calendar_task.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class TaskAppointment extends StatelessWidget {
  TaskAppointment({
    Key? key,
    required this.calendarController,
    required this.appointment,
    required this.calendarAppointmentDetails,
    required this.checkboxController,
    required this.task,
    required this.context,
  }) : super(key: key);

  final CalendarController calendarController;
  final CalendarTask appointment;
  final CalendarAppointmentDetails calendarAppointmentDetails;
  CheckboxAnimatedController? checkboxController;
  final Task task;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    double boxHeight = calendarAppointmentDetails.bounds.height;
    double boxWidth = calendarAppointmentDetails.bounds.width;
    String? duration;
    double hours = task.duration! / 3600;
    double minutes = (hours - hours.floor()) * 60;
    if (minutes.floor() == 0) {
      duration = '${hours.floor()}h';
    } else if (hours.floor() == 0) {
      duration = '${minutes.floor()}m';
    } else {
      duration = '${hours.floor()}h ${minutes.floor()}m';
    }
    return Opacity(
      opacity: task.done ?? false ? 0.6 : 1.0,
      child: Container(
        key: ObjectKey(appointment),
        width: boxWidth,
        height: boxHeight,
        decoration: BoxDecoration(
          color: ColorsExt.grey7(context),
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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.calendarId != null)
              Container(
                height: boxHeight,
                width: 2,
                decoration: BoxDecoration(
                  borderRadius:
                      const BorderRadius.only(topLeft: Radius.circular(4.0), bottomLeft: Radius.circular(4.0)),
                  color: ColorsExt.cyan(context),
                ),
              ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: calendarController.view == CalendarView.schedule
                        ? CrossAxisAlignment.center
                        : CrossAxisAlignment.start,
                    children: [
                      boxHeight > 14 &&
                              (calendarController.view == CalendarView.day ||
                                  calendarController.view == CalendarView.schedule)
                          ? GestureDetector(
                              onTap: () {
                                task.playTaskDoneSound();
                                checkboxController?.completedClick();
                              },
                              child: Row(
                                children: [
                                  Builder(builder: ((context) {
                                    TasksCubit tasksCubit = context.read<TasksCubit>();
                                    SyncCubit syncCubit = context.read<SyncCubit>();
                                    EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)
                                      ..attachTask(task);
                                    return CheckboxAnimated(
                                      onControllerReady: (controller) {
                                        checkboxController = controller;
                                      },
                                      task: task,
                                      key: ObjectKey(task),
                                      onCompleted: () async {
                                        HapticFeedback.mediumImpact();
                                        editTaskCubit.markAsDone(forceUpdate: true);
                                      },
                                    );
                                  })),
                                ],
                              ),
                            )
                          : const SizedBox(width: 3),
                      Expanded(
                        child: Text(appointment.subject,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                  height: 1.3,
                                  fontSize: calendarController.view == CalendarView.schedule
                                      ? 15.0
                                      : boxHeight < 15.0
                                          ? 10.5
                                          : 13.0,
                                  fontWeight: FontWeight.w500,
                                  color: ColorsExt.grey1(context),
                                )),
                      ),
                    ],
                  ),
                  if (calendarController.view == CalendarView.schedule)
                    Row(
                      children: [
                        const SizedBox(width: 5),
                        Text(
                            '${DateFormat("HH:mm").format(DateTime.parse(task.datetime!).toLocal())} - ${DateFormat("HH:mm").format(DateTime.parse(task.datetime!).toLocal().add(Duration(seconds: task.duration!)))}',
                            style: Theme.of(context).textTheme.caption?.copyWith(
                                  height: 1.3,
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                  color: ColorsExt.grey3(context),
                                )),
                      ],
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, right: 2),
              child: Row(
                children: [
                  if (boxWidth > 92 &&
                      (calendarController.view == CalendarView.day || calendarController.view == CalendarView.schedule))
                    Text(
                      duration,
                      style: TextStyle(
                        height: boxHeight < 15 ? 1.0 : 1.3,
                        fontSize: boxHeight < 12.0 ? 9.0 : 11.0,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey3(context),
                      ),
                    ),
                  if (task.calendarId != null &&
                      boxWidth > 75 &&
                      (calendarController.view == CalendarView.day || calendarController.view == CalendarView.schedule))
                    SizedBox(
                      height: 14,
                      width: 14,
                      child: SvgPicture.asset(
                        Assets.images.icons.common.lockSVG,
                        color: ColorsExt.grey3(context),
                      ),
                    ),
                  if (appointment.label != null && calendarController.view != CalendarView.month && boxWidth > 25)
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        constraints: const BoxConstraints(
                          minHeight: 14,
                          minWidth: 14,
                          maxHeight: 14,
                          maxWidth: 14,
                        ),
                        decoration: BoxDecoration(
                          color: appointment.label!.color != null
                              ? ColorsExt.getFromName(appointment.label!.color!).withOpacity(0.1)
                              : null,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            Assets.images.icons.common.numberSVG,
                            color: appointment.label!.color != null
                                ? ColorsExt.getFromName(appointment.label!.color!)
                                : ColorsExt.grey3(context),
                            width: 12,
                            height: 12,
                          ),
                        ),
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
