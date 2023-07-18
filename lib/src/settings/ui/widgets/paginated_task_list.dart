import 'package:flutter/material.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list.dart';
import 'package:models/task/task.dart';

class PaginatedTaskList extends StatefulWidget {
  /// Function to init the cards list
  final Future<dynamic> Function() initFunction;

  final List<Task> tasks;

  /// The lenght of the current fetched tasks
  final int tasksLength;

  /// The maximum fetchable tasks
  final int maxTasksLenght;

  /// Function that is triggered when you reach the end of the current fetched task list
  final Future<dynamic> Function() scrollNextPageFunc;

  final ScrollPhysics? physics;
  final ScrollController? scrollController;

  const PaginatedTaskList({
    Key? key,
    this.physics,
    required this.initFunction,
    required this.tasks,
    required this.tasksLength,
    required this.maxTasksLenght,
    required this.scrollNextPageFunc,
    required this.scrollController,
  }) : super(key: key);

  @override
  State<PaginatedTaskList> createState() {
    return _PaginatedTaskListState();
  }
}

class _PaginatedTaskListState extends State<PaginatedTaskList> {
  @override
  void initState() {
    widget.initFunction();

    widget.scrollController!.addListener(() async {
      if (widget.scrollController!.position.pixels == widget.scrollController!.position.maxScrollExtent &&
          (widget.tasksLength < widget.maxTasksLenght)) {
        widget.scrollNextPageFunc();
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    widget.scrollController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      radius: const Radius.circular(Dimension.radius),
      child: TaskList(
        key: const Key('paginationList'),
        tasks: widget.tasks,
        hideInboxLabel: true,
        scrollController: widget.scrollController,
        sorting: TaskListSorting.none,
        showLabel: true,
        showPlanInfo: true,
        addBottomPadding: true,
      ),
    );
  }
}
