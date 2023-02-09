import 'package:models/account/account.dart';
import 'package:models/doc/doc.dart';
import 'package:models/doc/doc_base.dart';

class NotionDoc extends Doc implements DocBase {
  final String? title;
  NotionDoc(Doc doc, this.title)
      : super(
          url: doc.url,
          localUrl: doc.localUrl,
          workspaceId: doc.workspaceId,
          workspaceName: doc.workspaceName,
          createdAt: doc.createdAt,
          updatedAt: doc.updatedAt,
        );
  @override
  String getLinkedContentSummary([Account? account]) {
    return workspaceName ?? '';
  }

  @override
  String get getSummary {
    return workspaceName ?? super.getSummary;
  }
}
