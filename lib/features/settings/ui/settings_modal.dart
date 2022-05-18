import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/button_selectable.dart';
import 'package:mobile/components/base/popup_menu_item.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/components/base/separator.dart';
import 'package:mobile/components/task/label_item.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/settings/cubit/settings_cubit.dart';
import 'package:mobile/features/settings/folder_item.dart';
import 'package:mobile/features/settings/ui/settings_page.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';

enum AddListType { addLabel, addFolder }

class SettingsModal extends StatelessWidget {
  const SettingsModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            padding: const EdgeInsets.only(top: 16),
            child: ListView(
              shrinkWrap: true,
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
                        color: ColorsExt.grey2(context),
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
                        context.read<MainCubit>().changeHomeView(HomeViewType.inbox);
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
                        List<Task> todayTasks = List.from(context.watch<TasksCubit>().state.todayTasks);
                        List<Task> todos = List.from(
                            todayTasks.where((element) => !element.isCompletedComputed && element.isTodayOrBefore));

                        return Text(
                          todos.length.toString(),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: ColorsExt.grey2_5(context),
                          ),
                        );
                      }),
                      onPressed: () {
                        context.read<MainCubit>().changeHomeView(HomeViewType.today);
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
                      title: t.task.someday,
                      leading: SvgPicture.asset(
                        "assets/images/icons/_common/tray.svg",
                        height: 19,
                        color: ColorsExt.grey3(context),
                      ),
                      selected: homeViewType == HomeViewType.someday,
                      trailing: Text(
                        t.comingSoon,
                        style: TextStyle(
                          fontSize: 17,
                          color: ColorsExt.grey3(context),
                        ),
                      ),
                      onPressed: () {
                        // TODO someday list
                      },
                    );
                  },
                ),
                const SizedBox(height: 2),
                BlocBuilder<MainCubit, MainCubitState>(
                  builder: (context, state) {
                    HomeViewType homeViewType = state.homeViewType;

                    return ButtonSelectable(
                      title: t.allTasks,
                      leading: SvgPicture.asset(
                        "assets/images/icons/_common/rectangle_grid_1x2.svg",
                        height: 19,
                        color: ColorsExt.grey3(context),
                      ),
                      selected: homeViewType == HomeViewType.someday,
                      trailing: Text(
                        t.comingSoon,
                        style: TextStyle(
                          fontSize: 17,
                          color: ColorsExt.grey3(context),
                        ),
                      ),
                      onPressed: () {
                        // TODO all tasks list
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                const Separator(),
                const SizedBox(height: 19.5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.settings.labels.toUpperCase(),
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                      ),
                    ),
                    PopupMenuButton<AddListType>(
                      icon: SvgPicture.asset(
                        "assets/images/icons/_common/plus.svg",
                        width: 22,
                        height: 22,
                        color: ColorsExt.grey3(context),
                      ),
                      onSelected: (AddListType result) {
                        switch (result) {
                          case AddListType.addLabel:
                            // TODO: Handle this case.
                            break;
                          case AddListType.addFolder:
                            // TODO: Handle this case.
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<AddListType>>[
                        PopupMenuItem<AddListType>(
                          value: AddListType.addLabel,
                          child: PopupMenuCustomItem(
                            iconAsset: "assets/images/icons/_common/number.svg",
                            text: t.label.addLabel,
                          ),
                        ),
                        PopupMenuItem<AddListType>(
                          value: AddListType.addFolder,
                          child: PopupMenuCustomItem(
                            iconAsset: "assets/images/icons/_common/folder.svg",
                            text: t.label.addFolder,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 7.5),
                BlocBuilder<SettingsCubit, SettingsCubitState>(
                  builder: (context, settingsState) {
                    return BlocBuilder<TasksCubit, TasksCubitState>(
                      builder: (context, tasksState) {
                        List<Label> allItems = tasksState.labels;

                        List<Label> folders = allItems.where((element) => element.type == "folder").toList();
                        List<Label> labelsWithoutFolder = allItems
                            .where((element) =>
                                element.type != "folder" && element.type != "section" && element.parentId == null)
                            .toList();

                        Map<Label?, List<Label>> folderLabels = {};

                        // Add to top all the labels which don't have parentId
                        folderLabels[null] = labelsWithoutFolder;

                        for (var folder in folders) {
                          List<Label> labels = allItems.where((Label label) => label.parentId == folder.id).toList();
                          folderLabels[folder] = labels;
                        }

                        return ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: folderLabels.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 4),
                          itemBuilder: (context, index) {
                            Label? folder = folderLabels.keys.elementAt(index);
                            List<Label> labels = folderLabels.values.elementAt(index);

                            if (folder == null) {
                              return ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: labels.length,
                                itemBuilder: (context, index) {
                                  Label label = labels[index];

                                  return LabelItem(
                                    label,
                                    onTap: () {
                                      context.read<MainCubit>().selectLabel(label);
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              );
                            } else {
                              List<Label>? labels = folderLabels[folder] ?? [];

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FolderItem(
                                          folder,
                                          onTap: () {
                                            context.read<SettingsCubit>().toggleFolder(folder);
                                          },
                                        ),
                                      ),
                                      Builder(builder: (context) {
                                        bool open = settingsState.folderOpen[folder] ?? false;

                                        return SvgPicture.asset(
                                          open
                                              ? "assets/images/icons/_common/chevron_up.svg"
                                              : "assets/images/icons/_common/chevron_down.svg",
                                          width: 16,
                                          height: 16,
                                          color: ColorsExt.grey3(context),
                                        );
                                      }),
                                    ],
                                  ),
                                  Builder(builder: (context) {
                                    bool open = settingsState.folderOpen[folder] ?? false;

                                    if (!open) {
                                      return const SizedBox();
                                    }

                                    return ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      itemCount: labels.length,
                                      itemBuilder: (context, index) {
                                        Label label = labels[index];

                                        return LabelItem(
                                          label,
                                          onTap: () {
                                            context.read<MainCubit>().selectLabel(label);
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  })
                                ],
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
