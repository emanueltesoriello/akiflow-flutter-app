import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/features/settings/ui/integrations/integration_list_item.dart';
import 'package:mobile/style/colors.dart';

class IntegrationsPage extends StatelessWidget {
  const IntegrationsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarComp(
            title: t.settings.integrations.title,
            showBack: true,
            showSyncButton: false,
          ),
          Expanded(
            child: ContainerInnerShadow(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Text(
                  //   t.settings.integrations.connected.toUpperCase(),
                  //   style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                  // ),
                  // const SizedBox(height: 4),
                  // IntegrationListItem(
                  //   leadingWidget: SvgPicture.asset(
                  //     "assets/images/icons/google/calendar.svg",
                  //   ),
                  //   title: t.settings.integrations.gmail.title,
                  //   onPressed: () {},
                  // ),
                  // const SizedBox(height: 16),
                  Text(
                    t.more.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                  ),
                  const SizedBox(height: 4),
                  IntegrationListItem(
                    position: IntegrationListItemPosition.top,
                    leadingWidget: SvgPicture.asset(
                      "assets/images/icons/google/calendar.svg",
                    ),
                    title: t.settings.integrations.calendar.title,
                    onPressed: () {},
                    enabled: false,
                    trailingWidget: const SizedBox(),
                  ),
                  IntegrationListItem(
                    position: IntegrationListItemPosition.center,
                    leadingWidget: SvgPicture.asset(
                      "assets/images/icons/google/gmail.svg",
                    ),
                    title: t.settings.integrations.gmail.title,
                    enabled: false,
                    trailingWidget: const SizedBox(),
                    onPressed: () {},
                  ),
                  IntegrationListItem(
                    position: IntegrationListItemPosition.bottom,
                    leadingWidget: SvgPicture.asset(
                      "assets/images/icons/slack/slack.svg",
                    ),
                    title: t.settings.integrations.slack.title,
                    enabled: false,
                    onPressed: () {},
                    trailingWidget: const SizedBox(),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
