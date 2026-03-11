import 'package:flutter_dotenv/flutter_dotenv.dart';

class AccessControlServices {
  static List<String> get availableRoles =>
      dotenv.env['APP_ROLES']?.split(',') ??
      ['project_manager', 'frontend', 'backend'];

  static const String actionCreate = 'create';
  static const String actionRead = 'read';
  static const String actionUpdate = 'update';
  static const String actionDelete = 'delete';

  static final Map<String, List<String>> _rolePermissions = {
    'project_manager': [actionCreate, actionRead, actionUpdate, actionDelete],
    'frontend': [actionCreate, actionRead, actionUpdate, actionDelete],
    'backend': [actionCreate, actionRead, actionUpdate, actionDelete],
  };

  static bool canPerform(String role, String action, {bool isOwner = false}) {
    final permissions = _rolePermissions[role] ?? [];

    final hasPermission = permissions.contains(action);

    if (!hasPermission) return false;

    if (role == 'project_manager') return true;

    if ((role == 'frontend' || role == 'backend') &&
        (action == actionUpdate || action == actionDelete)) {
      return isOwner;
    }

    return true;
  }
}
