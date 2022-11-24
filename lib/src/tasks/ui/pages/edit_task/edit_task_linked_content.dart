import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/separator.dart';
import 'package:mobile/src/integrations/ui/cubit/integrations_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/edit_task_cubit.dart';
import 'package:mobile/src/tasks/ui/cubit/tasks_cubit.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/actions/linked_content_modal.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';

class EditTaskLinkedContent extends StatelessWidget {
  const EditTaskLinkedContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        Task task = state.updatedTask;
        Doc? doc = task.computedDoc(context.watch<TasksCubit>().state.docs.firstWhereOrNull(
              (doc) => doc.taskId == task.id,
            ));

        if (doc == null) {
          return const SizedBox();
        }

        return BlocBuilder<IntegrationsCubit, IntegrationsCubitState>(builder: (context, integrations) {
          Account? account =
              integrations.accounts.firstWhereOrNull((element) => element.connectorId == doc.connectorId);

          return InkWell(
            onTap: () {
              showCupertinoModalBottomSheet(
                context: context,
                builder: (context) => LinkedContentModal(task: task, doc: doc, account: account),
              );
            },
            child: Column(
              children: [
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            task.openLinkedContentUrl(doc);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                task.computedIcon(doc),
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  //doc.getLinkedContentSummary(account), DEPRECATED
                                  doc.getSummary ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SvgPicture.asset(
                        Assets.images.icons.common.syncingSVG,
                        color: ColorsExt.grey2(context),
                        width: 17,
                        height: 17,
                      ),
                      const SizedBox(width: 10),
                      SvgPicture.asset(
                        Assets.images.icons.common.infoCircleSVG,
                        color: ColorsExt.grey3(context),
                        width: 18,
                        height: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Separator(),
              ],
            ),
          );
        });
      },
    );
  }
}
