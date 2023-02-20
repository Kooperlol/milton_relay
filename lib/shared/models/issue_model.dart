class IssueModel {
  final Issues issue;
  final String description, reporter;
  final DateTime date;
  bool resolved;

  IssueModel(
      this.issue, this.description, this.reporter, this.date, this.resolved);
}

enum Issues { design, coding, suggestion }

extension IssuesExstention on Issues {
  String get toName {
    switch (this) {
      case Issues.design:
        return "design";
      case Issues.coding:
        return "coding";
      case Issues.suggestion:
        return "suggestion";
    }
  }
}

Issues issueFromString(String string) =>
    Issues.values.where((element) => element.toName == string).first;
