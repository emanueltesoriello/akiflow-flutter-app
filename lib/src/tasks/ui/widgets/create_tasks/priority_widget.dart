import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';

import '../../../../../common/utils/no_scroll_behav.dart';
import 'priority_item.dart';

class PriorityWidget extends StatelessWidget {
  const PriorityWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        if (state.showPriority) {
          return SizedBox(
            height: 205,
            child: Column(
              children: [
                Expanded(
                  child: ScrollConfiguration(
                    behavior: NoScrollBehav(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Padding(
                          padding: const EdgeInsets.all(Dimension.paddingS),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              PriorityItem(
                                asset: Assets.images.icons.common.exclamationmark3SVG,
                                title: "High",
                                hint: "",
                                onSelect: () {
                                  context.read<EditTaskCubit>().setPriority(null, value: 1);
                                },
                              ),
                              PriorityItem(
                                asset: Assets.images.icons.common.exclamationmark2SVG,
                                title: "Medium",
                                hint: "",
                                onSelect: () {
                                  context.read<EditTaskCubit>().setPriority(null, value: 2);
                                },
                              ),
                              PriorityItem(
                                asset: Assets.images.icons.common.exclamationmark1SVG,
                                title: "Low",
                                hint: "",
                                onSelect: () {
                                  context.read<EditTaskCubit>().setPriority(null, value: 3);
                                },
                              ),
                              state.updatedTask.priority != null && state.updatedTask.priority! > -1
                                  ? PriorityItem(
                                      asset: Assets.images.icons.common.noPrioritySVG,
                                      title: "No priority",
                                      hint: "",
                                      onSelect: () {
                                        context.read<EditTaskCubit>().removePriority();
                                      },
                                    )
                                  : const SizedBox(),
                            ],
                          )),
                    ),
                  ),
                ),
                const Separator(),
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
