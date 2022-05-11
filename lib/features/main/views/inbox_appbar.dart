import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';

class InboxAppBar extends StatelessWidget {
  final String title;
  final String? leadingAsset;

  const InboxAppBar({
    Key? key,
    required this.title,
    this.leadingAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBarComp(
      title: title,
      leading: _leading(context),
      actions: [
        IconButton(
          icon: SvgPicture.asset(
            "assets/images/icons/_common/ellipsis.svg",
            width: 26,
            height: 26,
            color: ColorsExt.grey2(context),
          ),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _leading(BuildContext context) {
    bool selectMode = context.watch<TasksCubit>().state.inboxTasks.any((element) => element.selected ?? false);

    if (selectMode) {
      return InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          context.read<TasksCubit>().clearSelected();
        },
        child: SvgPicture.asset(
          "assets/images/icons/_common/arrow_left.svg",
          width: 26,
          height: 26,
          color: ColorsExt.grey2(context),
        ),
      );
    } else {
      if (leadingAsset == null) {
        return const SizedBox();
      }

      return SvgPicture.asset(
        leadingAsset!,
        width: 26,
        height: 26,
        color: ColorsExt.grey2(context),
      );
    }
  }
}
