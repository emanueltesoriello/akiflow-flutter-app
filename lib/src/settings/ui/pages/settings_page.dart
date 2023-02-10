import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
//import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/src/base/ui/widgets/base/app_bar.dart';
import 'package:mobile/src/base/ui/widgets/base/button_list.dart';
import 'package:mobile/src/base/ui/widgets/base/notification_count_icon.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/integrations/ui/pages/integrations_page.dart';
import 'package:mobile/src/settings/ui/cubit/settings_cubit.dart';
import 'package:mobile/src/settings/ui/pages/about_page.dart';
import 'package:mobile/src/settings/ui/pages/my_account_page.dart';
import 'package:mobile/src/settings/ui/pages/notifications_page.dart';
import 'package:mobile/src/settings/ui/widgets/settings_header_text.dart';
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
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder(
              future: FirebaseMessaging.instance.getToken(),
              builder: ((context, snapshot) => SelectableText("FCM TOken: ${snapshot.data}"))),
          ButtonList(
            title: t.settings.myAccount.title,
            position: ButtonListPosition.single,
            leading: "assets/images/icons/_common/person_circle.svg",
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const MyAccountPage()));
            },
          ),
          const SizedBox(height: 16),
          SettingHeaderText(text: t.comingSoon),
          ButtonList(
            title: t.settings.general,
            position: ButtonListPosition.top,
            leading: "assets/images/icons/_common/gear_alt.svg",
            enabled: false,
            onPressed: () {},
          ),
          ButtonList(
            title: t.settings.notifications,
            position: ButtonListPosition.center,
            leading: "assets/images/icons/_common/bell.svg",
            enabled: true,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NotificationsPage()));
            },
          ),
          ButtonList(
            title: t.settings.tasks,
            position: ButtonListPosition.bottom,
            leading: "assets/images/icons/_common/Check-done-outline.svg",
            enabled: false,
            onPressed: () {},
          ),
          const SizedBox(height: 16),
          ButtonList(
            title: t.settings.integrations.title,
            leading: "assets/images/icons/_common/puzzle.svg",
            position: ButtonListPosition.single,
            preTrailing: BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(
              builder: (context, state) {
                List<Account> accounts = state.accounts;

                if (accounts.every((account) => context.read<IntegrationsCubit>().isLocalActive(account))) {
                  return const SizedBox();
                }

                int count =
                    accounts.where((account) => !context.read<IntegrationsCubit>().isLocalActive(account)).length;

                return CircleAvatar(
                  backgroundColor: ColorsExt.orange(context),
                  radius: 9,
                  child: Text(
                    count.toString(),
                    style: TextStyle(color: ColorsExt.background(context), fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                );
              },
            ),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const IntegrationsPage()));
            },
          ),
          const SizedBox(height: 16),
          ButtonList(
            title: t.settings.about.title,
            leading: "assets/images/icons/_common/info_circle.svg",
            position: ButtonListPosition.top,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const AboutPage()));
            },
          ),
          ButtonList(
            title: t.settings.learnAkiflow.title,
            leading: "assets/images/icons/_common/guidebook.svg",
            position: ButtonListPosition.center,
            showShevron: false,
            onPressed: () {
              launchUrl(Uri.parse("https://www.notion.so/akiflow/How-to-use-Akiflow-7476c0787ec64e8aa3567bdeb3ab4540"),
                  mode: LaunchMode.externalApplication);
            },
          ),
          ButtonList(
            title: t.settings.changeLog,
            leading: "assets/images/icons/_common/curlybraces.svg",
            position: ButtonListPosition.bottom,
            showShevron: false,
            onPressed: () {
              launchUrl(Uri.parse("https://product.akiflow.com/changelog"), mode: LaunchMode.externalApplication);
            },
          ),
          const SizedBox(height: 16),
          ButtonList(
            title: t.settings.followUsOnTwitter,
            leading: "assets/images/icons/twitter/logo_twitter.svg",
            position: ButtonListPosition.top,
            showShevron: false,
            useSvgColor: true,
            onPressed: () {
              launchUrl(Uri.parse("https://twitter.com/getakiflow"), mode: LaunchMode.externalApplication);
            },
          ),
          ButtonList(
            title: t.settings.joinOurCommunity,
            leading: "assets/images/icons/slack/slack.svg",
            position: ButtonListPosition.center,
            showShevron: false,
            useSvgColor: true,
            onPressed: () {
              launchUrl(Uri.parse("https://akiflow-community.slack.com"), mode: LaunchMode.externalApplication);
            },
          ),
          /*ButtonList(
            title: t.settings.chatWithUs,
            leading: "assets/images/icons/_common/chat_bubble.svg",
            trailingWidget: FutureBuilder<dynamic>(
                future: Intercom.instance.unreadConversationCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return NotifcationCountIcon(snapshot.data);
                  }
                  return const SizedBox();
                }),
            position: ButtonListPosition.mid,
            showShevron: false,
            useSvgColor: true,
            onPressed: () async {
              await context.read<SettingsCubit>().launchIntercom();
            },
          ),*/
          ButtonList(
            title: t.settings.sendUsAnEmail,
            leading: "assets/images/icons/_common/envelope.svg",
            position: ButtonListPosition.bottom,
            showShevron: false,
            useSvgColor: true,
            onPressed: () {
              context.read<SettingsCubit>().sendEmail();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}