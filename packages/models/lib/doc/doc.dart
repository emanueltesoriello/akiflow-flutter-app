import 'package:models/account/account.dart';
import 'package:models/base.dart';
import 'package:models/doc/doc_base.dart';

class Doc extends DocBase implements Base {
  Doc({
    this.url,
    this.from,
    this.subject,
    this.internalDate,
    this.messageId,
    this.threadId,
    this.hash,
    this.accountId,
    this.workspaceId,
    this.workspaceName,
    this.projectId,
    this.projectName,
    this.sectionId,
    this.sectionName,
    this.assigneeId,
    this.assigneeName,
    this.taskId,
    this.parentTaskId,
    this.parentTaskName,
    this.teamId,
    this.teamName,
    this.spaceId,
    this.spaceName,
    this.folderId,
    this.folderName,
    this.listId,
    this.listName,
    this.issueTypeName,
    this.type,
    this.userImage,
    this.userName,
    this.starredAt,
    this.channel,
    this.channelName,
    this.messageTimestamp,
    this.dueDate,
    this.dueDateTime,
    this.isRecurring,
    this.string,
    this.timezone,
    this.lang,
    this.parentId,
    this.parentTaskTitle,
    this.id,
    this.desc,
    this.dateLastActivity,
    this.dueComplete,
    this.due,
    this.boardId,
    this.boardName,
    this.connectorId,
    this.originId,
    this.localUrl,
    this.createdAt,
    this.updatedAt,
  });

  final String? url;
  final String? from;
  final String? subject;
  final String? internalDate;
  final String? messageId;
  final String? threadId;
  final String? hash;

  final String? accountId;
  final String? workspaceId;
  final String? workspaceName;
  final String? projectId;
  final String? projectName;
  final String? sectionId;
  final String? sectionName;
  final String? assigneeId;
  final String? assigneeName;
  final String? localUrl;
  final String? createdAt;
  final String? updatedAt;

  final String? taskId;
  final String? parentTaskId;
  final String? teamId;
  final String? teamName;
  final String? spaceId;
  final String? spaceName;
  final String? folderId;
  final String? listId;
  final String? listName;
  final String? folderName;
  final String? parentTaskName;

  final String? connectorId;
  final String? originId;

  final String? issueTypeName;

  final String? type;
  final String? userImage;
  final String? userName;
  final int? starredAt;
  final String? channel;
  final String? channelName;
  final String? messageTimestamp;

  final String? dueDate;
  final String? dueDateTime;
  final bool? isRecurring;
  final String? string;
  final String? timezone;
  final String? lang;
  final String? parentId;
  final String? parentTaskTitle;

  final String? id;
  final String? desc;
  final String? dateLastActivity;
  final String? dueComplete;
  final String? boardId;
  final String? boardName;
  final String? due;

  factory Doc.fromMap(Map<String, dynamic> json) => Doc(
        url: json['url'] as String?,
        from: json['from'] as String?,
        subject: json['subject'] as String?,
        internalDate: json['internal_date'] as String?,
        messageId: json['message_id'] as String?,
        threadId: json['thread_id'] as String?,
        hash: json['hash'] as String?,
        accountId: json['account_id'] as String?,
        workspaceId: json['workspaceID'] as String?,
        workspaceName: json['workspace_name'] as String?,
        projectId: json['project_id'] as String?,
        projectName: json['project_name'] as String?,
        sectionId: json['section_id'] as String?,
        sectionName: json['section_name'] as String?,
        assigneeId: json['assignee_id'] as String?,
        assigneeName: json['assignee_name'] as String?,
        localUrl: json['local_url'] as String?,
        createdAt: json['created_at'] as String?,
        updatedAt: json['updated_at'] as String?,
        taskId: json['task_id'] as String?,
        parentTaskId: json['parent_task_id'] as String?,
        parentTaskName: json['url'] as String?,
        teamId: json['team_id'] as String?,
        teamName: json['team_name'] as String?,
        spaceId: json['space_id'] as String?,
        spaceName: json['space_name'] as String?,
        folderId: json['folder_id'] as String?,
        folderName: json['folder_name'] as String?,
        listId: json['list_id'] as String?,
        listName: json['list_name'] as String?,
        issueTypeName: json['issue_type_name'] as String?,
        type: json['type'] as String?,
        userImage: json['user_image'] as String?,
        userName: json['user_name'] as String?,
        starredAt: json['starred_at'] as int?,
        channel: json['channel'] as String?,
        channelName: json['channel_name'] as String?,
        messageTimestamp: json['message_timestamp'] as String?,
        dueDate: json['due_date'] as String?,
        dueDateTime: json['due_date_time'] as String?,
        isRecurring: json['is_recurring'] as bool?,
        string: json['string'] as String?,
        timezone: json['timezone'] as String?,
        lang: json['lang'] as String?,
        parentTaskTitle: json['parent_task_title'] as String?,
        desc: json['desc'] as String?,
        dateLastActivity: json['date_last_activity'] as String?,
        dueComplete: json['due_complete'] as String?,
        due: json['due'] as String?,
        boardId: json['board_id'] as String?,
        boardName: json['board_name'] as String?,
        id: json['id'] as String?,
      );

