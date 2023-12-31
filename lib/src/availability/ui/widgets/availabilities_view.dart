import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/src/availability/ui/cubit/availability_cubit.dart';
import 'package:mobile/src/availability/ui/models/navigation_state.dart';
import 'package:mobile/src/availability/ui/widgets/availability_view_placeholder.dart';
import 'package:mobile/src/availability/ui/widgets/imported_from_material/expandable_panel.dart';
import 'package:mobile/src/availability/ui/widgets/slots_header.dart';
import 'package:mobile/src/base/ui/cubit/sync/sync_cubit.dart';

import 'package:models/task/availability_config.dart';
import 'slot_list.dart';

class AvailabilitiesView extends StatelessWidget {
  const AvailabilitiesView({
    Key? key,
  }) : super(key: key);

  _buildRecurrentEvents(AvailabilityCubitState cubitState, List<AvailabilityConfig> recurrent) {
    return ExpandablePanel(
        isExpanded: cubitState.isRecurrentOpen,
        isHeaderVisible: recurrent.isNotEmpty ? true : false,
        headerBuilder: (context, isExpanded) {
          return GestureDetector(
              onTap: () {
                context.read<AvailabilityCubit>().toggleHeader(AvailabililtyConfigSlotsType.recurrent);
              },
              child: SlotsHeader(
                  type: AvailabililtyConfigSlotsType.recurrent,
                  asset: Assets.images.icons.common.recurrentSVG,
                  text: t.availability.activeRecurrentSlots,
                  isOpen: isExpanded));
        },
        body: SlotList(isOpen: cubitState.isRecurrentOpen, configs: recurrent));
  }

  _buildManualEvents(AvailabilityCubitState cubitState, List<AvailabilityConfig> manual) {
    return ExpandablePanel(
      isExpanded: cubitState.isManualOpen,
      isHeaderVisible: manual.isNotEmpty ? true : false,
      headerBuilder: (context, isExpanded) {
        return SlotsHeader(
            type: AvailabililtyConfigSlotsType.manual,
            asset: Assets.images.icons.common.handDrawSVG,
            text: t.availability.activeManualSlots,
            isOpen: isExpanded);
      },
      body: SlotList(isOpen: cubitState.isManualOpen, configs: manual),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AvailabilityCubit, AvailabilityCubitState>(builder: (context, state) {
      AvailabilityCubitState cubitState = context.watch<AvailabilityCubit>().state;

      if (state.navigationState == AvailabilityNavigationState.loading) {
        return const Center(child: Text('Loading..'));
      }
      if (state.availabilities?.isEmpty ?? true) {
        return const AvailabilityViewPlaceholder();
      }
      List<AvailabilityConfig> manual =
          state.availabilities?.where((element) => element.type == AvailabililtyConfigSlotsType.manual).toList() ?? [];
      List<AvailabilityConfig> recurrent =
          state.availabilities?.where((element) => element.type == AvailabililtyConfigSlotsType.recurrent).toList() ??
              [];

      manual.sort((a, b) {
        return b.updated_at.toString().toLowerCase().compareTo(a.updated_at.toString().toLowerCase());
      });
      recurrent.sort((a, b) {
        return b.updated_at.toString().toLowerCase().compareTo(a.updated_at.toString().toLowerCase());
      });
      return RefreshIndicator(
        onRefresh: () async {
          context.read<SyncCubit>().sync();
          context.read<AvailabilityCubit>().getAvailabilities();
        },
        child: ListView(
          children: [
            ExpandablePanelList(
              elevation: 0,
              expansionCallback: (panelIndex, isExpanded) {
                context.read<AvailabilityCubit>().toggleHeader(
                    panelIndex == 1 ? AvailabililtyConfigSlotsType.manual : AvailabililtyConfigSlotsType.recurrent);
              },
              children: [
                _buildRecurrentEvents(cubitState, recurrent),
                _buildManualEvents(cubitState, manual),
              ],
            ),
          ],
        ),
      );
    });
  }
}
