class GmailMessageMetadata {
  final String id;
  final String threadId;

  GmailMessageMetadata(this.id, this.threadId);
}

class GmailMessagesAndThreads {
  final List<String> messagesId;
  final List<String> threadsId;

  GmailMessagesAndThreads(this.messagesId, this.threadsId);
}

class GmailMessage {
  final String? id;
  final String? threadId;
  final String? internalDate;
  final String? subject;
  final String? from;
  final String? messageId;

  GmailMessage({
    this.id,
    this.threadId,
    this.internalDate,
    this.subject,
    this.from,
    this.messageId,
  });

  factory GmailMessage.fromMap(Map<String, dynamic> json) {
    return GmailMessage(
      id: json['id'] as String?,
      threadId: json['threadId'] as String?,
      internalDate: json['internalDate'] as String?,
      subject: json['subject'] as String?,
      from: json['from'] as String?,
      messageId: json['messageId'] as String?,
    );
  }
}

enum GmailSyncMode {
  useAkiflowLabel(1),
  useStarToImport(0),
  doNothing(-1),
  askMeEveryTime(null);

  final int? key;
  const GmailSyncMode(this.key);

  factory GmailSyncMode.fromKey(int? key) {
    switch (key) {
      case 1:
        return useAkiflowLabel;
      case 0:
        return useStarToImport;
      case -1:
        return doNothing;
      default:
        return askMeEveryTime;
    }
  }
}
