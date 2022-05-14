import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/components/base/separator.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/actions/linked_content_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:models/doc/asana_doc.dart';
import 'package:models/doc/click_up_doc.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/gmail_doc.dart';
import 'package:models/doc/notion_doc.dart';
import 'package:models/doc/slack_doc.dart';
import 'package:models/doc/todoist_doc.dart';
import 'package:models/doc/trello_doc.dart';
import 'package:models/task/task.dart';

class EditTaskLinkedContent extends StatelessWidget {
  const EditTaskLinkedContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        List<Doc> docs = context.watch<TasksCubit>().state.docs;

        Task task = state.updatedTask;

        Doc? doc = docs.firstWhereOrNull(
          (doc) => doc.taskId == task.id,
        );

        if (doc?.content == null) {
          return const SizedBox();
        }

        Doc docWithType;

        switch (doc!.connectorId) {
          case "asana":
            docWithType = AsanaDoc(doc);
            break;
          case "clickup":
            docWithType = ClickupDoc(doc);
            break;
          case "gmail":
            docWithType = GmailDoc(doc);
            break;
          case "notion":
            docWithType = NotionDoc(doc);
            break;
          case "slack":
            docWithType = SlackDoc(doc);
            break;
          case "todoist":
            docWithType = TodoistDoc(doc);
            break;
          case "trello":
            docWithType = TrelloDoc(doc);
            break;
          default:
            docWithType = doc;
            break;
        }

        return InkWell(
          onTap: () {
            showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => LinkedContentModal(
                task: task,
                doc: docWithType,
              ),
            );
          },
          child: Column(
            children: [
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      doc.computedIcon,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        docWithType.getLinkedContentSummary,
                        style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SvgPicture.asset(
                      "assets/images/icons/_common/info_circle.svg",
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
      },
    );
  }
}
