import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/src/calendar/ui/cubit/calendar_cubit.dart';
import 'package:mobile/src/calendar/ui/widgets/calendar_appbar.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import '../widgets/calendar_body.dart';

class CalendarView extends StatelessWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (context) => CalendarCubit(), child: const _View());
  }
}

class _View extends StatefulWidget {
  const _View({Key? key}) : super(key: key);

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> {
  final CalendarController calendarController = CalendarController();
  late CalendarDataSource dataSource;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    calendarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    calendarController.view = context.watch<CalendarCubit>().state.calendarView;
    TasksCubit tasksCubit = context.watch<TasksCubit>();
    List<Task> tasks = List.from(tasksCubit.state.calendarTasks);
    tasks = List.from(tasks.where((element) => element.deletedAt == null && element.datetime != null));

    return BlocBuilder<CalendarCubit, CalendarCubitState>(
      builder: (context, state) {
        return Scaffold(
          appBar: CalendarAppBar(calendarController: calendarController),
          body: CalendarBody(
            calendarController: calendarController,
            tasks: tasks,
          ),
        );
      },
    );
  }
}
