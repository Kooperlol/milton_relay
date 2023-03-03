import 'package:milton_relay/shared/models/issue_model.dart';

class IssueService {
  IssueModel getIssueFromJson(String id, Map<String, dynamic> json) =>
      IssueModel(
          id,
          issueFromString(json['issue'] as String),
          json['description'] as String,
          json['reporter'] as String,
          DateTime.fromMicrosecondsSinceEpoch(json['date'] as int),
          json['resolved'] as bool,
          (json['image-urls'] as List<dynamic>)
              .map((e) => e.toString())
              .toList());

  Map<String, dynamic> issueToJson(IssueModel issue) => <String, dynamic>{
        'issue': issue.issue.toName,
        'description': issue.description,
        'reporter': issue.reporter,
        'date': issue.date.microsecondsSinceEpoch,
        'resolved': issue.resolved,
        'image-urls': issue.imageURLs
      };
}
