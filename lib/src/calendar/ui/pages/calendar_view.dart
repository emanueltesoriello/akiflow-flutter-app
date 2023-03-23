import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/extensions/event_extension.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/widgets/appbar/calendar_appbar.dart';
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
        List<Task> tasks = [];
        if (!state.areCalendarTasksHidden) {
          tasks = List.from(tasksCubit.state.calendarTasks);
        }

        List<Calendar> calendars = context.watch<CalendarCubit>().state.calendars;
        calendars = calendars
            .where((element) =>
                element.settings != null &&
                ((element.settings["visibleMobile"] ?? element.settings["visible"] ?? false) == true))
            .toList();
        List<String> visibleCalendarIds = [];
        for (var calendar in calendars) {
          visibleCalendarIds.add(calendar.id!);
        }

        EventsCubit eventsCubit = context.watch<EventsCubit>();
        List<Event> events = List.from(eventsCubit.state.events);
        events = events.where((element) => visibleCalendarIds.contains(element.calendarId)).toList();
        if (state.areDeclinedEventsHidden) {
          events = events.where((event) => event.isLoggedUserAttndingEvent != AtendeeResponseStatus.declined).toList();
        }

        print(events.length);

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
