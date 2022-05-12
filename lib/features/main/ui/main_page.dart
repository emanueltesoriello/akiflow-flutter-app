import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/container_inner_shadow.dart';
import 'package:mobile/components/task/bottom_task_actions.dart';
import 'package:mobile/features/add_task/ui/add_task_modal.dart';
import 'package:mobile/features/calendar/ui/calendar_view.dart';
import 'package:mobile/features/inbox/ui/inbox_view.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/views/inbox_appbar.dart';
import 'package:mobile/features/settings/ui/settings_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/ui/today_appbar.dart';
import 'package:mobile/features/today/ui/today_view.dart';
import 'package:mobile/style/colors.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MainPage extends StatelessWidget {
  final List<Widget> _views = [
    const SizedBox(),
    const InboxView(),
    const TodayView(),
    const CalendarView(),
  ];

  MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool isSelectMode = context.read<TasksCubit>().state.inboxTasks.any((t) => t.selected ?? false);

        if (isSelectMode) {
          context.read<TasksCubit>().clearSelected();
          return false;
        } else {
          return true;
        }
      },
      child: Stack(
        children: [
          Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => const AddTaskModal(),
              ),
              child: SvgPicture.asset(
                "assets/images/icons/_common/plus.svg",
                color: Theme.of(context).backgroundColor,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            bottomNavigationBar: BottomNavigationBar(
              elevation: 16,
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/icons/_common/line_horizontal_3.svg"),
                  label: t.bottomBar.menu,
                ),
                BottomNavigationBarItem(
                    icon: SvgPicture.asset("assets/images/icons/_common/tray.svg"),
                    activeIcon: SvgPicture.asset(
                      "assets/images/icons/_common/tray.svg",
                      color: Theme.of(context).primaryColor,
                    ),
                    label: t.bottomBar.inbox),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                    height: 19,
                    color: ColorsExt.grey1(context),
                  ),
                  activeIcon: SvgPicture.asset(
                    "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                    height: 19,
                    color: Theme.of(context).primaryColor,
                  ),
                  label: t.bottomBar.today,
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset("assets/images/icons/_common/calendar.svg"),
                  activeIcon: SvgPicture.asset(
                    "assets/images/icons/_common/calendar.svg",
                    color: Theme.of(context).primaryColor,
                  ),
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
                  showCupertinoModalBottomSheet(
                    context: context,
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
                        return InboxAppBar(
                          title: t.bottomBar.inbox,
                          leadingAsset: "assets/images/icons/_common/tray.svg",
                        );
                      case HomeViewType.today:
                        return const TodayAppBar();
                      case HomeViewType.calendar:
                        return const SizedBox();
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
          ),
          BlocBuilder<TasksCubit, TasksCubitState>(
            builder: (context, state) {
              if (state.inboxTasks.any((element) => element.selected ?? false)) {
                return const SafeArea(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: BottomTaskActions(),
                  ),
                );
              } else {
                return const SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
