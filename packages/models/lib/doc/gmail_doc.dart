import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class GmailDoc extends Doc implements DocBase {
  final String? title;
  GmailDoc(Doc doc, this.title)
      : super(
          url: doc.url,
          from: doc.from,
          subject: doc.subject,
          internalDate: doc.internalDate,
          messageId: doc.messageId,
          threadId: doc.threadId,
          hash: doc.hash,
        );

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (from != null && from!.isNotEmpty) {
      final matches = RegExp(r'^(.*?)\s*<(.*?)>').allMatches(from!);

      String? name = matches.isEmpty ? from : matches.first.group(1);
      String? email = matches.isEmpty ? from : matches.first.group(2);

      if (name != null && name.isNotEmpty) {
        summaryPieces.add(name);
      } else if (email != null && email.isNotEmpty) {
        summaryPieces.add(email);
      }
    }
    if (title != null && title!.isNotEmpty) {
      summaryPieces.add(title);
    }

    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return from ?? super.getSummary;
  }
}
