import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/app_bar.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/home/cubit/home_cubit.dart';
import 'package:mobile/features/home/views/inbox/ui/view.dart';
import 'package:mobile/features/home/views/settings/ui/view.dart';
import 'package:mobile/style/colors.dart';

class HomePage extends StatelessWidget {
  final List<Widget> _views = [
    const SizedBox(),
    const InboxView(),
    const SizedBox(),
    const SizedBox(),
  ];

  HomePage({Key? key}) : super(key: key);

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
              color: ColorsExt.textGrey(context),
            ),
            activeIcon: Image.asset(
              "assets/images/icons/_common/14.square@2x.png", // TODO SFSymbols.14 not available
              height: 19,
              color: Theme.of(context).primaryColor,
            ),
            label: t.bottom_bar.today,
          ),
          BottomNavigationBarItem(
            icon: const Icon(SFSymbols.calendar),
            label: t.bottom_bar.calendar,
          ),
        ],
        currentIndex: context.watch<HomeCubit>().state.currentViewIndex,
        unselectedItemColor: ColorsExt.textGrey(context),
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          if (index == 0) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => const SettingsView(),
            );
          } else {
            context.read<HomeCubit>().bottomBarViewClick(index);
          }
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
          Expanded(
            child: BlocBuilder<HomeCubit, HomeCubitState>(
              builder: (context, state) {
                return _views[state.currentViewIndex];
              },
            ),
          ),
        ],
      ),
    );
  }
}
