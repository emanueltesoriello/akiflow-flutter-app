import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/animated_chevron.dart';
import 'package:models/task/task.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader(
    this.title, {
    Key? key,
    required this.tasks,
    required this.listOpened,
    required this.onClick,
  }) : super(key: key);

  final String title;
  final List<Task> tasks;
  final bool listOpened;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox();
    }

    return InkWell(
      onTap: onClick,
      child: Container(
        //  height: 42,
        //  width: double.infinity,
        padding: const EdgeInsets.only(
            top: Dimension.padding, bottom: Dimension.paddingS, left: Dimension.padding, right: Dimension.padding),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.akiflow(context))),
            const SizedBox(width: 4),
            Text("(${tasks.length})",
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey2(context))),
            const Spacer(),
            SvgPicture.asset(
              listOpened ? Assets.images.icons.common.chevronUpSVG : Assets.images.icons.common.chevronDownSVG,
              color: ColorsExt.grey3(context),
              width: Dimension.chevronIconSize,
              height: Dimension.chevronIconSize,
            )
          ],
        ),
      ),
    );
  }
}
