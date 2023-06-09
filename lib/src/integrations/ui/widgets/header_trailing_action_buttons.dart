import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/integrations_utils.dart';
import 'package:models/account/account.dart';
import 'package:url_launcher/url_launcher.dart';

class HeaderTrailingActionButtons extends StatelessWidget {
  final Account account;

  const HeaderTrailingActionButtons(this.account, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: () {
            launchUrl(Uri.parse(IntegrationsUtils.howToLinkFromConnectorId(account.connectorId)),
                mode: LaunchMode.externalApplication);
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimension.paddingS),
            child: SvgPicture.asset(
              Assets.images.icons.common.guidebookSVG,
              width: 24,
              height: 24,
              color: ColorsExt.grey600(context),
            ),
          ),
        ),
        const SizedBox(width: Dimension.paddingS),
        InkWell(
          onTap: () {
            launchUrl(Uri.parse("https://www.notion.so/akiflow/Security-6d61cefd8c2349b2b4d5561aa82f1832"),
                mode: LaunchMode.externalApplication);
          },
          child: Padding(
            padding: const EdgeInsets.all(Dimension.paddingS),
            child: SvgPicture.asset(
              Assets.images.icons.common.lockShieldSVG,
              width: 24,
              height: 24,
              color: ColorsExt.yorkGreen400(context),
            ),
          ),
        ),
        const SizedBox(width: Dimension.paddingSM),
      ],
    );
  }
}
