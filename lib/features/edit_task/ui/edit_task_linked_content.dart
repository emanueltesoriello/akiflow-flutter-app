import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mobile/components/base/separator.dart';
import 'package:mobile/features/edit_task/cubit/edit_task_cubit.dart';
import 'package:mobile/features/edit_task/ui/linked_content_modal.dart';
import 'package:mobile/features/tasks/tasks_cubit.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/gmail_doc.dart';
import 'package:models/task/task.dart';

class EditTaskLinkedContent extends StatelessWidget {
  const EditTaskLinkedContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EditTaskCubit, EditTaskCubitState>(
      builder: (context, state) {
        List<Doc> docs = context.watch<TasksCubit>().state.docs;

        Task task = state.newTask;

        Doc? doc = docs.firstWhereOrNull(
          (doc) => doc.taskId == task.id,
        );

        if (doc?.content == null) {
          return const SizedBox();
        }

        GmailDoc gmailDoc = GmailDoc(doc!);

        return InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
              builder: (context) => LinkedContentModal(doc: GmailDoc(doc)),
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
                      gmailDoc.computedIcon,
                      width: 18,
                      height: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        gmailDoc.getSummary,
                        style: TextStyle(
                            fontSize: 17, color: ColorsExt.grey2(context)),
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
