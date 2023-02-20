import 'package:milton_relay/shared/models/issue_model.dart';

class IssueService {
  IssueModel getIssueFromJson(Map<String, dynamic> json) => IssueModel(
      issueFromString(json['issue'] as String),
      json['description'] as String,
      json['reporter'] as String,
      DateTime.fromMicrosecondsSinceEpoch(json['date'] as int),
      json['resolved'] as bool);

  Map<String, dynamic> issueToJson(IssueModel issue) => <String, dynamic>{
        'issue': issue.issue.toName,
        'description': issue.description,
        'reporter': issue.reporter,
        'date': issue.date.microsecondsSinceEpoch,
        'resolved': issue.resolved
      };
}
