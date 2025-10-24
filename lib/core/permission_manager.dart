import 'package:flutter/material.dart';

/// Privacy-first sample mode manager.
/// In this app, sample mode is always true and no runtime permissions are requested.
class PermissionManager {
  static const bool isSampleMode = true;

  /// A small banner to remind users the app runs offline with no dangerous permissions.
  static Widget buildSampleModeBanner({
    EdgeInsets padding = const EdgeInsets.all(12),
  }) {
    return Builder(
      builder: (context) {
        final scheme = Theme.of(context).colorScheme;
        return Container(
          width: double.infinity,
          padding: padding,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.privacy_tip_outlined, color: scheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Privacy-first: Sample mode. No internet. No contacts/call/SMS permissions.',
                  style: TextStyle(fontSize: 12, color: scheme.onSurface),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
