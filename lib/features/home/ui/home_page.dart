import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:mobile/components/app_bar.dart';
import 'package:mobile/components/button.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/auth/ui/auth_page.dart';
import 'package:mobile/i18n/strings.g.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/style/text_style.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(SFSymbols.line_horizontal_3),
            label: t.bottom_bar.menu,
          ),
          BottomNavigationBarItem(
              icon: const Icon(SFSymbols.tray), label: t.bottom_bar.inbox),
          BottomNavigationBarItem(
            icon: Image.asset(
              "assets/images/icons/_common/14.square@2x.png", // TODO SFSymbols.14 not available
              height: 19,
            ),
            label: t.bottom_bar.today,
          ),
          BottomNavigationBarItem(
            icon: const Icon(SFSymbols.calendar),
            label: t.bottom_bar.calendar,
          ),
        ],
        currentIndex: 1,
        unselectedItemColor: ColorsExt.textGrey(context),
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          print('Tapped $index');
        },
      ),
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
          BlocBuilder<AuthCubit, AuthCubitState>(
            builder: (context, state) {
              if (state.user == null) {
                return const Text("not logged");
              }

              return Text(state.user?.name ?? "n/d");
            },
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
