import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/widgets/calendar_appbar.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/event/event.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../widgets/calendar_body.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        final PanelController panelController = PanelController();
        final CalendarController calendarController = CalendarController();
        calendarController.view = context.watch<CalendarCubit>().state.calendarView;
        TasksCubit tasksCubit = context.watch<TasksCubit>();
        List<Task> tasks = List.from(tasksCubit.state.calendarTasks);
        tasks = List.from(tasks.where((element) => element.deletedAt == null && element.datetime != null));

        List<Calendar> calendars = context.watch<CalendarCubit>().state.calendars;
        calendars = calendars
            .where((element) =>
                element.settings != null && element.settings["visible"] != null && element.settings["visible"] == true)
            .toList();
        List<String> visibleCalendarIds = [];
        for (var calendar in calendars) {
          visibleCalendarIds.add(calendar.id!);
        }

        EventsCubit eventsCubit = context.watch<EventsCubit>();
        List<Event> events = List.from(eventsCubit.state.events);
        events = events.where((element) => visibleCalendarIds.contains(element.calendarId)).toList();

        print('STATE VISIBLE DATES: ${state.visibleDates}');
        eventsCubit.fetchEventsBetweenDates(state.visibleDates.isEmpty ? DateTime.now() : state.visibleDates.first,
            state.visibleDates.isEmpty ? null : state.visibleDates.last);
        print('EVENTS LENGTH: ${events.length}');

        return Scaffold(
          appBar: CalendarAppBar(
            calendarController: calendarController,
          ),
          body: CalendarBody(
            calendarController: calendarController,
            panelController: panelController,
            tasks: tasks,
            events: events,
          ),
        );
      },
    );
  }
}
