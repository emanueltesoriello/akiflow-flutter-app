import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';

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
  final bool showLinearProgress;
  final double elevation;

  const AppBarComp(
      {Key? key,
      this.title,
      this.titleWidget,
      this.showBack = false,
      this.actions = const [],
      this.onBackClick,
      this.showLogo = false,
      this.leading,
      this.customTitle,
      this.shadow = true,
      this.showLinearProgress = true,
      this.showSyncButton = false,
      this.elevation = 4})
      : super(key: key);

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
      child: BlocBuilder<SyncCubit, SyncCubitState>(
        builder: (context, state) {
          return AppBar(
            centerTitle: false,
            scrolledUnderElevation: 0,
            backgroundColor: ColorsExt.background(context),
            surfaceTintColor: ColorsExt.background(context),
            bottom: (showSyncButton == false || state.loading == false)
                ? PreferredSize(
                    preferredSize: Size.zero,
                    child: Container(height: Dimension.progressIndicatorSize / 2),
                  )
                : showLinearProgress
                    ? PreferredSize(
                        preferredSize: const Size.fromHeight(Dimension.progressIndicatorSize),
                        child: LinearProgressIndicator(
                          value: null,
                          minHeight: Dimension.progressIndicatorSize / 2,
                          backgroundColor: ColorsExt.background(context),
                        ),
                      )
                    : PreferredSize(
                        preferredSize: Size.zero,
                        child: Container(height: Dimension.progressIndicatorSize / 2),
                      ),
            elevation: elevation,
            automaticallyImplyLeading: false,
            shadowColor: shadow ? const Color.fromRGBO(0, 0, 0, 0.3) : null,
            title: _buildTitle(context),
            titleSpacing: leading != null || showBack == true ? 0 : Dimension.padding,
            leading: _buildLeading(context),
            actions: _buildActions(context),
          );
        },
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
            Assets.images.icons.common.arrowLeftSVG,
            width: 26,
            height: 26,
            color: ColorsExt.grey800(context),
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
            Assets.images.icons.common.arrowLeftSVG,
            height: 26,
            width: 26,
            color: ColorsExt.grey800(context),
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
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.w500,
              color: ColorsExt.grey800(context),
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

    return Text(title!,
        textAlign: TextAlign.start,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context)
            .textTheme
            .titleLarge!
            .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey800(context)));
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
          if (state.networkError) {
            return SizedBox(
              height: Dimension.defaultIconSize,
              width: Dimension.defaultIconSize,
              child: SvgPicture.asset(
                Assets.images.icons.common.wifiSlashSVG,
                color: ColorsExt.buttercup400(context),
              ),
            );
          }
          if (showSyncButton == false || state.loading == false) {
            return const SizedBox();
          }
          return Container();
        },
      ),
      const SizedBox(width: Dimension.paddingS),
      ...actions,
    ];
  }
}
