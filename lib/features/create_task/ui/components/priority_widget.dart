import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';

import '../../../../utils/no_scroll_behav.dart';
import 'priority_item.dart';

class PriorityWidget extends StatelessWidget {
  const PriorityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        if (state.showPriority) {
          return SizedBox(
            height: 242,
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: NoScrollBehav(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              PriorityItem(
                                asset: Assets.images.icons.common.exclamationmark3SVG,
                                title: "High",
                                hint: "!1",
                                onSelect: () {
                                  context.read<EditTaskCubit>().setPriority(null, value: 1);
                                },
                              ),
                              PriorityItem(
                                asset: Assets.images.icons.common.exclamationmark2SVG,
                                title: "Medium",
                                hint: "!2",
                                onSelect: () {
                                  context.read<EditTaskCubit>().setPriority(null, value: 2);
                                },
                              ),
                              PriorityItem(
                                asset: Assets.images.icons.common.exclamationmark1SVG,
                                title: "Low",
                                hint: "!3",
                                onSelect: () {
                                  context.read<EditTaskCubit>().setPriority(null, value: 3);
                                },
                              ),
                              PriorityItem(
                                asset: Assets.images.icons.common.noPrioritySVG,
                                title: "No priority",
                                hint: "",
                                onSelect: () {
                                  context.read<EditTaskCubit>().removePriority();
                                },
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                Container(
                  color: Theme.of(context).dividerColor,
                  width: double.infinity,
                  height: 1,
                ),
              ],
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
