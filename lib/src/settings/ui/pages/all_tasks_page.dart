import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/task/task_list_menu.dart';

class AllTasksPage extends StatelessWidget {
  const AllTasksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBarComp(
          title: t.allTasks,
          showLinearProgress: true,
          leading: SvgPicture.asset(
            Assets.images.icons.common.rectangleGrid1X2SVG,
            width: Dimension.appBarLeadingIcon,
            height: Dimension.appBarLeadingIcon,
            color: ColorsExt.grey900(context),
          ),
          actions: const [TaskListMenu()],
          showSyncButton: true,
        ),
        body: Container());
  }
}
