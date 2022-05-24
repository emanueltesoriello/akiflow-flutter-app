import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/my_account_page.dart';
import 'package:mobile/style/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarComp(
            title: t.settings.title,
            showBack: true,
            showSyncButton: false,
          ),
          Expanded(
            child: ContainerInnerShadow(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
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
                  Text(
                    t.comingSoon.toUpperCase(),
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: ColorsExt.grey3(context)),
                  ),
                  const SizedBox(height: 4),
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
                    title: t.settings.integrations,
                    leading: "assets/images/icons/_common/puzzle.svg",
                    position: ButtonListPosition.single,
                    onPressed: () {
                      // TODO SETTINGS - integrations
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.about,
                    leading: "assets/images/icons/_common/info_circle.svg",
                    position: ButtonListPosition.top,
                    onPressed: () {
                      // TODO SETTINGS - about event
                    },
                  ),
                  ButtonList(
                    title: t.settings.learnAkiflow,
                    leading: "assets/images/icons/_common/guidebook.svg",
                    position: ButtonListPosition.center,
                    showShevron: false,
                    onPressed: () {
                      // TODO SETTINGS - refer friend event
                    },
                  ),
                  ButtonList(
                    title: t.settings.changeLog,
                    leading: "assets/images/icons/_common/curlybraces.svg",
                    position: ButtonListPosition.bottom,
                    showShevron: false,
                    onPressed: () {
                      // TODO SETTINGS - help center event
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
                      launchUrl(Uri.parse("https://twitter.com/getakiflow"));
                    },
                  ),
                  ButtonList(
                    title: t.settings.joinOurCommunity,
                    leading: "assets/images/icons/slack/slack.svg",
                    position: ButtonListPosition.center,
                    showShevron: false,
                    useSvgColor: true,
                    onPressed: () {
                      launchUrl(Uri.parse("https://akiflow-community.slack.com"));
                    },
                  ),
                  ButtonList(
                    title: t.settings.sendUsAnEmail,
                    leading: "assets/images/icons/_common/envelope.svg",
                    position: ButtonListPosition.bottom,
                    showShevron: false,
                    useSvgColor: true,
                    onPressed: () {
                      launchUrl(Uri.parse("mailto:support@akiflow.com"));
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.bugReport,
                    position: ButtonListPosition.single,
                    onPressed: () {
                      context.read<SettingsCubit>().bugReport();
                    },
                  ),
                  BlocBuilder<SettingsCubit, SettingsCubitState>(
                    builder: (context, state) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          state.appVersion ?? "",
                          textAlign: TextAlign.end,
                        ),
                      );
                    },
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
