import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/button_list_divider.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
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
          ),
          Expanded(
            child: ContainerInnerShadow(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ButtonList(
                    title: t.settings.upgradeToPro,
                    position: ButtonListPosition.top,
                    leading: "assets/images/icons/_common/crown.svg",
                    leadingColor: Theme.of(context).primaryColor,
                    showShevron: false,
                    onPressed: () {
                      // TODO SETTINGS - upgrade to pro event
                    },
                  ),
                  ButtonList(
                    title: t.settings.myAccount,
                    position: ButtonListPosition.center,
                    leading: "assets/images/icons/_common/person_circle.svg",
                    onPressed: () {
                      // TODO SETTINGS - my account settings event
                    },
                  ),
                  ButtonList(
                    title: t.settings.general,
                    position: ButtonListPosition.onlyHorizontalPadding,
                    leading: "assets/images/icons/_common/gear_alt.svg",
                    onPressed: () {
                      // TODO SETTINGS - general settings event
                    },
                  ),
                  ButtonList(
                    title: t.settings.tasks,
                    position: ButtonListPosition.center,
                    leading: "assets/images/icons/_common/Check-done-outline.svg",
                    onPressed: () {
                      // TODO SETTINGS - tasks settings event
                    },
                  ),
                  ButtonList(
                    title: t.settings.notifications,
                    position: ButtonListPosition.bottom,
                    leading: "assets/images/icons/_common/bell.svg",
                    onPressed: () {
                      // TODO SETTINGS - notifications settings event
                    },
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
                    title: t.settings.referYourFriends,
                    leading: "assets/images/icons/_common/gift.svg",
                    position: ButtonListPosition.top,
                    onPressed: () {
                      // TODO SETTINGS - refer friend event
                    },
                  ),
                  ButtonList(
                    title: t.settings.helpCenter,
                    leading: "assets/images/icons/_common/guidebook.svg",
                    position: ButtonListPosition.center,
                    onPressed: () {
                      // TODO SETTINGS - help center event
                    },
                  ),
                  ButtonList(
                    title: t.settings.about,
                    leading: "assets/images/icons/_common/info_circle.svg",
                    position: ButtonListPosition.bottom,
                    onPressed: () {
                      // TODO SETTINGS - about event
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.followUsOnTwitter,
                    leading: "assets/images/icons/twitter/twitter.svg",
                    position: ButtonListPosition.top,
                    showShevron: false,
                    onPressed: () {
                      launchUrl(Uri.parse("https://twitter.com/getakiflow"));
                    },
                  ),
                  const ButtonListDivider(),
                  ButtonList(
                    title: t.settings.joinOurCommunity,
                    leading: "assets/images/icons/slack/slack.svg",
                    position: ButtonListPosition.bottom,
                    showShevron: false,
                    onPressed: () {
                      launchUrl(Uri.parse("https://akiflow-community.slack.com"));
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
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.logout,
                    position: ButtonListPosition.single,
                    onPressed: () {
                      context.read<AuthCubit>().logout();

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const AuthPage()), (Route<dynamic> route) => false);
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
