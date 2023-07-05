import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/base/ui/widgets/task/panel.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/models/grouped_tasks.dart';
import 'package:mobile/src/calendar/ui/widgets/appbar/calendar_appbar.dart';
import 'package:mobile/src/events/ui/cubit/events_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/viewed_month_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/calendar/calendar.dart';
import 'package:models/event/event.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_calendar/calendar.dart' as sf_calendar;
import '../widgets/calendar_body.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        final PanelController panelController = PanelController();
        final sf_calendar.CalendarController calendarController = sf_calendar.CalendarController();
        calendarController.view = state.calendarView;

        TasksCubit tasksCubit = context.watch<TasksCubit>();
        List<Task> tasks = [];
        List<GroupedTasks> groupedTasks = [];
        if (!state.areCalendarTasksHidden) {
          tasks = List.from(tasksCubit.state.calendarTasks);
          tasks = tasks.where((task) => task.datetime != null).toList();

          if (state.groupOverlappingTasks && calendarController.view != sf_calendar.CalendarView.schedule) {
            groupedTasks = findOverlappingTasks(tasks);
            // remove tasks that are in a group from the regular task list
            for (var group in groupedTasks) {
              for (var task in group.taskList) {
                tasks.remove(task);
              }
            }
          }
        }

        List<Calendar> calendars = state.calendars;
        List<String> visibleCalendarIds = [];
        if (calendars.isNotEmpty) {
          for (Calendar calendar in calendars) {
            bool visible = calendar.settings != null &&
                ((calendar.settings["visibleMobile"] ?? calendar.settings["visible"] ?? false) == true);
            if (visible) {
              visibleCalendarIds.add(calendar.id!);
            }
          }
        }

        EventsCubit eventsCubit = context.watch<EventsCubit>();
        List<Event> events = List.from(eventsCubit.state.events);
        events = events.where((element) => visibleCalendarIds.contains(element.calendarId)).toList();

        return BlocProvider(
            lazy: false,
            create: (BuildContext context) => ViewedMonthCubit(),
            child: Scaffold(
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
            ));
      },
    );
  }

  List<GroupedTasks> findOverlappingTasks(List<Task> tasks) {
    List<GroupedTasks> groupedTasks = [];

    tasks.sort((a, b) => DateTime.parse(a.datetime!).compareTo(DateTime.parse(b.datetime!)));

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
        groupedTasks.add(GroupedTasks('group${task.id}', [task], taskStartTime, taskEndTime));
      }
    }

    // filter out groups with only one event
    groupedTasks.removeWhere((group) => group.taskList.length < 2);

    return groupedTasks;
  }
}
