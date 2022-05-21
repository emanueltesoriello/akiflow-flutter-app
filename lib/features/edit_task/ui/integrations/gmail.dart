import 'package:flutter/material.dart';
import 'package:i18n/strings.g.dart';
import 'package:models/doc/doc.dart';

class GmailLinkedContent extends StatelessWidget {
  final Doc doc;
  final Function itemBuilder;

  const GmailLinkedContent({
    Key? key,
    required this.doc,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        itemBuilder(
          context,
          title: t.linkedContent.subject,
          value: doc.title ?? t.noTitle,
        ),
        itemBuilder(
          context,
          title: t.linkedContent.from,
          value: doc.content?["from"] ?? '',
        ),
        itemBuilder(
          context,
          title: t.linkedContent.date,
          value: doc.content?["internalDateFormatted"] ?? '',
        ),
      ],
    );
  }
}
