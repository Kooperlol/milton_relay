import 'package:flutter/material.dart';

class IssueModel {
  final String id;
  final Issues issue;
  final String description, reporter;
  final DateTime date;
  final List<String> imageURLs;
  bool resolved;

  IssueModel(this.id, this.issue, this.description, this.reporter, this.date,
      this.resolved, this.imageURLs);
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

  IconData get toIcon {
    switch (this) {
      case Issues.design:
        return Icons.format_paint;
      case Issues.coding:
        return Icons.code;
      case Issues.suggestion:
        return Icons.lightbulb;
    }
  }
}

Issues issueFromString(String string) =>
    Issues.values.where((element) => element.toName == string).first;
