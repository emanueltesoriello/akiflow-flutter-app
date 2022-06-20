import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/about_page.dart';
import 'package:mobile/features/settings/ui/integrations_page.dart';
import 'package:mobile/features/settings/ui/my_account_page.dart';
import 'package:mobile/features/settings/ui/view/settings_header_text.dart';
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
            enabled: false,
            onPressed: () {},
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
          ButtonList(
            title: t.settings.chatWithUs,
            leading: "assets/images/icons/_common/intercom.svg",
            trailingWidget: FutureBuilder<dynamic>(
                future: Intercom.instance.unreadConversationCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Visibility(
                      visible: snapshot.data>0,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          snapshot.data.toString(),
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    );
                  }
                  return const SizedBox();
                }),
            position: ButtonListPosition.bottom,
            showShevron: false,
            useSvgColor: true,
            onPressed: () {
              context.read<SettingsCubit>().launchIntercom();
            },
          ),
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
