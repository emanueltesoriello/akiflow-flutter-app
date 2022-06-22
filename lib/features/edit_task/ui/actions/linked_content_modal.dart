import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/features/edit_task/ui/integrations/asana.dart';
import 'package:mobile/features/edit_task/ui/integrations/clickup.dart';
import 'package:mobile/features/edit_task/ui/integrations/gmail.dart';
import 'package:mobile/features/edit_task/ui/integrations/notion.dart';
import 'package:mobile/features/edit_task/ui/integrations/slack.dart';
import 'package:mobile/features/edit_task/ui/integrations/todoist.dart';
import 'package:mobile/features/edit_task/ui/integrations/trello.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/account/account.dart';
import 'package:models/doc/asana_doc.dart';
import 'package:models/doc/click_up_doc.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/gmail_doc.dart';
import 'package:models/doc/notion_doc.dart';
import 'package:models/doc/slack_doc.dart';
import 'package:models/doc/todoist_doc.dart';
import 'package:models/doc/trello_doc.dart';
import 'package:models/task/task.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkedContentModal extends StatelessWidget {
  final Task task;
  final Doc doc;
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
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        margin: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
          child: Container(
            color: Theme.of(context).backgroundColor,
            child: Wrap(
              children: [
                ListView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 12),
                    const ScrollChip(),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        SizedBox(
                          height: 58,
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
                                  doc.getLinkedContentSummary(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      fontSize: 17, fontWeight: FontWeight.w500, color: ColorsExt.grey2(context)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            if (doc is AsanaDoc) {
                              return AsanaLinkedContent(doc: doc, itemBuilder: _item, task: task);
                            } else if (doc is GmailDoc) {
                              return GmailLinkedContent(doc: doc, itemBuilder: _item);
                            } else if (doc is SlackDoc) {
                              return SlackLinkedContent(
                                task: task,
                                doc: doc,
                                itemBuilder: _item,
                                account: account,
                              );
                            } else if (doc is TodoistDoc) {
                              return TodoistLinkedContent(task: task, doc: doc, itemBuilder: _item);
                            } else if (doc is TrelloDoc) {
                              return TrelloLinkedContent(doc: doc, task: task, itemBuilder: _item);
                            } else if (doc is ClickupDoc) {
                              return ClickupLinkedContent(doc: doc, task: task, itemBuilder: _item);
                            } else if (doc is NotionDoc) {
                              return NotionLinkedContent(task: task, doc: doc, itemBuilder: _item);
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
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ButtonList(
                      leadingTextIconAsset: "assets/images/icons/_common/arrow_up_right_square.svg",
                      title: t.linkedContent.open,
                      onPressed: () {
                        launchUrl(Uri.parse(doc.url ?? ''), mode: LaunchMode.externalApplication);
                      }),
                ),
                Container(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SizedBox _item(
    BuildContext context, {
    required String title,
    required String value,
  }) {
    if (value.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 40,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 17, color: ColorsExt.grey3(context))),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 17, color: ColorsExt.grey2(context))),
            ),
          ],
        ),
      ),
    );
  }
}
