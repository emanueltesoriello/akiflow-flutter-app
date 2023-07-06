import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/labels_list.dart';
import 'package:models/label/label.dart';

class LabelWidget extends StatelessWidget {
  const LabelWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        if (state.showLabelsList) {
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
                        padding: const EdgeInsets.all(Dimension.padding),
                        child: LabelsList(
                          showHeaders: false,
                          onSelect: (Label selected) {
                            context.read<EditTaskCubit>().setLabel(selected);
                          },
                          showNoLabel: state.updatedTask.listId != null,
                        ),
                      ),
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
