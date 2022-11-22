import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mobile/assets.dart';
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
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          SvgPicture.asset(asset),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(color: ColorsExt.akiflow(context), fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              print(isOpen);
              context.read<AvailabilityCubit>().toggleHeader(type);
            },
            child: SvgPicture.asset(context.watch<AvailabilityCubit>().state.isManualOpen
                ? Assets.images.icons.common.chevronUpSVG
                : Assets.images.icons.common.chevronDownSVG),
          ),
        ],
      ),
    );
  }
}
