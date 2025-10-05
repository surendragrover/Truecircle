import 'package:flutter/material.dart';

/// Dialog explaining why permissions are needed for Full Mode.
class PermissionExplanationDialog extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final bool isHindi;
  const PermissionExplanationDialog(
      {super.key, required this.onOpenSettings, this.isHindi = false});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(isHindi ? 'अनुमतियाँ आवश्यक' : 'Permissions Required'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isHindi
                ? 'Full Mode सक्रिय करने से पहले कुछ सिस्टम अनुमतियाँ देनी होंगी:'
                : 'Before enabling Full Mode we need a few safe permissions:'),
            const SizedBox(height: 12),
            _buildPoint(isHindi,
                hi: 'भावनात्मक विश्लेषण बेहतर करने के लिए स्थानीय स्टोरेज',
                en: 'Local storage for enhanced emotional analysis'),
            _buildPoint(isHindi,
                hi: 'त्योहार / रिमाइंडर scheduling (डिवाइस से बाहर कुछ नहीं जाता)',
                en: 'Scheduling for festival / reminder logic (remains on-device)'),
            _buildPoint(isHindi,
                hi: 'बेहतर AI personalization (सारा प्रोसेस डिवाइस पर)',
                en: 'Improved AI personalization (all processing on-device)'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isHindi
                    ? 'आपका कोई भी निजी डेटा सर्वर पर नहीं भेजा जाता। सब कुछ फोन में सुरक्षित है।'
                    : 'No personal raw data leaves your device. Everything stays private locally.',
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(isHindi ? 'रद्द करें' : 'Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(context);
            onOpenSettings();
          },
          icon: const Icon(Icons.settings),
          label: Text(isHindi ? 'सेटिंग्स खोलें' : 'Open Settings'),
        ),
      ],
    );
  }

  Widget _buildPoint(bool isHindi, {required String hi, required String en}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield, size: 16, color: Colors.teal),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isHindi ? hi : en,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
