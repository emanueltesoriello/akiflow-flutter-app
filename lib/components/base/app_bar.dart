import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/sync_progress.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';

class AppBarComp extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final Widget? titleWidget;
  final List<Widget> actions;
  final Function()? onBackClick;
  final bool showLogo;
  final Widget? leading;
  final Widget? customTitle;
  final bool shadow;
  final bool showSyncButton;

  const AppBarComp({
    Key? key,
    this.title,
    this.titleWidget,
    this.showBack = false,
    this.actions = const [],
    this.onBackClick,
    this.showLogo = false,
    this.leading,
    this.customTitle,
    this.shadow = true,
    this.showSyncButton = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ColorsExt.background(context),
        boxShadow: shadow
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.05),
                  offset: Offset(0, -1),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: AppBar(
        centerTitle: false,
        backgroundColor: ColorsExt.background(context),
        surfaceTintColor: ColorsExt.background(context),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          
        ),
        elevation: 4,
        automaticallyImplyLeading: false,
        shadowColor: shadow ? const Color.fromRGBO(0, 0, 0, 0.3) : null,
        title: _buildTitle(context),
        titleSpacing: leading != null || showBack == true ? 0 : 16,
        leading: _buildLeading(context),
        actions: _buildActions(context),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (TaskExt.isSelectMode(context.watch<TasksCubit>().state)) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          context.read<TasksCubit>().clearSelected();
        },
        child: Center(
          child: SvgPicture.asset(
            "assets/images/icons/_common/arrow_left.svg",
            width: 26,
            height: 26,
            color: ColorsExt.grey2(context),
          ),
        ),
      );
    }

    if (leading != null) {
      return Center(child: leading!);
    }

    if (showBack) {
      return InkWell(
        onTap: (() => Navigator.pop(context)),
        child: Center(
          child: SvgPicture.asset(
            "assets/images/icons/_common/arrow_left.svg",
            height: 26,
            width: 26,
            color: ColorsExt.grey2(context),
          ),
        ),
      );
    }

    return null;
  }

  Widget _buildTitle(BuildContext context) {
    TasksCubit bloc = context.watch<TasksCubit>();

    int tasksSelected = TaskExt.countTasksSelected(bloc.state);

    if (tasksSelected != 0) {
      return Text(
        t.task.nSelected(count: tasksSelected),
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w500,
          color: ColorsExt.grey2(context),
        ),
      );
    }

    if (titleWidget != null) {
      return titleWidget!;
    }

    if (customTitle != null) {
      return customTitle!;
    }

    if (title == null) {
      return const SizedBox();
    }

    return Text(
      title!,
      textAlign: TextAlign.start,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 22, color: ColorsExt.grey2(context)),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    TasksCubit bloc = context.watch<TasksCubit>();

    int tasksSelected = TaskExt.countTasksSelected(bloc.state);

    if (tasksSelected != 0) {
      return [];
    }

    return [
      BlocBuilder<SyncCubit, SyncCubitState>(
        builder: (context, state) {
          if (showSyncButton == false || state.loading == false) {
            return const SizedBox();
          }

          return const SyncProgress();
        },
      ),
      const SizedBox(width: 8),
      ...actions,
    ];
  }
}
