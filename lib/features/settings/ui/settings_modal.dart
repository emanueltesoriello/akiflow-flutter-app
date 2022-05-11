import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/button_selectable.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/settings/ui/settings_page.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/task/task.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            padding: const EdgeInsets.only(top: 16),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const ScrollChip(),
                const SizedBox(height: 19),
                Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/logo/logo_outline.svg",
                      width: 48,
                      height: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: BlocBuilder<AuthCubit, AuthCubitState>(
                        builder: (context, state) {
                          if (state.user == null) {
                            return const SizedBox();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.user?.name ?? "n/d",
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                state.user?.email ?? "n/d",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: ColorsExt.grey3(context),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      child: SvgPicture.asset(
                        "assets/images/icons/_common/search.svg",
                        color: ColorsExt.grey3(context),
                      ),
                      onTap: () {
                        // TODO SETTINGS - search
                      },
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      child: SvgPicture.asset(
                        "assets/images/icons/_common/gear_alt.svg",
                        color: ColorsExt.grey3(context),
                      ),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                      },
                    ),
                  ],
                ),
                const Divider(height: 32),
                BlocBuilder<MainCubit, MainCubitState>(
                  builder: (context, state) {
                    HomeViewType homeViewType = state.homeViewType;

                    return ButtonSelectable(
                      title: t.bottomBar.inbox,
                      leading: SvgPicture.asset(
                        "assets/images/icons/_common/tray.svg",
                        width: 24,
                        height: 24,
                        color: ColorsExt.grey2(context),
                      ),
                      selected: homeViewType == HomeViewType.inbox,
                      trailing: Builder(builder: (context) {
                        List<Task> tasks = List.from(context.watch<TasksCubit>().state.inboxTasks);

                        tasks = TaskExt.filterInboxTasks(tasks);

                        return Text(
                          tasks.length.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2_5(context),
                          ),
                        );
                      }),
                      onPressed: () {
                        context.read<MainCubit>().changeHomeView(1);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
                const SizedBox(height: 2),
                BlocBuilder<MainCubit, MainCubitState>(
                  builder: (context, state) {
                    HomeViewType homeViewType = state.homeViewType;

                    return ButtonSelectable(
                      title: t.bottomBar.today,
                      leading: SvgPicture.asset(
                        "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                        height: 19,
                        color: ColorsExt.grey1(context),
                      ),
                      selected: homeViewType == HomeViewType.today,
                      trailing: Builder(builder: (context) {
                        List<Task> tasks = List.from(context.watch<TasksCubit>().state.inboxTasks);

                        tasks = TaskExt.filterTodayTodoTasks(tasks);

                        return Text(
                          tasks.length.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2_5(context),
                          ),
                        );
                      }),
                      onPressed: () {
                        context.read<MainCubit>().changeHomeView(2);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