  @override
  Map<String, dynamic> toMap() => {
        'url': url,
        'from': from,
        'subject': subject,
        'internal_date': internalDate,
        'message_id': messageId,
        'thread_id': threadId,
        'hash': hash,
        'account_id': accountId,
        'workspace_id': workspaceId,
        'workspace_name': workspaceName,
        'project_id': projectId,
        'project_name': projectName,
        'section_id': sectionId,
        'section_name': sectionName,
        'assignee_id': assigneeId,
        'assignee_name': assigneeName,
        'task_id': taskId,
        'parent_task_id': parentTaskId,
        'parent_task_name': parentTaskName,
        'team_id': teamId,
        'team_name': teamName,
        'space_id': spaceId,
        'space_name': spaceName,
        'folder_id': folderId,
        'folder_name': folderName,
        'list_id': listId,
        'list_name': listName,
        'issue_type_name': issueTypeName,
        'type': type,
        'user_image': userImage,
        'user_name': userName,
        'starred_at': starredAt,
        'channel': channel,
        'channel_name': channelName,
        'message_timestamp': messageTimestamp,
        'due_date': dueDate,
        'due_date_time': dueDateTime,
        'is_recurring': isRecurring,
        'string': string,
        'timezone': timezone,
        'lang': lang,
        'parent_id': parentId,
        'parent_task_title': parentTaskTitle,
        'id': id,
        'desc': desc,
        'date_last_activity': dateLastActivity,
        'due_complete': dueComplete,
        'due': due,
        'board_id': boardId,
        'board_name': boardName,
        'connector_id': connectorId,
        'origin_id': originId,
        'local_url': localUrl,
        'created_at': createdAt,
        'updated_at': createdAt,
      }..removeWhere((key, value) => value == null);

  @override
  Map<String, Object?> toSql() {
    return {};
  }

  static Doc fromSql(Map<String, dynamic> json) {
    Map<String, dynamic>? copy = Map<String, dynamic>.from(json);
    return Doc.fromMap(copy);
  }

  @override
  List<Object?> get props {
    return [
      url,
      from,
      subject,
      internalDate,
      messageId,
      threadId,
      hash,
      accountId,
      workspaceId,
      workspaceName,
      projectId,
      projectName,
      sectionId,
      sectionName,
      assigneeId,
      assigneeName,
      taskId,
      parentTaskId,
      parentTaskName,
      teamId,
      teamName,
      spaceId,
      spaceName,
      folderId,
      folderName,
      listId,
      listName,
      issueTypeName,
      type,
      userImage,
      userName,
      starredAt,
      channel,
      channelName,
      messageTimestamp,
      dueDate,
      isRecurring,
      string,
      timezone,
      lang,
      parentId,
      parentTaskTitle,
      id,
      desc,
      dateLastActivity,
      dueComplete,
      due,
      boardId,
      boardName,
      connectorId,
      originId,
      localUrl,
      createdAt,
      createdAt,
    ];
  }

  @override
  String get getSummary {
    return url ?? '';
  }

  @override
  String get getFinalURL {
    // TODO asana url (AsanaDocModel.ts)
    //  if (content?["localUrl"] && await AsanaConnector.getInstance().isProtocolHandled()) {
    //   return this.localUrl
    // }
    return url ?? '';
  }

  @override
  String getLinkedContentSummary([Account? account]) {
    return url ?? '';
  }
}
