import 'package:flutter/material.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:mobile/components/app_bar.dart';
import 'package:mobile/components/button.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/i18n/strings.g.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/text_style.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBarComp(
            title: 'Inbox',
            leading: Icon(
              SFSymbols.tray,
              size: 26,
              color: ColorsExt.textGrey2_5(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  SFSymbols.ellipsis,
                  size: 18,
                  color: ColorsExt.textGrey3(context),
                ),
                onPressed: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ButtonComp(
                  child: Text(
                    t.login,
                    style: TextStyleExt.button(context),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AuthPage(),
                        ));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
