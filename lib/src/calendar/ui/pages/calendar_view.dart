import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/widgets/calendar_appbar.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
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
        final CalendarController calendarController = CalendarController();
        calendarController.view = context.watch<CalendarCubit>().state.calendarView;
        TasksCubit tasksCubit = context.watch<TasksCubit>();
        List<Task> tasks = List.from(tasksCubit.state.calendarTasks);
        tasks = List.from(tasks.where((element) => element.deletedAt == null && element.datetime != null));

        EventsCubit eventsCubit = context.watch<EventsCubit>();
        List<Event> events = List.from(eventsCubit.state.events);
        events = List.from(events.where((element) => element.taskId == null));

        return Scaffold(
          appBar: CalendarAppBar(calendarController: calendarController),
          body: CalendarBody(
            calendarController: calendarController,
            tasks: tasks,
            events: events,
          ),
        );
      },
    );
  }
}
