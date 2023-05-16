import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:intl/intl.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/common/utils/no_scroll_behav.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/cubit/main/main_cubit.dart';
import 'package:mobile/src/base/ui/widgets/base/popup_menu_item.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/label/ui/cubit/labels_cubit.dart';
import 'package:mobile/src/label/ui/widgets/create_edit_label_modal.dart';
import 'package:mobile/src/label/ui/widgets/create_folder_modal.dart';
import 'package:mobile/src/base/ui/widgets/base/button_selectable.dart';
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

  _buildInbox(HomeViewType homeViewType, BuildContext context) {
    return ButtonSelectable(
      title: t.bottomBar.inbox,
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.traySVG,
          color: ColorsExt.grey800(context),
        ),
      ),
      selected: homeViewType == HomeViewType.inbox,
      trailing: Builder(builder: (context) {
        List<Task> tasks = List.from(context.watch<TasksCubit>().state.inboxTasks);

        return Text(tasks.length.toString(),
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey700(context),
                ));
      }),
      onPressed: () {
        context.read<MainCubit>().changeHomeView(HomeViewType.inbox);
        Navigator.pop(context);
      },
    );
  }

  _buildToday(HomeViewType homeViewType, BuildContext context) {
    return ButtonSelectable(
      title: t.bottomBar.today,
      leading: SizedBox(
        height: 22,
        width: 22,
        child: SvgPicture.asset(
          "assets/images/icons/_common/${DateFormat("dd").format(DateTime.now())}_square.svg",
          color: ColorsExt.grey900(context),
        ),
      ),
      selected: homeViewType == HomeViewType.today,
      trailing: Builder(builder: (context) {
        List<Task> fixedTodayTasks = List.from(context.watch<TasksCubit>().state.fixedTodayTasks);
        List<Task> fixedTodoTodayTasks =
            List.from(fixedTodayTasks.where((element) => !element.isCompletedComputed && element.isTodayOrBefore));

        return Text(fixedTodoTodayTasks.length.toString(),
            style: Theme.of(context).textTheme.bodyText1?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: ColorsExt.grey700(context),
                ));
      }),
      onPressed: () {
        context.read<MainCubit>().changeHomeView(HomeViewType.today);
        Navigator.pop(context);
      },
    );
  }

  _buildSomeday(HomeViewType homeViewType, BuildContext context) {
    return ButtonSelectable(
      title: t.task.someday,
      titleColor: ColorsExt.grey600(context),
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.archiveboxSVG,
          color: ColorsExt.grey600(context),
        ),
      ),
      selected: homeViewType == HomeViewType.someday,
      trailing: Text(t.comingSoon,
          style: Theme.of(context).textTheme.bodyText1?.copyWith(
                color: ColorsExt.grey600(context),
              )),
      onPressed: () {
        // TODO someday list
      },
    );
  }

  _buildAllTasks(HomeViewType homeViewType, BuildContext context) {
    return ButtonSelectable(
      title: t.allTasks,
      titleColor: ColorsExt.grey600(context),
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.rectangleGrid1X2SVG,
          height: 19,
          color: ColorsExt.grey600(context),
        ),
      ),
      selected: homeViewType == HomeViewType.someday,
      trailing: Text(
        t.comingSoon,
        style: Theme.of(context).textTheme.bodyText1?.copyWith(color: ColorsExt.grey600(context)),
      ),
      onPressed: () {
        // TODO all tasks list
      },
    );
  }

  _buildLabelsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: Dimension.paddingS),
      child: Row(
        children: [
          Expanded(
            child: Text(
              t.settings.labels.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .bodyText1
                  ?.copyWith(fontWeight: FontWeight.w600, color: ColorsExt.grey600(context)),
            ),
          ),
          Theme(
            data:
                Theme.of(context).copyWith(useMaterial3: false, popupMenuTheme: const PopupMenuThemeData(elevation: 4)),
            child: PopupMenuButton<AddListType>(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              icon: SvgPicture.asset(
                Assets.images.icons.common.plusSVG,
                width: Dimension.defaultIconSize,
                height: Dimension.defaultIconSize,
                color: ColorsExt.grey800(context),
              ),
              onSelected: (AddListType result) async {
                switch (result) {
                  case AddListType.addLabel:
                    LabelsCubit labelsCubit = context.read<LabelsCubit>();

                    Label newLabel = Label(id: const Uuid().v4(), color: "palette-red");

                    List<Label> folders =
                        labelsCubit.state.labels.where((label) => label.isFolder && label.deletedAt == null).toList();

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
                    iconAsset: Assets.images.icons.common.numberSVG,
                    text: t.label.addLabel,
                  ),
                ),
                PopupMenuItem<AddListType>(
                  value: AddListType.addFolder,
                  child: PopupMenuCustomItem(
                    iconAsset: Assets.images.icons.common.folderSVG,
                    text: t.label.addFolder,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  _buildAvailabilitySection(BuildContext context) {
    return ButtonSelectable(
      title: t.availability.shareAvailabilities,
      titleColor: ColorsExt.grey800(context),
      leading: SizedBox(
        height: Dimension.defaultIconSize,
        width: Dimension.defaultIconSize,
        child: SvgPicture.asset(
          Assets.images.icons.common.availabilitySVG,
          height: 19,
          color: ColorsExt.grey800(context),
        ),
      ),
      trailing: Container(),
      onPressed: () {
        context.read<MainCubit>().changeHomeView(HomeViewType.availability);
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(Dimension.padding),
        topRight: Radius.circular(Dimension.padding),
      ),
      child: ScrollConfiguration(
        behavior: NoScrollBehav(),
        child: Column(
          children: [
            const SizedBox(height: Dimension.padding),
            const ScrollChip(),
            const SizedBox(height: Dimension.padding),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
              child: Column(
                children: const [
                  Header(),
                  SizedBox(height: Dimension.padding),
                  Separator(),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(Dimension.padding),
                children: [
                  BlocBuilder<MainCubit, MainCubitState>(
                    builder: (context, state) {
                      HomeViewType homeViewType = state.homeViewType;
                      return _buildInbox(homeViewType, context);
                    },
                  ),
                  BlocBuilder<MainCubit, MainCubitState>(
                    builder: (context, state) {
                      HomeViewType homeViewType = state.homeViewType;
                      return _buildToday(homeViewType, context);
                    },
                  ),
                  BlocBuilder<MainCubit, MainCubitState>(
                    builder: (context, state) {
                      HomeViewType homeViewType = state.homeViewType;

                      return _buildSomeday(homeViewType, context);
                    },
                  ),
                  BlocBuilder<MainCubit, MainCubitState>(
                    builder: (context, state) {
                      HomeViewType homeViewType = state.homeViewType;
                      return _buildAllTasks(homeViewType, context);
                    },
                  ),
                  _buildAvailabilitySection(context),
                  const SizedBox(height: Dimension.paddingS),
                  const Separator(),
                  const SizedBox(height: Dimension.paddingS),
                  _buildLabelsSection(context),
                  const SizedBox(height: Dimension.paddingS),
                  LabelsList(
                    showHeaders: false,
                    showNoLabel: false,
                    onSelect: (Label selected) {
                      context.read<LabelsCubit>().selectLabel(selected);
                      context.read<MainCubit>().changeHomeView(HomeViewType.label);
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: Dimension.paddingM),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
