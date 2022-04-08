import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/app_bar.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/style/colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarComp(
            title: t.settings.title,
            leading: Icon(
              SFSymbols.gear_alt,
              size: 26,
              color: ColorsExt.grey2(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  SFSymbols.ellipsis,
                  size: 18,
                  color: ColorsExt.grey2(context),
                ),
                onPressed: () {},
              ),
            ],
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  ButtonList(
                    title:
                        t.settings.upgrade_to_pro, // TODO  svg for crown icons
                    position: ButtonListPosition.top,
                    leading: SFSymbols.person,
                    leadingColor: Theme.of(context).primaryColor,
                    onPressed: () {},
                  ),
                  ButtonList(
                    title: t.settings.my_account,
                    position: ButtonListPosition.center,
                    leading: SFSymbols.person_circle,
                    onPressed: () {},
                  ),
                  ButtonList(
                    title: t.settings.logout,
                    position: ButtonListPosition.bottom,
                    onPressed: () {},
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
