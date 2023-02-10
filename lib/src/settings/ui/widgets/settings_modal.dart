import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/label/ui/widgets/create_edit_label_modal.dart';
import 'package:mobile/src/label/ui/widgets/create_folder_modal.dart';
import 'package:mobile/src/settings/ui/widgets/button_selectable.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/pages/edit_task/labels_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/label/label.dart';
import 'package:models/task/task.dart';
import 'package:uuid/uuid.dart';

import 'header.dart';

enum AddListType { addLabel, addFolder }

class SettingsModal extends StatelessWidget {
  final double topPadding;

  const SettingsModal({Key? key, required this.topPadding}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16.0),
        topRight: Radius.circular(16.0),
      ),
      child: ScrollConfiguration(
        behavior: NoScrollBehav(),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const ScrollChip(),
            const SizedBox(height: 19),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: const [
                  Header(),
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
                          List<Task> fixedTodayTasks = List.from(context.watch<TasksCubit>().state.fixedTodayTasks);
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
                            style:
                                TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ColorsExt.grey3(context)),
                          ),
                        ),
                        Theme(
                          data: Theme.of(context)
                              .copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
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
                                      .where((label) => label.isFolder && label.deletedAt == null)
                                      .toList();

                                  Label? newLabelUpdated = await showCupertinoModalBottomSheet(
                                    context: context,
                                    builder: (context) => CreateEditLabelModal(folders: folders, label: newLabel),
                                  );

                                  if (newLabelUpdated != null) {
                                    labelsCubit.addLabel(newLabelUpdated, labelType: LabelType.label);

                                    context.read<LabelsCubit>().selectLabel(newLabelUpdated);
                                    context.read<MainCubit>().changeHomeView(HomeViewType.label);
                                    Navigator.pop(context);
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
    );
  }
}