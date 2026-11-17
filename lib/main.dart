import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AntFishApp(
      authRepositoryBuilder: (session, onUnauthorized) => createAuthRepository(
        session: session,
        onUnauthorized: onUnauthorized,
      ),
    ),
  );
}
