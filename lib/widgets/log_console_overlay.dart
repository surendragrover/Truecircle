// Log console overlay intentionally disabled for release builds and privacy.
// Keeping a small no-op stub so any imports remain valid but the UI is
// not exposed in production. If you need to restore for debugging, replace
// this file with a full implementation guarded by a compile-time flag.

import 'package:flutter/material.dart';

class LogConsoleOverlay extends StatelessWidget {
  const LogConsoleOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    // No-op placeholder
    return const SizedBox.shrink();
  }
}

// End of no-op log overlay stub.
