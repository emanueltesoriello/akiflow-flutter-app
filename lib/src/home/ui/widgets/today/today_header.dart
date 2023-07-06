import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';

class TodayHeader extends StatelessWidget {
  const TodayHeader(
    this.title, {
    Key? key,
    required this.tasksLenght,
    required this.listOpened,
    required this.onClick,
  }) : super(key: key);

  final String title;
  final int tasksLenght;
  final bool listOpened;
  final Function() onClick;

  @override
  Widget build(BuildContext context) {
    if (tasksLenght == 0) {
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
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.akiflow500(context))),
            const SizedBox(width: 4),
            Text(tasksLenght.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey800(context))),
            const Spacer(),
            SvgPicture.asset(
              listOpened ? Assets.images.icons.common.chevronUpSVG : Assets.images.icons.common.chevronDownSVG,
              color: ColorsExt.grey600(context),
              width: Dimension.chevronIconSize,
              height: Dimension.chevronIconSize,
            )
          ],
        ),
      ),
    );
  }
}
