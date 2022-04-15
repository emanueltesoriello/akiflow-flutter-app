import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sfsymbols/flutter_sfsymbols.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_selectable.dart';
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 6,
                    width: 36,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: ColorsExt.grey4(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 19),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
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
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500),
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
                          child: Icon(
                            SFSymbols.search,
                            color: ColorsExt.grey3(context),
                          ),
                          onTap: () {
                            // TODO search
                          },
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          child: Icon(
                            SFSymbols.gear_alt,
                            color: ColorsExt.grey3(context),
                          ),
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SettingsPage()));
                          },
                        ),
                      ],
                    ),
                    const Divider(height: 32),
                    BlocBuilder<MainCubit, MainCubitState>(
                      builder: (context, state) {
                        HomeViewType homeViewType = state.homeViewType;

                        return ButtonSelectable(
                          title: t.bottom_bar.inbox,
                          leading: Icon(
                            SFSymbols.tray,
                            size: 24,
                            color: ColorsExt.grey2(context),
                          ),
                          selected: homeViewType == HomeViewType.inbox,
                          trailing: Builder(builder: (context) {
                            List<Task> tasks = List.from(
                                context.watch<TasksCubit>().state.tasks);

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
                          title: t.bottom_bar.today,
                          leading: Image.asset(
                            "assets/images/icons/_common/14.square@2x.png", // TODO SFSymbols.14 not available
                            height: 19,
                            color: ColorsExt.grey1(context),
                          ),
                          selected: homeViewType == HomeViewType.today,
                          trailing: Builder(builder: (context) {
                            List<Task> tasks = List.from(
                                context.watch<TasksCubit>().state.tasks);

                            tasks = TaskExt.filterTodayTasks(tasks);

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
            ],
          ),
        ),
      ),
    );
  }
}
