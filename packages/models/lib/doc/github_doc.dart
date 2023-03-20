import 'package:models/account/account.dart';
import 'package:models/doc/doc_base.dart';

class GithubDoc extends DocBase {
  late final String? title;
  final String? url;
  final String? repo;
  final String? repoId;
  final String? type;
  final String? submitter;
  final String? updatedAt;
  final String? hash;

  GithubDoc({
    this.url,
    this.repo,
    this.repoId,
    this.type,
    this.submitter,
    this.updatedAt,
    this.hash,
  });

  factory GithubDoc.fromMap(Map<String, dynamic> json) => GithubDoc(
        url: json['url'] as String?,
        repo: json['repo'] as String?,
        repoId: json['repo_id'] as String?,
        type: json['type'] as String?,
        submitter: json['submitter'] as String?,
        updatedAt: json['updated_at'] as String?,
        hash: json['hash'] as String?,
      );

  setTitle(String? title) {
    this.title = title;
  }

  @override
  String getLinkedContentSummary([Account? account]) {
    final summaryPieces = [];
    if (repo != null && repo!.isNotEmpty) {
      summaryPieces.add(repo);
    }
    if (submitter != null && submitter!.isNotEmpty) {
      summaryPieces.add(submitter);
    }

    return summaryPieces.join(' - ');
  }

  @override
  String get getSummary {
    return repo ?? url ?? '';
  }

  @override
  List<Object?> get props {
    return [
      title,
      url,
      repo,
      repoId,
      type,
      submitter,
      updatedAt,
      hash,
    ];
  }
}
