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
    return GestureDetector(
      onTap: () {
        context.read<AvailabilityCubit>().toggleHeader(type);
      },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: 16),
          SvgPicture.asset(asset),
          const SizedBox(width: 16),
          Text(
            text,
            style: TextStyle(color: ColorsExt.akiflow(context), fontWeight: FontWeight.w500),
          ),
        ],
      ),
      //const Separator(),
    );
  }
}
