import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/aki_chip.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class AddTaskModal extends StatelessWidget {
  AddTaskModal({Key? key}) : super(key: key);

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.transparent,
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
            ),
            child: Container(
              color: Theme.of(context).backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        hintText: t.addTask.titleHint,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: ColorsExt.grey3(context),
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: TextStyle(
                        color: ColorsExt.grey2(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.only(bottom: 16),
                        isDense: true,
                        hintText: t.addTask.descriptionHint,
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: ColorsExt.grey3(context),
                          fontSize: 17,
                        ),
                      ),
                      style: TextStyle(
                        color: ColorsExt.grey2(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        AkiChip(
                          icon: "assets/images/icons/_common/calendar.svg",
                          iconSize: 18,
                          text: t.addTask.plan,
                          onPressed: () {
                            // TODO task plan
                          },
                        ),
                        const SizedBox(width: 8),
                        AkiChip(
                          icon: "assets/images/icons/_common/hourglass.svg",
                          iconSize: 18,
                          onPressed: () {
                            // TODO task duration
                          },
                        ),
                        const SizedBox(width: 8),
                        AkiChip(
                          icon: "assets/images/icons/_common/number.svg",
                          iconSize: 18,
                          onPressed: () {
                            // TODO task label
                          },
                        ),
                        const Spacer(),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Task task = Task(
                              (task) => task
                                ..title = _titleController.text
                                ..description = _descriptionController.text
                                ..status = TaskStatusType.inbox.id,
                            );

                            context.read<TasksCubit>().addTask(task);

                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Material(
                            color: Theme.of(context).primaryColor,
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              height: 36,
                              width: 36,
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/images/icons/_common/paperplane_send.svg",
                                  width: 24,
                                  height: 24,
                                  color: Theme.of(context).backgroundColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
