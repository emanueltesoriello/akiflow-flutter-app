import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/availability/ui/cubit/availability_cubit.dart';
import 'package:mobile/src/availability/ui/widgets/availability_view_placeholder.dart';
import 'package:mobile/src/availability/ui/widgets/slots_header.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:models/task/availability_config.dart';

import '../../../../common/style/colors.dart';
import '../../../base/ui/widgets/task/notice.dart';
import 'slot_list.dart';

class AvailabilitiesView extends StatelessWidget {
  const AvailabilitiesView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailabilityCubit, AvailabilityCubitState>(builder: (context, state) {
      if (state.availabilities?.isEmpty ?? true) {
        return const AvailabilityViewPlaceholder();
      }
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          state.isNoticeDismissed
              ? const SizedBox.shrink()
              : GestureDetector(
                  onLongPress: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Notice(
                      title: "Coming Soon",
                      subtitle: "The full calendar experience is coming in the near future",
                      icon: Icons.info_outline,
                      onClose: () {
                        context.read<AvailabilityCubit>().noticeClosed();
                      },
                    ),
                  ),
                ),
          SlotsHeader(
              type: AvailabililtyConfigSlotsType.manual,
              asset: Assets.images.icons.common.handDrawSVG,
              text: 'Active manual slots',
              isOpen: state.isManualOpen),
          const Separator(),
          SlotList(
              isOpen: state.isManualOpen,
              configs: state.availabilities
                      ?.where((element) => element.type == AvailabililtyConfigSlotsType.manual)
                      .toList() ??
                  []),
          SlotsHeader(
              type: AvailabililtyConfigSlotsType.recurrent,
              asset: Assets.images.icons.common.recurrentSVG,
              text: 'Active recurrent slots',
              isOpen: state.isRecurrentOpen),
          SlotList(
              isOpen: state.isRecurrentOpen,
              configs: state.availabilities
                      ?.where((element) => element.type == AvailabililtyConfigSlotsType.recurrent)
                      .toList() ??
                  []),
          const Separator()
        ],
      );
    });
  }
}
