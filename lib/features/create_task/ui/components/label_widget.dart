import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:models/label/label.dart';

import '../../../../utils/no_scroll_behav.dart';
import '../../../edit_task/ui/labels_list.dart';

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
                        padding: const EdgeInsets.all(12),
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
