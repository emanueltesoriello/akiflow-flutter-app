import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/home/ui/cubit/today/today_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:models/task/task.dart';

class JustCreatedTaskView extends StatefulWidget {
  const JustCreatedTaskView({Key? key}) : super(key: key);

  @override
  State<JustCreatedTaskView> createState() => _JustCreatedTaskViewState();
}

class _JustCreatedTaskViewState extends State<JustCreatedTaskView> {
  int snackBarShown = 0;

  _buildSnackBar(TasksCubitState state) {
    return SnackBar(
      padding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      content: Padding(
        padding: const EdgeInsets.only(bottom: Dimension.padding),
        child: Container(
          height: Dimension.snackBarHeight,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: Dimension.padding),
          decoration: BoxDecoration(
            color: ColorsExt.grey6(context),
            border: Border.all(color: ColorsExt.grey5(context), width: 1),
            borderRadius: BorderRadius.circular(Dimension.radiusS),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: Dimension.padding),
            child: Row(
              children: [
                Expanded(
                  child: Text(t.task.taskCreatedSuccessfully,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1
                          ?.copyWith(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500)),
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
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: ColorsExt.akiflow(context), fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TasksCubit, TasksCubitState>(
        listener: (context, state) => {
              if (state.justCreatedTask != null && snackBarShown == 0)
                {
                  snackBarShown += 1,
                  ScaffoldMessenger.of(context).showSnackBar(_buildSnackBar(state)),
                }
              else if (state.justCreatedTask == null)
                {snackBarShown = 0}
            },
        child: const SizedBox(height: 0)
        /* return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Material(color: Colors.transparent, child: _buildSnackBar(context, state)),
            SizedBox(height: MediaQuery.of(context).padding.bottom + Dimension.bottomBarHeight + Dimension.padding),
          ],
        );*/

        );
  }
}
