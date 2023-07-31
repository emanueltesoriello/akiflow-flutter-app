import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list_menu.dart';
import 'package:mobile/src/settings/ui/widgets/someday_body.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

class SomedayPage extends StatelessWidget {
  const SomedayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, tasksState) {
        return Scaffold(
          backgroundColor: ColorsExt.background(context),
          appBar: AppBarComp(
            title: t.task.someday,
            showLinearProgress: true,
            leading: SvgPicture.asset(
              Assets.images.icons.common.archiveboxSVG,
              width: Dimension.appBarLeadingIcon,
              height: Dimension.appBarLeadingIcon,
              color: ColorsExt.grey800(context),
            ),
            actions: const [TaskListMenu()],
            showSyncButton: true,
          ),
          body: const SomedayBody(),
        );
      },
    );
  }
}
