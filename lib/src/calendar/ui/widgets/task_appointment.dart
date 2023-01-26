import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
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
    return Container(
      key: ObjectKey(appointment),
      width: calendarAppointmentDetails.bounds.width,
      height: boxHeight,
      decoration: const BoxDecoration(
          color: Color.fromARGB(150, 230, 230, 230),
          borderRadius: BorderRadius.all(
            Radius.circular(3.0),
          )),
      child: Padding(
        padding: const EdgeInsets.only(left: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((calendarController.view == CalendarView.day || calendarController.view == CalendarView.schedule) &&
                boxHeight > 12)
              GestureDetector(
                onTap: () {
                  checkboxController!.completedClick();
                },
                child: Row(
                  children: [
                    Builder(builder: ((context) {
                      TasksCubit tasksCubit = context.read<TasksCubit>();
                      SyncCubit syncCubit = context.read<SyncCubit>();
                      EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);
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
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 2.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.subject,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        height: 1.3,
                        fontSize: boxHeight < 12.0
                            ? 8.0
                            : boxHeight < 22.0
                                ? 12.0
                                : 17.0,
                        fontWeight: FontWeight.w500,
                        color: ColorsExt.grey1(context),
                      ),
                    ),
                    if ((calendarController.view == CalendarView.day ||
                            calendarController.view == CalendarView.schedule) &&
                        appointment.label != null &&
                        boxHeight > 37)
                      TagBox(
                        icon: Assets.images.icons.common.numberSVG,
                        text: appointment.label!.title,
                        backgroundColor: appointment.label!.color != null
                            ? ColorsExt.getFromName(appointment.label!.color!).withOpacity(0.1)
                            : null,
                        iconColor: appointment.label!.color != null
                            ? ColorsExt.getFromName(appointment.label!.color!)
                            : ColorsExt.grey3(context),
                        onPressed: () {},
                        active: appointment.label!.color != null,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
