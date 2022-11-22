import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';

import '../widgets/availabilities_view.dart';

class AvailabilityView extends StatelessWidget {
  const AvailabilityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBarComp(
          title: "Availabilities",
          leading: SvgPicture.asset(
            Assets.images.icons.common.availabilitySVG,
            width: 26,
            height: 26,
            color: ColorsExt.grey1(context),
          ),
          showSyncButton: true,
        ),
        body: const AvailabilitiesView());
  }
}
