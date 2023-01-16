import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/tagbox.dart';
import 'package:mobile/src/base/ui/widgets/task/checkbox_animated.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/models/calendar_event.dart';
import 'package:mobile/src/calendar/ui/models/calendar_task.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarBody extends StatelessWidget {
  const CalendarBody({
    Key? key,
    required this.calendarController,
    required this.tasks,
  }) : super(key: key);
  final CalendarController calendarController;
  final List<Task> tasks;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitState>(builder: (context, state) {
      CheckboxAnimatedController? checkboxController;
      bool isThreeDays = context.watch<CalendarCubit>().state.isCalendarThreeDays;
      return SfCalendar(
        controller: calendarController,
        headerHeight: 0,
        firstDayOfWeek: 1,
        view: context.watch<CalendarCubit>().state.calendarView,
        timeZone: DateTime.now().timeZoneName,
        dataSource: _getCalendarDataSource(context),
        timeSlotViewSettings: TimeSlotViewSettings(timeIntervalHeight: 50.0, numberOfDaysInView: isThreeDays ? 3 : -1),
        scheduleViewSettings: ScheduleViewSettings(
            hideEmptyScheduleWeek: true,
            monthHeaderSettings: MonthHeaderSettings(height: 80, backgroundColor: ColorsExt.akiflow(context))),
        monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
        onTap: (calendarTapDetails) => calendarTapped(calendarTapDetails, context),
        appointmentBuilder: (context, calendarAppointmentDetails) =>
            appointmentBuilder(context, calendarAppointmentDetails, checkboxController),
        allowDragAndDrop: true,
        onDragEnd: (appointmentDragEndDetails) => dragEnd(appointmentDragEndDetails, context),
      );
    });
  }

  Widget appointmentBuilder(BuildContext context, CalendarAppointmentDetails calendarAppointmentDetails,
      CheckboxAnimatedController? checkboxController) {
    final Appointment appointment = calendarAppointmentDetails.appointments.first;
    if (appointment is CalendarEvent) {
      return _event(calendarAppointmentDetails, appointment, context);
    } else if (appointment is CalendarTask) {
      Task task = tasks.where((task) => task.id == appointment.id).first;
      return _task(appointment, calendarAppointmentDetails, checkboxController, task, context);
    }
    return const SizedBox();
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails, BuildContext context) {
    if (calendarController.view == CalendarView.month &&
        calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      context.read<CalendarCubit>().changeCalendarView(CalendarView.day);
      calendarController.view = CalendarView.day;
    } else if (calendarTapDetails.targetElement == CalendarElement.appointment &&
        calendarTapDetails.appointments!.first is CalendarTask) {
      TaskExt.editTask(context, tasks.where((task) => task.id == calendarTapDetails.appointments!.first.id).first);
    } else if (calendarTapDetails.targetElement == CalendarElement.appointment &&
        calendarTapDetails.appointments!.first is CalendarEvent) {
      print('TAP ON EVENT');
    }
  }

  void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails, BuildContext context) {
    dynamic appointment = appointmentDragEndDetails.appointment!;
    DateTime droppingTime = appointmentDragEndDetails.droppingTime!;
    DateTime droppedTimeRounded = DateTime(droppingTime.year, droppingTime.month, droppingTime.day, droppingTime.hour,
        [0, 15, 30, 45, 60][(droppingTime.minute / 15).round()]);

    if (tasks.any((task) => task.id == appointment.id)) {
      Task task = tasks.firstWhere((task) => task.id == appointment.id);
      DateTime taskDateTime = DateTime.parse(task.datetime!);
      TasksCubit tasksCubit = context.read<TasksCubit>();

      if (taskDateTime.difference(droppingTime.toUtc()).inMinutes.abs() > 4) {
        SyncCubit syncCubit = context.read<SyncCubit>();
        EditTaskCubit editTaskCubit = EditTaskCubit(tasksCubit, syncCubit)..attachTask(task);

        editTaskCubit.changeDateTimeFromCalendar(date: droppingTime, dateTime: droppedTimeRounded);
      } else {
        tasksCubit.fetchCalendarTasks();
      }
    }
  }

  _AppointmentDataSource _getCalendarDataSource(BuildContext context) {
    List<CalendarEvent> events = <CalendarEvent>[];
    List<CalendarTask> calendarTasks = <CalendarTask>[];

    DateTime now = DateTime.now();

    events.add(CalendarEvent(
      startTime: DateTime(now.year, now.month, now.day, 12, 0, 0),
      endTime: DateTime(now.year, now.month, now.day, 13, 0, 0),
      subject: 'Meeting',
      color: Colors.red,
    ));
    events.add(CalendarEvent(
      startTime: DateTime(now.year, now.month, now.day, 14, 0, 0),
      endTime: DateTime(now.year, now.month, now.day, 16, 0, 0),
      subject: 'Title of some meeting',
      color: Colors.green,
    ));
    events.add(CalendarEvent(
      startTime: DateTime(now.year, now.month, now.day - 1, 16, 0, 0),
      endTime: DateTime(now.year, now.month, now.day - 1, 17, 0, 0),
      subject: 'Title of some event',
    ));

    calendarTasks = tasks.map((task) => CalendarTask.taskToCalendarTask(context, task)).toList();

    List<Appointment> all = [...events, ...calendarTasks];
    return _AppointmentDataSource(all);
  }

  Container _event(
      CalendarAppointmentDetails calendarAppointmentDetails, CalendarEvent appointment, BuildContext context) {
    return Container(
      width: calendarAppointmentDetails.bounds.width,
      height: calendarAppointmentDetails.bounds.height,
      decoration: BoxDecoration(
          color: appointment.color.withAlpha(50),
          borderRadius: const BorderRadius.all(
            Radius.circular(3.0),
          )),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 2, 6, 2),
            child: Container(
              height: calendarAppointmentDetails.bounds.height,
              width: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: appointment.color,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 2.0),
              child: Text(
                appointment.subject,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  height: 1.3,
                  fontSize: calendarAppointmentDetails.bounds.height < 22.0 ? 12.0 : 17.0,
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey1(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _task(CalendarTask appointment, CalendarAppointmentDetails calendarAppointmentDetails,
      CheckboxAnimatedController? checkboxController, Task task, BuildContext context) {
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

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
