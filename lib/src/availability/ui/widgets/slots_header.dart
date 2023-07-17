import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/availability/ui/cubit/availability_cubit.dart';
import 'package:models/task/availability_config.dart';

import '../../../../common/style/colors.dart';

class SlotsHeader extends StatelessWidget {
  const SlotsHeader({super.key, required this.asset, required this.text, required this.isOpen, required this.type});
  final String asset, text;
  final bool isOpen;
  final AvailabililtyConfigSlotsType type;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.read<AvailabilityCubit>().toggleHeader(type);
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: Dimension.padding),
          SvgPicture.asset(
            asset,
            height: Dimension.smallconSize,
          ),
          const SizedBox(width: Dimension.paddingS),
          Text(text,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(fontWeight: FontWeight.w500, color: ColorsExt.akiflow500(context))),
          const Spacer(),
          Container(
            margin: const EdgeInsetsDirectional.only(end: Dimension.padding),
            child: SvgPicture.asset(
              isOpen ? Assets.images.icons.common.chevronUpSVG : Assets.images.icons.common.chevronDownSVG,
              color: ColorsExt.grey600(context),
              width: Dimension.chevronIconSize,
              height: Dimension.chevronIconSize,
            ),
          )
        ],
      ),
    );
  }
}
