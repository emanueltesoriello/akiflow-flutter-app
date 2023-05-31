import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:models/account/account.dart';

class ChooseConferenceModal extends StatelessWidget {
  final Function(String, String) onChange;
  const ChooseConferenceModal({super.key, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
      builder: (context, state) {
        List<Account> zoomAccounts = state.accounts.where((element) => element.connectorId == "zoom").toList();

        return Material(
          color: Theme.of(context).backgroundColor,
          child: Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Dimension.radiusM),
                topRight: Radius.circular(Dimension.radiusM),
              ),
            ),
            margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: ListView(
              shrinkWrap: true,
              children: [
                const SizedBox(height: Dimension.padding),
                const ScrollChip(),
                const SizedBox(height: Dimension.padding),
                Padding(
                  padding: const EdgeInsets.all(Dimension.padding),
                  child: Row(
                    children: [
                      const SizedBox(width: Dimension.paddingS),
                      Text(
                        'Choose conference account',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: ColorsExt.grey800(context),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                _item(
                  context,
                  isZoom: false,
                  text: t.event.googleMeet,
                  click: () {
                    onChange('meet', '');
                    Navigator.pop(context);
                  },
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: zoomAccounts.length,
                  itemBuilder: (context, index) {
                    return _item(
                      context,
                      isZoom: true,
                      text: 'Zoom: ${zoomAccounts[index].identifier}',
                      click: () {
                        onChange(zoomAccounts[index].connectorId ?? '', zoomAccounts[index].id ?? '');
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                const SizedBox(height: Dimension.paddingXL),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _item(
    BuildContext context, {
    required bool isZoom,
    required String text,
    required Function() click,
  }) {
    return InkWell(
      onTap: click,
      child: Container(
        padding: const EdgeInsets.all(Dimension.padding),
        child: Row(
          children: [
            SizedBox(
              width: Dimension.defaultIconSize,
              height: Dimension.defaultIconSize,
              child: SvgPicture.asset(isZoom ? Assets.images.icons.zoom.zoomSVG : Assets.images.icons.google.meetSVG),
            ),
            const SizedBox(width: Dimension.paddingXS),
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.subtitle1?.copyWith(color: ColorsExt.grey800(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
