import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/button_list_divider.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
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
            actions: [
              IconButton(
                icon: Icon(
                  SFSymbols.arrow_2_circlepath,
                  size: 18,
                  color: ColorsExt.grey2(context),
                ),
                onPressed: () {
                  context.read<TasksCubit>().refresh();
                },
              ),
            ],
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
                    leading: SFSymbols.person, // TODO  svg for crown icons
                    leadingColor: Theme.of(context).primaryColor,
                    showShevron: false,
                    onPressed: () {
                      // TODO upgrade to pro event
                    },
                  ),
                  ButtonList(
                    title: t.settings.myAccount,
                    position: ButtonListPosition.center,
                    leading: SFSymbols.person_circle,
                    onPressed: () {
                      // TODO my account settings event
                    },
                  ),
                  ButtonList(
                    title: t.settings.general,
                    position: ButtonListPosition.onlyHorizontalPadding,
                    leading: SFSymbols.gear_alt,
                    onPressed: () {
                      // TODO general settings event
                    },
                  ),
                  ButtonList(
                    title: t.settings.tasks,
                    position: ButtonListPosition.center,
                    leading: SFSymbols.checkmark,
                    onPressed: () {
                      // TODO tasks settings event
                    },
                  ),
                  ButtonList(
                    title: t.settings.notifications,
                    position: ButtonListPosition.bottom,
                    leading: SFSymbols.bell,
                    onPressed: () {
                      // TODO notifications settings event
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.integrations,
                    leading:
                        SFSymbols.person, // TODO svg for integrations icons
                    position: ButtonListPosition.single,
                    onPressed: () {
                      // TODO logout event
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.referYourFriends,
                    leading: SFSymbols
                        .person, // TODO  svg for refer_your_friends icons
                    position: ButtonListPosition.top,
                    onPressed: () {
                      // TODO refer friend event
                    },
                  ),
                  ButtonList(
                    title: t.settings.helpCenter,
                    leading:
                        SFSymbols.person, // TODO  svg for help center icons
                    position: ButtonListPosition.center,
                    onPressed: () {
                      // TODO refer help center event
                    },
                  ),
                  ButtonList(
                    title: t.settings.about,
                    leading: SFSymbols.info_circle,
                    position: ButtonListPosition.bottom,
                    onPressed: () {
                      // TODO refer about event
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.followUsOnTwitter,
                    leading: SFSymbols.person, // TODO  svg for twitter icon
                    position: ButtonListPosition.top,
                    showShevron: false,
                    onPressed: () {
                      launch("https://twitter.com/getakiflow");
                    },
                  ),
                  const ButtonListDivider(),
                  ButtonList(
                    title: t.settings.joinOurCommunity,
                    leading: SFSymbols.info_circle, // TODO  svg for slack icon
                    position: ButtonListPosition.bottom,
                    showShevron: false,
                    onPressed: () {
                      launch("https://akiflow-community.slack.com");
                    },
                  ),
                  const SizedBox(height: 16),
                  ButtonList(
                    title: t.settings.logout,
                    position: ButtonListPosition.single,
                    onPressed: () {
                      context.read<AuthCubit>().logout();

                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const AuthPage()),
                          (Route<dynamic> route) => false);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
