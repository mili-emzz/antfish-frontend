import 'package:flutter/material.dart';

import 'app.dart';
import 'features/auth/auth.dart';
import 'features/metrics/metrics.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    AntFishApp(
      authRepositoryBuilder: (session, onUnauthorized) => createAuthRepository(
        session: session,
        onUnauthorized: onUnauthorized,
      ),
      metricsRepositoryBuilder: (session, onUnauthorized) =>
          createMetricsRepository(
            session: session,
            onUnauthorized: onUnauthorized,
          ),
    ),
  );
}
