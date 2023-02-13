import 'package:models/account/account.dart';
import 'package:models/base.dart';
import 'package:models/doc/doc_base.dart';

class GmailDoc extends Base implements DocBase {
  late final String? title;
  final String? connectorId;
  final String? originId;
  final String? url;
  final String? from;
  final String? subject;
  final String? internalDate;
  final String? messageId;
  final String? threadId;
  final String? hash;

  GmailDoc({
    this.connectorId,
    this.originId,
    this.url,
    this.from,
    this.subject,
    this.internalDate,
    this.messageId,
    this.threadId,
    this.hash,
  });

  factory GmailDoc.fromMap(Map<String, dynamic> json) => GmailDoc(
        connectorId: json['commector_id'] as String?,
        originId: json['origin_id'] as String?,
        url: json['url'] as String?,
        from: json['from'] as String?,
        subject: json['subject'] as String?,
        internalDate: json['internal_date'] as String?,
        messageId: json['message_id'] as String?,
        threadId: json['thread_id'] as String?,
        hash: json['hash'] as String?,
      );

  setTitle(String? title) {
    this.title = title;
  }

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (from != null && from!.isNotEmpty) {
      summaryPieces.add(from);
    }
    if (title != null && title!.isNotEmpty) {
      summaryPieces.add(title);
    }

    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return from ?? url ?? '';
  }

  @override
  List<Object?> get props {
    return [
      title,
      connectorId,
      originId,
      url,
      from,
      subject,
      internalDate,
      messageId,
      threadId,
      hash,
    ];
  }

  @override
  Map<String, dynamic> toMap() => {
        'url': url,
        'from': from,
        'subject': subject,
        'internal_date': internalDate,
        'message_id': messageId,
        'thread_id': threadId,
        'hash': hash,
        'connector_id': connectorId,
        'origin_id': originId,
      };

  @override
  Map<String, Object?> toSql() {
    return {};
  }

  @override
  bool? get stringify => throw UnimplementedError();
}
