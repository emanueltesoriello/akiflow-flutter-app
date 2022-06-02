import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';

class AppBarComp extends StatelessWidget implements PreferredSizeWidget {
  final bool showBack;
  final String? title;
  final List<Widget> actions;
  final Function()? onBackClick;
  final bool showLogo;
  final Widget? leading;
  final Widget? customTitle;
  final Widget? child;

  const AppBarComp({
    Key? key,
    this.title,
    this.showBack = false,
    this.actions = const [],
    this.onBackClick,
    this.showLogo = false,
    this.leading,
    this.customTitle,
    this.child,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(useMaterial3: false),
      child: AppBar(
        centerTitle: false,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        elevation: 4,
        automaticallyImplyLeading: false,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.3),
        title: _buildTitle(context),
        titleSpacing: leading != null ? 0 : 16,
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
      return Center(
        child: InkWell(
          onTap: (() => Navigator.pop(context)),
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
      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 24, color: ColorsExt.grey2(context)),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      Container(width: 16),
      ...actions,
    ];
  }
}
