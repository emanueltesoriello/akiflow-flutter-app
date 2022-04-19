import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/features/add_task/ui/add_task_modal.dart';
import 'package:mobile/features/inbox/ui/inbox_view.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/views/calendar_appbar.dart';
import 'package:mobile/features/main/views/inbox_appbar.dart';
import 'package:mobile/features/main/views/today_appbar.dart';
import 'package:mobile/features/settings/ui/settings_modal.dart';
import 'package:mobile/features/today/ui/today_view.dart';
import 'package:mobile/style/colors.dart';

class MainPage extends StatelessWidget {
  final List<Widget> _views = [
    const SizedBox(),
    const InboxView(),
    const TodayView(),
    const SizedBox(),
  ];

  MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) => AddTaskModal(),
        ),
        child: const Icon(SFSymbols.plus),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(SFSymbols.line_horizontal_3),
            label: t.bottomBar.menu,
          ),
          BottomNavigationBarItem(
              icon: const Icon(SFSymbols.tray), label: t.bottomBar.inbox),
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
            label: t.bottomBar.today,
          ),
          BottomNavigationBarItem(
            icon: const Icon(SFSymbols.calendar),
            label: t.bottomBar.calendar,
          ),
        ],
        currentIndex: () {
          switch (context.watch<MainCubit>().state.homeViewType) {
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
            context.read<MainCubit>().changeHomeView(index);
          }
        },
      ),
      body: Column(
        children: [
          BlocBuilder<MainCubit, MainCubitState>(
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
            child: ContainerInnerShadow(
              child: BlocBuilder<MainCubit, MainCubitState>(
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
