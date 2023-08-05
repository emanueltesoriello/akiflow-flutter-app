import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/button_list.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/pages/integrations_page.dart';
import 'package:mobile/src/settings/ui/cubit/settings_cubit.dart';
import 'package:mobile/src/settings/ui/pages/about_page.dart';
import 'package:mobile/src/settings/ui/pages/calendar_settings_page.dart';
import 'package:mobile/src/settings/ui/pages/general_settings_page.dart';
import 'package:mobile/src/settings/ui/pages/my_account_page.dart';
import 'package:mobile/src/settings/ui/pages/notifications_page.dart';
import 'package:mobile/src/base/ui/widgets/base/settings_header_text.dart';
import 'package:models/account/account.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComp(
        title: t.settings.title,
        showBack: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(Dimension.padding),
        children: [
          if (kDebugMode)
            FutureBuilder(
                future: FirebaseMessaging.instance.getToken(),
                builder: ((context, snapshot) => SelectableText("FCM TOken: ${snapshot.data}"))),
          ButtonList(
            title: t.settings.general.general,
            position: ButtonListPosition.top,
            leading: Assets.images.icons.common.gearAltSVG,
            enabled: true,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const GeneralSettingsPage()));
            },
          ),
          ButtonList(
            title: t.settings.myAccount.title,
            position: ButtonListPosition.center,
            leading: Assets.images.icons.common.personCircleSVG,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyAccountPage()));
            },
          ),
          ButtonList(
            title: t.settings.integrations.title,
            leading: Assets.images.icons.common.puzzleSVG,
            position: ButtonListPosition.center,
            preTrailing: BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
              builder: (context, state) {
                List<Account> accounts = state.accounts;

                if (accounts.every((account) => context.read<IntegrationsCubit>().isLocalActive(account))) {
                  return const SizedBox();
                }

                int count =
                    accounts.where((account) => !context.read<IntegrationsCubit>().isLocalActive(account)).length;

                return CircleAvatar(
                  backgroundColor: ColorsExt.apricot400(context),
                  radius: Dimension.radius,
                  child: Text(
                    count.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: ColorsExt.background(context),
                        ),
                  ),
                );
              },
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const IntegrationsPage()));
            },
          ),
          ButtonList(
            title: t.settings.calendar,
            position: ButtonListPosition.mid,
            leading: Assets.images.icons.common.calendarSVG,
            enabled: true,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const CalendarSettingsPage()));
            },
          ),
          ButtonList(
            title: t.settings.notifications,
            position: ButtonListPosition.bottom,
            leading: Assets.images.icons.common.bellSVG,
            enabled: true,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsPage()));
            },
          ),
          const SizedBox(height: Dimension.padding),
          SettingHeaderText(text: t.comingSoon),
          ButtonList(
            title: t.settings.tasks,
            position: ButtonListPosition.single,
            leading: Assets.images.icons.common.checkDoneOutlineSVG,
            enabled: false,
            onPressed: () {},
          ),
          const SizedBox(height: Dimension.padding),
          ButtonList(
            title: t.settings.about.title,
            leading: Assets.images.icons.common.infoCircleSVG,
            position: ButtonListPosition.top,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
          ButtonList(
            title: t.settings.learnAkiflow.title,
            leading: Assets.images.icons.common.guidebookSVG,
            position: ButtonListPosition.mid,
            showShevron: false,
            onPressed: () {
              launchUrl(Uri.parse("https://www.notion.so/akiflow/How-to-use-Akiflow-7476c0787ec64e8aa3567bdeb3ab4540"),
                  mode: LaunchMode.externalApplication);
            },
          ),
          ButtonList(
            title: t.settings.changeLog,
            leading: Assets.images.icons.common.curlybracesSVG,
            position: ButtonListPosition.bottom,
            showShevron: false,
            onPressed: () {
              launchUrl(Uri.parse("https://product.akiflow.com/changelog"), mode: LaunchMode.externalApplication);
            },
          ),
          const SizedBox(height: Dimension.padding),
          ButtonList(
            title: t.settings.followUsOnTwitter,
            leading: Assets.images.icons.twitter.logoTwitterSVG,
            position: ButtonListPosition.top,
            showShevron: false,
            useSvgColor: true,
            onPressed: () {
              launchUrl(Uri.parse("https://twitter.com/getakiflow"), mode: LaunchMode.externalApplication);
            },
          ),
          ButtonList(
            title: t.settings.joinOurCommunity,
            leading: Assets.images.icons.slack.slackSVG,
            position: ButtonListPosition.center,
            showShevron: false,
            useSvgColor: true,
            onPressed: () {
              launchUrl(Uri.parse("https://akiflow-community.slack.com"), mode: LaunchMode.externalApplication);
            },
          ),
          ButtonList(
            title: t.settings.chatWithUs,
            leading: "assets/images/icons/_common/chat_bubble.svg",
            position: ButtonListPosition.mid,
            showShevron: false,
            useSvgColor: true,
            onPressed: () async {
              context.read<SettingsCubit>().openIntercomPage();
            },
          ),
          ButtonList(
            title: t.settings.sendUsAnEmail,
            leading: Assets.images.icons.common.envelopeSVG,
            position: ButtonListPosition.bottom,
            showShevron: false,
            useSvgColor: true,
            onPressed: () {
              context.read<SettingsCubit>().sendEmail();
            },
          ),
          const SizedBox(height: Dimension.padding),
        ],
      ),
    );
  }
}
