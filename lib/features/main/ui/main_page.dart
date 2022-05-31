import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/task/bottom_task_actions.dart';
import 'package:mobile/features/add_task/ui/add_task_modal.dart';
import 'package:mobile/features/calendar/ui/calendar_view.dart';
import 'package:mobile/features/edit_task/ui/recurring_edit_dialog.dart';
import 'package:mobile/features/inbox/ui/inbox_view.dart';
import 'package:mobile/features/label/cubit/create_edit/label_cubit.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/label_view.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/main/views/inbox_appbar.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/ui/settings_modal.dart';
import 'package:mobile/features/sync/sync_cubit.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/features/today/cubit/today_cubit.dart';
import 'package:mobile/features/today/ui/today_appbar.dart';
import 'package:mobile/features/today/ui/today_view.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with WidgetsBindingObserver {
  final List<Widget> _views = [
    const SizedBox(),
    const InboxView(),
    const TodayView(),
    const CalendarView(),
  ];

  StreamSubscription? streamSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    TasksCubit tasksCubit = context.read<TasksCubit>();

    tasksCubit.closeStream();

    if (streamSubscription != null) {
      streamSubscription!.cancel();
    }

    streamSubscription = tasksCubit.editRecurringTasksDialog.listen((allSelected) {
      showDialog(
          context: context,
          builder: (context) => RecurringEditDialog(
                onlyThisTap: () {
                  tasksCubit.update(allSelected);
                },
                allTap: () {
                  tasksCubit.update(allSelected, andFutureTasks: true);
                },
              ));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    bool isAuthenticatingOAuth = context.read<SettingsCubit>().state.isAuthenticatingOAuth;
    if (state == AppLifecycleState.resumed && isAuthenticatingOAuth == false) {
      context.read<SyncCubit>().sync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool isSelectMode = context.read<TasksCubit>().state.inboxTasks.any((t) => t.selected ?? false);

        if (isSelectMode) {
          context.read<TasksCubit>().clearSelected();
          return false;
        } else {
          if (ModalRoute.of(context)?.settings.name != "/") {
            return false;
          }

          return true;
        }
      },
      child: Stack(
        children: [
          Scaffold(
            floatingActionButton: _floatingButton(),
            bottomNavigationBar: _bottomBar(context),
            body: _content(),
          ),
          BlocBuilder<TasksCubit, TasksCubitState>(
            builder: (context, state) {
              bool anyInboxSelected = state.inboxTasks.any((t) => t.selected ?? false);
              bool anyTodaySelected = state.todayTasks.any((t) => t.selected ?? false);

              if (anyInboxSelected || anyTodaySelected) {
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

  Widget _content() {
    return Column(
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
          child: BlocBuilder<MainCubit, MainCubitState>(
            builder: (context, state) {
              switch (state.homeViewType) {
                case HomeViewType.inbox:
                  return _views[1];
                case HomeViewType.today:
                  return _views[2];
                case HomeViewType.calendar:
                  return _views[3];
                case HomeViewType.label:
                  Label label = state.selectedLabel!;

                  LabelsCubit labelsCubit = context.read<LabelsCubit>();

                  return BlocProvider(
                    key: UniqueKey(),
                    create: (context) => LabelCubit(label, labelsCubit: labelsCubit),
                    child: LabelView(key: ObjectKey(label)),
                  );
                default:
                  return const SizedBox();
              }
            },
          ),
        ),
      ],
    );
  }

  static const double bottomBarIconSize = 30;

  Widget _bottomBar(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        List<Task> inboxTasks = List.from(state.inboxTasks);
        List<Task> todayTasks = List.from(state.todayTasks);
        List<Task> todos =
            List.from(todayTasks.where((element) => !element.isCompletedComputed && element.isTodayOrBefore));

        return Theme(
          data: Theme.of(context).copyWith(useMaterial3: false),
          child: Material(
            elevation: 4,
            shadowColor: const Color.fromRGBO(0, 0, 0, 0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(height: 0.5, color: const Color(0xffE4EDF3)),
                BottomNavigationBar(
                  elevation: 16,
                  type: BottomNavigationBarType.fixed,
                  items: <BottomNavigationBarItem>[
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: bottomBarIconSize,
                          height: bottomBarIconSize,
                          child: SvgPicture.asset("assets/images/icons/_common/line_horizontal_3.svg",
                              color: ColorsExt.grey2(context))),
                      label: t.bottomBar.menu,
                    ),
                    BottomNavigationBarItem(
                        icon: Stack(
                          children: [
                            SizedBox(
                                width: bottomBarIconSize,
                                height: bottomBarIconSize,
                                child: SvgPicture.asset("assets/images/icons/_common/tray.svg",
                                    color: ColorsExt.grey2(context))),
                            _BottomIconBadge(inboxTasks.length.toString()),
                          ],
                        ),
                        activeIcon: Stack(
                          children: [
                            SizedBox(
                              width: bottomBarIconSize,
                              height: bottomBarIconSize,
                              child: SvgPicture.asset("assets/images/icons/_common/tray.svg",
                                  color: Theme.of(context).primaryColor),
                            ),
                            _BottomIconBadge(inboxTasks.length.toString()),
                          ],
                        ),
                        label: t.bottomBar.inbox),
                    BottomNavigationBarItem(
                      icon: Stack(
                        children: [
                          SizedBox(
                            width: bottomBarIconSize,
                            height: bottomBarIconSize,
                            child: SvgPicture.asset(
                              "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                              color: ColorsExt.grey2(context),
                            ),
                          ),
                          _BottomIconBadge(todos.length.toString()),
                        ],
                      ),
                      activeIcon: Stack(
                        children: [
                          SizedBox(
                            width: bottomBarIconSize,
                            height: bottomBarIconSize,
                            child: SvgPicture.asset(
                              "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          _BottomIconBadge(todos.length.toString()),
                        ],
                      ),
                      label: t.bottomBar.today,
                    ),
                    BottomNavigationBarItem(
                      icon: SizedBox(
                          width: bottomBarIconSize,
                          height: bottomBarIconSize,
                          child: SvgPicture.asset("assets/images/icons/_common/calendar.svg",
                              color: ColorsExt.grey2(context))),
                      activeIcon: SizedBox(
                        width: bottomBarIconSize,
                        height: bottomBarIconSize,
                        child: SvgPicture.asset(
                          "assets/images/icons/_common/calendar.svg",
                          color: Theme.of(context).primaryColor,
                        ),
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
                  selectedItemColor: () {
                    if (context.watch<MainCubit>().state.homeViewType == HomeViewType.label) {
                      return ColorsExt.grey1(context);
                    } else {
                      return Theme.of(context).primaryColor;
                    }
                  }(),
                  onTap: (index) {
                    if (index == 0) {
                      showCupertinoModalBottomSheet(
                        context: context,
                        builder: (context) => const SettingsModal(),
                        closeProgressThreshold: 0,
                      );
                    } else {
                      switch (index) {
                        case 1:
                          context.read<MainCubit>().changeHomeView(HomeViewType.inbox);
                          break;
                        case 2:
                          context.read<MainCubit>().changeHomeView(HomeViewType.today);
                          break;
                        case 3:
                          context.read<MainCubit>().changeHomeView(HomeViewType.calendar);
                          break;
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  BlocBuilder<TasksCubit, TasksCubitState> _floatingButton() {
    return BlocBuilder<TasksCubit, TasksCubitState>(
      builder: (context, state) {
        double bottomPadding;

        if (state.queue.isNotEmpty) {
          if (Platform.isIOS) {
            bottomPadding = MediaQuery.of(context).viewInsets.bottom + kBottomNavigationBarHeight + 8;
          } else {
            bottomPadding = MediaQuery.of(context).viewInsets.bottom + kBottomNavigationBarHeight;
          }
        } else {
          bottomPadding = 0;
        }

        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: FloatingActionButton(
            onPressed: () async {
              HomeViewType homeViewType = context.read<MainCubit>().state.homeViewType;
              TaskStatusType taskStatusType =
                  homeViewType == HomeViewType.inbox ? TaskStatusType.inbox : TaskStatusType.planned;
              DateTime date = context.read<TodayCubit>().state.selectedDate;

              Label? label = context.read<MainCubit>().state.selectedLabel;

              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => AddTaskModal(taskStatusType: taskStatusType, date: date, label: label),
              );
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SvgPicture.asset(
              "assets/images/icons/_common/plus.svg",
              color: ColorsExt.background(context),
            ),
          ),
        );
      },
    );
  }
}

class _BottomIconBadge extends StatelessWidget {
  final String info;

  const _BottomIconBadge(
    this.info, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(23, -5),
      child: Container(
        width: 17,
        height: 17,
        decoration: BoxDecoration(
          color: ColorsExt.akiflow(context),
          border: Border.all(color: ColorsExt.background(context), width: 1),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            info,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: ColorsExt.background(context),
            ),
          ),
        ),
      ),
    );
  }
}
