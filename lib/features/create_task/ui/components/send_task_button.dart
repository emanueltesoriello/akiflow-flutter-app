import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:models/task/task.dart';

import '../../../edit_task/cubit/edit_task_cubit.dart';

class SendTaskButton extends StatelessWidget {
  const SendTaskButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();

        context.read<EditTaskCubit>().create();

        Task taskUpdated = context.read<EditTaskCubit>().state.updatedTask;

        Navigator.pop(context, taskUpdated);
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
              Assets.images.icons.common.paperplaneSendSVG,
              width: 24,
              height: 24,
              color: Theme.of(context).backgroundColor,
            ),
          ),
        ),
      ),
    );
  }
}
