import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intercom_flutter/intercom_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mobile/components/base/badged_icon.dart';
import 'package:mobile/components/base/icon_badge.dart';
import 'package:mobile/components/base/popup_menu_item.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/components/base/separator.dart';
import 'package:mobile/features/auth/cubit/auth_cubit.dart';
import 'package:mobile/features/edit_task/ui/labels_list.dart';
import 'package:mobile/features/label/cubit/labels_cubit.dart';
import 'package:mobile/features/label/ui/create_edit_label_modal.dart';
import 'package:mobile/features/label/ui/create_folder_modal.dart';
import 'package:mobile/features/main/cubit/main_cubit.dart';
import 'package:mobile/features/settings/ui/search_modal.dart';
import 'package:mobile/features/settings/ui/settings_page.dart';
import 'package:mobile/features/settings/ui/view/button_selectable.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/no_scroll_behav.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:uuid/uuid.dart';

enum AddListType { addLabel, addFolder }

class SettingsModal extends StatelessWidget {
  final double topPadding;

  const SettingsModal({Key? key, required this.topPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(color: Colors.transparent),
        constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - topPadding - 56),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            padding: const EdgeInsets.only(top: 16),
            child: ScrollConfiguration(
              behavior: NoScrollBehav(),
              child: Column(
                children: [
                  const ScrollChip(),
                  const SizedBox(height: 19),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: const [
                        _Header(),
                        SizedBox(height: 19),
                        Separator(),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      children: [
                        BlocBuilder<MainCubit, MainCubitState>(
                          builder: (context, state) {
                            HomeViewType homeViewType = state.homeViewType;

                            return ButtonSelectable(
                              title: t.bottomBar.inbox,
                              leading: SizedBox(
                                height: 22,
                                width: 22,
                                child: SvgPicture.asset(
                                  "assets/images/icons/_common/tray.svg",
                                  color: ColorsExt.grey2(context),
                                ),
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
                              leading: SizedBox(
                                height: 22,
                                width: 22,
                                child: SvgPicture.asset(
                                  "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
                                  color: ColorsExt.grey1(context),
                                ),
                              ),
                              selected: homeViewType == HomeViewType.today,
                              trailing: Builder(builder: (context) {
                                List<Task> fixedTodayTasks =
                                    List.from(context.watch<TasksCubit>().state.fixedTodayTasks);
                                List<Task> fixedTodoTodayTasks = List.from(fixedTodayTasks
                                    .where((element) => !element.isCompletedComputed && element.isTodayOrBefore));

                                return Text(
                                  fixedTodoTodayTasks.length.toString(),
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
                              leading: SizedBox(
                                height: 22,
                                width: 22,
                                child: SvgPicture.asset(
                                  "assets/images/icons/_common/archivebox.svg",
                                  color: ColorsExt.grey3(context),
                                ),
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
                              leading: SizedBox(
                                height: 22,
                                width: 22,
                                child: SvgPicture.asset(
                                  "assets/images/icons/_common/rectangle_grid_1x2.svg",
                                  height: 19,
                                  color: ColorsExt.grey3(context),
                                ),
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
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.settings.labels.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                                ),
                              ),
                              Theme(
                                data: Theme.of(context).copyWith(
                                    useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
                                child: PopupMenuButton<AddListType>(
                                  icon: SvgPicture.asset(
                                    "assets/images/icons/_common/plus.svg",
                                    width: 22,
                                    height: 22,
                                    color: ColorsExt.grey3(context),
                                  ),
                                  onSelected: (AddListType result) async {
                                    switch (result) {
                                      case AddListType.addLabel:
                                        LabelsCubit labelsCubit = context.read<LabelsCubit>();

                                        Label newLabel = Label(id: const Uuid().v4(), color: "palette-red");

                                        List<Label> folders = labelsCubit.state.labels
                                            .where((label) => label.type == "folder" && label.deletedAt == null)
                                            .toList();

                                        Label? newLabelUpdated = await showCupertinoModalBottomSheet(
                                          context: context,
                                          builder: (context) => CreateEditLabelModal(folders: folders, label: newLabel),
                                        );

                                        if (newLabelUpdated != null) {
                                          labelsCubit.addLabel(newLabelUpdated, labelType: LabelType.label);
                                        }
                                        break;
                                      case AddListType.addFolder:
                                        LabelsCubit labelsCubit = context.read<LabelsCubit>();

                                        Label newFolderInitial = Label(id: const Uuid().v4(), type: "folder");

                                        Label? newFolder = await showCupertinoModalBottomSheet(
                                          context: context,
                                          builder: (context) => CreateFolderModal(initialFolder: newFolderInitial),
                                        );

                                        if (newFolder != null) {
                                          labelsCubit.addLabel(newFolder, labelType: LabelType.folder);
                                        }
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
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 7.5),
                        LabelsList(
                          showHeaders: false,
                          showNoLabel: false,
                          onSelect: (Label selected) {
                            context.read<LabelsCubit>().selectLabel(selected);
                            context.read<MainCubit>().changeHomeView(HomeViewType.label);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.user?.email ?? "n/d",
                    style: TextStyle(
                      fontSize: 14,
                      color: ColorsExt.grey3(context),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => const SearchModal(),
            );
          },
        ),
        const SizedBox(width: 12),
        InkWell(
          child: BadgedIcon(
            icon: "assets/images/icons/_common/gear_alt.svg",
            badge: FutureBuilder<dynamic>(
                future: Intercom.instance.unreadConversationCount(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return IconBadge(
                      snapshot.data,
                      offset: const Offset(12, -9),
                    );
                  }
                  return const SizedBox();
                }),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
          },
        ),
      ],
    );
  }
}
