import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

class UndoBottomView extends StatelessWidget {
  const UndoBottomView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        if (state.queue.isEmpty) {
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
                            state.queue.first.type.text,
                            style:
                                TextStyle(color: ColorsExt.grey2(context), fontWeight: FontWeight.w500, fontSize: 15),
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              context.read<TasksCubit>().undo();
                            },
                            child: Text(t.task.undo.toUpperCase(),
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
