import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/assets.dart';
import 'package:mobile/common/style/colors.dart';
import 'package:mobile/common/style/sizes.dart';
import 'package:mobile/extensions/task_extension.dart';
import 'package:mobile/src/base/ui/widgets/base/button_list.dart';
import 'package:mobile/src/base/ui/widgets/base/scroll_chip.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/asana.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/clickup.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/github.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/gmail.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/jira.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/notion.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/slack.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/todoist.dart';
import 'package:mobile/src/tasks/ui/widgets/edit_tasks/integrations/trello.dart';
import 'package:models/account/account.dart';
import 'package:models/doc/asana_doc.dart';
import 'package:models/doc/click_up_doc.dart';
import 'package:models/doc/github_doc.dart';
import 'package:models/doc/gmail_doc.dart';
import 'package:models/doc/jira_doc.dart';
import 'package:models/doc/notion_doc.dart';
import 'package:models/doc/slack_doc.dart';
import 'package:models/doc/todoist_doc.dart';
import 'package:models/doc/trello_doc.dart';
import 'package:models/task/task.dart';

class LinkedContentModal extends StatelessWidget {
  final Task task;
  final dynamic doc;
  final Account? account;

  const LinkedContentModal({
    Key? key,
    required this.task,
    required this.doc,
    required this.account,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        color: Theme.of(context).colorScheme.background,
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(Dimension.radiusM),
            topRight: Radius.circular(Dimension.paddingM),
          ),
          child: Wrap(
            children: [
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                children: [
                  const SizedBox(height: Dimension.padding),
                  const ScrollChip(),
                  const SizedBox(height: Dimension.padding),
                  Column(
                    children: [
                      SizedBox(
                        height: 58, //81391
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              task.computedIcon(),
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                doc.getLinkedContentSummary(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.w500, color: ColorsExt.grey800(context)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          if (doc is AsanaDoc) {
                            return AsanaLinkedContent(doc: doc as AsanaDoc, itemBuilder: _item, task: task);
                          } else if (doc is ClickupDoc) {
                            return ClickupLinkedContent(doc: doc as ClickupDoc, task: task, itemBuilder: _item);
                          } else if (doc is GithubDoc) {
                            return GithubLinkedContent(doc: doc as GithubDoc, task: task, itemBuilder: _item);
                          } else if (doc is GmailDoc) {
                            return GmailLinkedContent(doc: doc as GmailDoc, itemBuilder: _item, task: task);
                          } else if (doc is JiraDoc) {
                            return JiraLinkedContent(doc: doc as JiraDoc, task: task, itemBuilder: _item);
                          } else if (doc is NotionDoc) {
                            return NotionLinkedContent(doc: doc as NotionDoc, task: task, itemBuilder: _item);
                          } else if (doc is SlackDoc) {
                            return SlackLinkedContent(
                                doc: doc as SlackDoc, task: task, itemBuilder: _item, account: account);
                          } else if (doc is TodoistDoc) {
                            return TodoistLinkedContent(doc: doc as TodoistDoc, task: task, itemBuilder: _item);
                          } else if (doc is TrelloDoc) {
                            return TrelloLinkedContent(doc: doc as TrelloDoc, task: task, itemBuilder: _item);
                          }
                          return const SizedBox();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              Container(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimension.padding),
                child: OutlinedButton(
                    style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                        backgroundColor: MaterialStateProperty.all((Colors.transparent)),
                        minimumSize: MaterialStateProperty.all(const Size(double.infinity, Dimension.buttonHeight))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          Assets.images.icons.common.arrowUpRightSquareSVG,
                          color: ColorsExt.grey800(context),
                        ),
                        const SizedBox(width: Dimension.paddingS),
                        Text(
                          t.linkedContent.open,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: ColorsExt.grey800(context)),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    onPressed: () {
                      task.openLinkedContentUrl(doc);
                    }),
              ),
              Container(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _item(
    BuildContext context, {
    required String title,
    required String? value,
    bool syncing = false,
  }) {
    if (value == null || value.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 40,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title.isEmpty ? '-' : title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorsExt.grey600(context)),
            ),
            const SizedBox(width: Dimension.paddingS),
            Expanded(
              child: Text(value.isEmpty ? '-' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: ColorsExt.grey800(context))),
            ),
            syncing
                ? SvgPicture.asset(
                    Assets.images.icons.common.syncingSVG,
                    color: ColorsExt.grey800(context),
                    width: 18,
                    height: 18,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
