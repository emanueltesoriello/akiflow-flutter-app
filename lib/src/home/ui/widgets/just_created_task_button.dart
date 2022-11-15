import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:models/task/task.dart';

class JustCreatedTaskView extends StatelessWidget {
  const JustCreatedTaskView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        if (state.justCreatedTask == null) {
          return const SizedBox();
        }

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(
              color: Colors.transparent,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 51,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: ColorsExt.grey6(context),
                    border: Border.all(
                      color: ColorsExt.grey5(context),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            t.task.taskCreatedSuccessfully,
                            style:
                                TextStyle(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              Task task = state.justCreatedTask!;

                              TaskStatusType? statusType = task.statusType;
                              String? date = task.date;

                              if (statusType == null || statusType == TaskStatusType.inbox) {
                                context.read<MainCubit>().changeHomeView(HomeViewType.inbox);
                              } else {
                                if (date != null) {
                                  DateTime dateParsed = DateTime.parse(date);
                                  context.read<MainCubit>().changeHomeView(HomeViewType.today);
                                  context.read<TodayCubit>().onDateSelected(dateParsed);
                                } else {
                                  context.read<MainCubit>().changeHomeView(HomeViewType.today);
                                }
                              }

                              TaskExt.editTask(context, task);
                            },
                            child: Text(t.view.toUpperCase(),
                                style: TextStyle(
                                    color: ColorsExt.akiflow(context), fontWeight: FontWeight.w500, fontSize: 15))),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + bottomBarHeight + 16),
          ],
        );
      },
    );
  }
}
