import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/components/task/task_list.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/label/ui/label_appbar.dart';
import 'package:mobile/features/label/ui/section_header.dart';
import 'package:mobile/features/today/ui/today_task_list.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class LabelView extends StatelessWidget {
  const LabelView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LabelCubit, LabelCubitState>(
      builder: (context, state) {
        List<Task> labelTasks = state.tasks ?? [];

        List<Task> filtered = labelTasks.toList();

        if (!state.showDone) {
          filtered = labelTasks.where((element) => !element.isCompletedComputed).toList();
        }

        return Column(
          children: [
            LabelAppBar(label: state.selectedLabel!, showDone: state.showDone),
            Expanded(
              child: ContainerInnerShadow(
                child: SlidableAutoCloseBehavior(
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: PrimaryScrollController.of(context) ?? ScrollController(),
                    slivers: state.sections.map((section) {
                      List<Task> tasks = filtered.where((task) => task.sectionId == section.id).toList();

                      return TodayTaskList(
                        tasks: tasks,
                        sorting: TaskListSorting.descending,
                        showTasks: state.openedSections[section.id] ?? false,
                        header: SectionHeaderItem(
                          section.title ?? t.task.noTitle,
                          taskCount: tasks.length,
                          onClick: () {
                            context.read<LabelCubit>().toggleOpenSection(section.id);
                          },
                          listOpened: state.openedSections[section.id] ?? false,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
