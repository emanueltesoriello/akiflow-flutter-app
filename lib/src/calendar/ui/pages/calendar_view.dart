import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/models/grouped_tasks.dart';
import 'package:mobile/src/calendar/ui/widgets/appbar/calendar_appbar.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/event/event.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';
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
        List<GroupedTasks> groupedTasks = [];
        if (!state.areCalendarTasksHidden) {
          tasks = List.from(tasksCubit.state.calendarTasks);

          groupedTasks = findOverlappingTasks(tasks);

          // remove tasks that are in a group from the regular task list
          for (var group in groupedTasks) {
            for (var task in group.taskList) {
              tasks.remove(task);
            }
          }
        }

        List<Calendar> calendars = context.watch<CalendarCubit>().state.calendars;
        List<String> visibleCalendarIds = [];
        if (calendars.isNotEmpty) {
          calendars = calendars
              .where((element) =>
                  element.settings != null &&
                  ((element.settings["visibleMobile"] ?? element.settings["visible"] ?? false) == true))
              .toList();

          for (var calendar in calendars) {
            visibleCalendarIds.add(calendar.id!);
          }
        }

        EventsCubit eventsCubit = context.watch<EventsCubit>();
        List<Event> events = List.from(eventsCubit.state.events);
        events = events.where((element) => visibleCalendarIds.contains(element.calendarId)).toList();

        return Scaffold(
          appBar: CalendarAppBar(
            calendarController: calendarController,
          ),
          body: CalendarBody(
            calendarController: calendarController,
            panelController: panelController,
            tasks: tasks,
            groupedTasks: groupedTasks,
            events: events,
          ),
        );
      },
    );
  }

  List<GroupedTasks> findOverlappingTasks(List<Task> tasks) {
    List<GroupedTasks> groupedTasks = [];

    tasks.sort((a, b) => DateTime.parse(a.datetime!).compareTo(DateTime.parse(b.datetime!)));

    print(tasks.length);

    for (Task task in tasks) {
      DateTime taskStartTime = DateTime.parse(task.datetime!);
      DateTime taskEndTime = DateTime.parse(task.datetime!).add(Duration(seconds: task.duration!));

      // check if the task overlaps with any of the existing groups
      bool isOverlapping = false;
      for (GroupedTasks group in groupedTasks) {
        if (taskStartTime.isBefore(group.endTime) && taskEndTime.isAfter(group.startTime)) {
          isOverlapping = true;
          group.taskList.add(task);
          if (taskStartTime.isBefore(group.startTime)) {
            group.startTime = taskStartTime;
          }
          if (taskEndTime.isAfter(group.endTime)) {
            group.endTime = taskEndTime;
          }
          break;
        }
      }

      // add the task to a new group if it doesn't overlap with any existing group
      if (!isOverlapping) {
        groupedTasks.add(GroupedTasks(const Uuid().v4(), [task], taskStartTime, taskEndTime));
      }
    }

    // filter out groups with only one event
    groupedTasks.removeWhere((group) => group.taskList.length < 2);

    return groupedTasks;
  }
}
