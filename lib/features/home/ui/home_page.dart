import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/features/home/cubit/home_cubit.dart';
import 'package:mobile/features/home/views/_components/calendar_appbar.dart';
import 'package:mobile/features/home/views/_components/inbox_appbar.dart';
import 'package:mobile/features/home/views/_components/today_appbar.dart';
import 'package:mobile/features/home/views/inbox/ui/view.dart';
import 'package:mobile/features/settings/ui/settings_modal.dart';
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
              color: ColorsExt.grey1(context),
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
        currentIndex: () {
          switch (context.watch<HomeCubit>().state.homeViewType) {
            case HomeViewType.inbox:
              return 1;
            case HomeViewType.today:
              return 2;
            case HomeViewType.calendar:
              return 3;
            default:
              return 0;
          }
        }(),
        unselectedItemColor: ColorsExt.grey1(context),
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: (index) {
          if (index == 0) {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => const SettingsModal(),
            );
          } else {
            context.read<HomeCubit>().bottomBarViewClick(index);
          }
        },
      ),
      body: Column(
        children: [
          BlocBuilder<HomeCubit, HomeCubitState>(
            builder: (context, state) {
              switch (state.homeViewType) {
                case HomeViewType.inbox:
                  return const InboxAppBar();
                case HomeViewType.today:
                  return const TodayAppBar();
                case HomeViewType.calendar:
                  return const CalendarAppBar();
                default:
                  return const SizedBox();
              }
            },
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: BlocBuilder<HomeCubit, HomeCubitState>(
                builder: (context, state) {
                  switch (state.homeViewType) {
                    case HomeViewType.inbox:
                      return _views[1];
                    case HomeViewType.today:
                      return _views[2];
                    case HomeViewType.calendar:
                      return _views[3];
                    default:
                      return const SizedBox();
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
