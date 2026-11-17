import 'package:flutter/widgets.dart';

import 'session_controller.dart';

/// Expone el [SessionController] en el árbol de widgets desde `core/session/`
/// para que cualquier feature (`account`, `analysis`, `metrics`, `auth`) pueda
/// leer o cerrar la sesión sin violar las reglas de importación entre features.
class SessionScope extends InheritedNotifier<SessionController> {
  const SessionScope({
    super.key,
    required SessionController controller,
    required super.child,
  }) : super(notifier: controller);

  static SessionController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<SessionScope>()?.notifier;
}
