import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/base/ui/widgets/custom_snackbar.dart';
import 'package:mobile/src/base/ui/widgets/task/checkbox_animated.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/models/calendar_event.dart';
import 'package:mobile/src/calendar/ui/models/calendar_task.dart';
import 'package:mobile/src/calendar/ui/widgets/appbar_calendar_panel.dart';
import 'package:mobile/src/calendar/ui/widgets/event_appointment.dart';
import 'package:mobile/src/calendar/ui/widgets/task_appointment.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/events/ui/widgets/event_modal.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/event/event.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarBody extends StatelessWidget {
  const CalendarBody({
    Key? key,
    required this.calendarController,
    required this.tasks,
    required this.events,
    required this.panelController,
  }) : super(key: key);
  final CalendarController calendarController;
  final PanelController panelController;
  final List<Task> tasks;
  final List<Event> events;

  @override
  Widget build(BuildContext context) {
    ValueNotifier<double> calendarOffsetNotifier = ValueNotifier<double>(0);
    return BlocBuilder<CalendarCubit, CalendarCubitState>(builder: (context, state) {
      CheckboxAnimatedController? checkboxController;
      CalendarCubit calendarCubit = context.read<CalendarCubit>();
      EventsCubit eventsCubit = context.read<EventsCubit>();
      TasksCubit tasksCubit = context.read<TasksCubit>();
      bool isThreeDays = calendarCubit.state.isCalendarThreeDays;

      calendarCubit.panelStateStream.listen((PanelState panelState) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (panelController.isAttached) {
            switch (panelState) {
              case PanelState.opened:
                panelController.open();
                break;
              case PanelState.closed:
                panelController.close();
                break;
            }
          }
        });
      });

      return LayoutBuilder(builder: (context, constraints) {
        return SlidingUpPanel(
          bodyHeight: constraints.maxHeight,
          slideDirection: SlideDirection.down,
          controller: panelController,
          maxHeight: 330,
          minHeight: 0,
          defaultPanelState: PanelState.closed,
          panel: ValueListenableBuilder(
            valueListenable: calendarOffsetNotifier,
            builder: (context, value, child) {
              return Container(
                color: ColorsExt.background(context),
                child: AppbarCalendarPanel(
                  calendarController: calendarController,
                ),
              );
            },
          ),
          onPanelClosed: () {
            calendarCubit.panelClosed();
          },
          onPanelOpened: () {
            calendarCubit.panelOpened();
          },
          body: SfCalendar(
            backgroundColor: ColorsExt.background(context),
            controller: calendarController,
            headerHeight: 0,
            firstDayOfWeek: DateTime.monday,
            selectionDecoration: const BoxDecoration(),
            view: calendarCubit.state.calendarView,
            onViewChanged: (ViewChangedDetails details) {
              calendarCubit.setVisibleDates(details.visibleDates);
              String start = details.visibleDates.first.subtract(const Duration(days: 1)).toIso8601String();
              String end = details.visibleDates.last.add(const Duration(days: 1)).toIso8601String();
              tasksCubit.fetchTasksBetweenDates(start, end);
              eventsCubit.fetchEventsBetweenDates(start, end);
            },
            dataSource: _getCalendarDataSource(context),
            viewHeaderStyle: ViewHeaderStyle(
              dayTextStyle: TextStyle(fontSize: 15, color: ColorsExt.grey2(context), fontWeight: FontWeight.w500),
              dateTextStyle: TextStyle(fontSize: 15, color: ColorsExt.grey2(context), fontWeight: FontWeight.w600),
            ),
            timeSlotViewSettings: TimeSlotViewSettings(
              timeIntervalHeight: 60.0,
              minimumAppointmentDuration: const Duration(minutes: 15),
              timeTextStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: ColorsExt.grey2(context)),
              numberOfDaysInView: isThreeDays ? 3 : -1,
              timeFormat: MediaQuery.of(context).alwaysUse24HourFormat ? 'HH:mm' : 'h a',
            ),
            scheduleViewSettings: ScheduleViewSettings(
                appointmentItemHeight: 48,
                hideEmptyScheduleWeek: true,
                dayHeaderSettings: DayHeaderSettings(
                  dayTextStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: ColorsExt.grey2(context)),
                  dateTextStyle: TextStyle(fontWeight: FontWeight.w500, fontSize: 20, color: ColorsExt.grey2(context)),
                ),
                weekHeaderSettings: WeekHeaderSettings(
                  startDateFormat: 'dd',
                  endDateFormat: 'dd MMM',
                  weekTextStyle:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: ColorsExt.grey2_5(context)),
                ),
                monthHeaderSettings: MonthHeaderSettings(
                  height: 66,
                  backgroundColor: ColorsExt.grey7(context),
                  monthTextStyle: TextStyle(fontSize: 20, color: ColorsExt.grey2(context), fontWeight: FontWeight.w500),
                )),
            monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
            onTap: (calendarTapDetails) => calendarTapped(calendarTapDetails, context, eventsCubit),
            appointmentBuilder: (context, calendarAppointmentDetails) =>
                appointmentBuilder(context, calendarAppointmentDetails, checkboxController),
            allowDragAndDrop: true,
            onDragEnd: (appointmentDragEndDetails) => dragEnd(appointmentDragEndDetails, context, calendarCubit),
          ),
        );
      });
    });
  }

  Widget appointmentBuilder(BuildContext context, CalendarAppointmentDetails calendarAppointmentDetails,
      CheckboxAnimatedController? checkboxController) {
    final Appointment appointment = calendarAppointmentDetails.appointments.first;
    if (appointment is CalendarTask) {
      Task task = tasks.where((task) => task.id == appointment.id).first;
      return TaskAppointment(
          calendarController: calendarController,
          appointment: appointment,
          calendarAppointmentDetails: calendarAppointmentDetails,
          checkboxController: checkboxController,
          task: task,
          context: context);
    } else if (appointment.notes == 'deleted') {
      return const SizedBox();
    } else {
      Event event = events.where((event) => event.id == appointment.id).first;
      return EventAppointment(
          calendarAppointmentDetails: calendarAppointmentDetails,
          calendarController: calendarController,
          appointment: appointment,
          event: event,
          context: context);
    }
  }

  void calendarTapped(CalendarTapDetails calendarTapDetails, BuildContext context, EventsCubit eventsCubit) {
    context.read<CalendarCubit>().closePanel();
    if (calendarController.view == CalendarView.month &&
        calendarTapDetails.targetElement == CalendarElement.calendarCell) {
      context.read<CalendarCubit>().changeCalendarView(CalendarView.day);
      calendarController.view = CalendarView.day;
    } else if (calendarTapDetails.targetElement == CalendarElement.appointment &&
        calendarTapDetails.appointments!.first is CalendarTask) {
      TaskExt.editTask(context, tasks.where((task) => task.id == calendarTapDetails.appointments!.first.id).first);
    } else if (calendarTapDetails.targetElement == CalendarElement.appointment) {
      Event event = events.where((event) => event.id == calendarTapDetails.appointments!.first.id).first;
      eventsCubit.refetchEvent(event);
      showCupertinoModalBottomSheet(
        context: context,
        builder: (context) => EventModal(
          event: event,
          tappedDate: calendarTapDetails.date,
        ),
      ).whenComplete(
        () async {
          await eventsCubit.fetchUnprocessedEventModifiers();
          eventsCubit.saveToStatePatchedEvent(eventsCubit.patchEventWithEventModifier(event));
        },
      );
    }
  }

  void dragEnd(AppointmentDragEndDetails appointmentDragEndDetails, BuildContext context, CalendarCubit calendarCubit) {
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
    } else if (events.any((event) => event.id == appointment.id)) {
      Event event = events.firstWhere((event) => event.id == appointment.id);
      if (event.creatorId != event.originCalendarId) {
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackbar.get(
            context: context, type: CustomSnackbarType.error, message: t.snackbar.cannotMoveThisEvent));
      }
    }
  }

  _AppointmentDataSource _getCalendarDataSource(BuildContext context) {
    List<CalendarEvent> calendarNonRecurringEvents = <CalendarEvent>[];
    List<CalendarEvent> calendarParentEvents = <CalendarEvent>[];
    List<CalendarEvent> calendarExceptionEvents = <CalendarEvent>[];
    List<CalendarTask> calendarTasks = <CalendarTask>[];

    List<Event> nonRecurring = <Event>[];
    List<Event> recurringParents = <Event>[];
    List<Event> recurringExceptions = <Event>[];

    nonRecurring = events.where((event) => event.recurringId == null).toList();
    recurringParents = events.where((event) => event.id == event.recurringId).toList();
    recurringExceptions = events.where((event) => event.recurringId != null && event.recurringId != event.id).toList();

    calendarNonRecurringEvents = nonRecurring
        .map((event) => CalendarEvent.fromEvent(
              context: context,
              event: event,
              isRecurringParent: false,
              isRecurringException: false,
              isNonRecurring: true,
            ))
        .toList();
    calendarParentEvents = recurringParents
        .map((event) => CalendarEvent.fromEvent(
              context: context,
              event: event,
              isRecurringParent: true,
              isRecurringException: false,
              isNonRecurring: false,
              exceptions: recurringExceptions,
            ))
        .toList();
    calendarExceptionEvents = recurringExceptions
        .map((event) => CalendarEvent.fromEvent(
              context: context,
              event: event,
              isRecurringParent: false,
              isRecurringException: true,
              isNonRecurring: false,
            ))
        .toList();
    calendarTasks = tasks.map((task) => CalendarTask.taskToCalendarTask(context, task)).toList();

    List<Appointment> all = [
      ...calendarNonRecurringEvents,
      ...calendarParentEvents,
      ...calendarExceptionEvents,
      ...calendarTasks
    ];
    return _AppointmentDataSource(all);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
