enum LaudeRoles { summaCumLaude, magnaCumLaude, cumLaude, normal }

extension LaudeRoleExtension on LaudeRoles {
  String get toName {
    switch (this) {
      case LaudeRoles.summaCumLaude:
        return 'Summa Cum Laude';
      case LaudeRoles.magnaCumLaude:
        return 'Magna Cum Laude';
      case LaudeRoles.cumLaude:
        return 'Cum Laude';
      case LaudeRoles.normal:
        return 'No Laude Recognition';
    }
  }
}
