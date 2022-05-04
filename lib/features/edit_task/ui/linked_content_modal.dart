import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:i18n/strings.g.dart';
import 'package:mobile/components/base/button_list.dart';
import 'package:mobile/components/base/scroll_chip.dart';
import 'package:mobile/style/colors.dart';
import 'package:mobile/utils/doc_extension.dart';
import 'package:mobile/utils/task_extension.dart';
import 'package:models/doc/doc.dart';
import 'package:models/task/task.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkedContentModal extends StatelessWidget {
  final Task task;
  final Doc doc;

  const LinkedContentModal({
    Key? key,
    required this.task,
    required this.doc,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      height: MediaQuery.of(context).size.height * 0.5,
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: Container(
          color: Theme.of(context).backgroundColor,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 12),
                    const ScrollChip(),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 58,
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
                              doc.content?.from ?? 'no user',
                              style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: ColorsExt.grey2(context)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        _item(
                          context,
                          title: t.linkedContent.subject,
                          value: task.title ?? t.task.noTitle,
                        ),
                        _item(
                          context,
                          title: t.linkedContent.from,
                          value: doc.content?.from ?? t.task.noTitle,
                        ),
                        _item(
                          context,
                          title: t.linkedContent.date,
                          value: task.createdAtFormatted,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ButtonList(
                    leadingTextIconAsset:
                        "assets/images/icons/_common/arrow_up_right_square.svg",
                    title: t.linkedContent.open,
                    onPressed: () {
                      launch(doc.url ?? '');
                    }),
              ),
              const SizedBox(height: 50),
            ],
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
    return SizedBox(
      height: 40,
      child: Center(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style:
                    TextStyle(fontSize: 17, color: ColorsExt.grey3(context))),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      TextStyle(fontSize: 17, color: ColorsExt.grey2(context))),
            ),
          ],
        ),
      ),
    );
  }
}
