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
      List<AvailabilityConfig> manual =
          state.availabilities?.where((element) => element.type == AvailabililtyConfigSlotsType.manual).toList() ?? [];
      List<AvailabilityConfig> recurrent =
          state.availabilities?.where((element) => element.type == AvailabililtyConfigSlotsType.recurrent).toList() ??
              [];
      return RefreshIndicator(
        onRefresh: () => context.read<AvailabilityCubit>().getAvailabilities(),
        child: Column(
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
            manual.isNotEmpty
                ? SlotsHeader(
                    type: AvailabililtyConfigSlotsType.manual,
                    asset: Assets.images.icons.common.handDrawSVG,
                    text: 'Active manual slots',
                    isOpen: context.watch<AvailabilityCubit>().state.isManualOpen)
                : const SizedBox.shrink(),
            SlotList(isOpen: context.watch<AvailabilityCubit>().state.isManualOpen, configs: manual),
            recurrent.isNotEmpty
                ? SlotsHeader(
                    type: AvailabililtyConfigSlotsType.recurrent,
                    asset: Assets.images.icons.common.recurrentSVG,
                    text: 'Active recurrent slots',
                    isOpen: context.watch<AvailabilityCubit>().state.isRecurrentOpen)
                : const SizedBox.shrink(),
            SlotList(isOpen: context.watch<AvailabilityCubit>().state.isRecurrentOpen, configs: recurrent),
            const SizedBox(height: 72)
          ],
        ),
      );
    });
  }
}
