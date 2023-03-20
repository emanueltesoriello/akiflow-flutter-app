import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class SlackDoc extends DocBase {
  final String? url;
  final String? localUrl;
  final String? type;
  final String? userImage;
  final String? userName;
  final int? starredAt;
  final String? channel;
  final String? channelName;
  final String? messageTimestamp;

  SlackDoc(
      {this.url,
      this.localUrl,
      this.type,
      this.userImage,
      this.userName,
      this.starredAt,
      this.channel,
      this.channelName,
      this.messageTimestamp});

  factory SlackDoc.fromMap(Map<String, dynamic> json) => SlackDoc(
        url: json['url'] as String?,
        localUrl: json['local_url'] as String?,
        type: json['type'] as String?,
        userImage: json['user_image'] as String?,
        userName: json['user_name'] as String?,
        starredAt: json['starred_at'] as int?,
        channel: json['channel'] as String?,
        channelName: json['channel_name'] as String?,
        messageTimestamp: json['message_timestamp'] as String?,
      );

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];

    try {
      String? workspace = getWorkspace(account);

      if (workspace != null) {
        summaryPieces.add(workspace);
      }
    } catch (_) {}

    try {
      if (channelName != null && channelName!.isNotEmpty) {
        summaryPieces.add(channelName);
      }
    } catch (_) {}

    try {
      if (userName != null && userName!.isNotEmpty) {
        summaryPieces.add(userName);
      }
    } catch (_) {}

    if (summaryPieces.isEmpty) {
      return url ?? '';
    } else {
      return "Slack: ${summaryPieces.join(' - ')}";
    }
  }

  String? getWorkspace(Account? account) {
    if (account != null) {
      return account.identifier;
    }
    return null;
  }

  @override
  String get getSummary {
    return userName ?? url ?? '';
  }

  @override
  List<Object?> get props {
    return [
      url,
      localUrl,
      type,
      userImage,
      userName,
      starredAt,
      channel,
      channelName,
      messageTimestamp,
    ];
  }
}
