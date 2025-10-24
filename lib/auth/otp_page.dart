import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'services/otp_service.dart';
import '../core/permission_manager.dart';
import '../core/app_config.dart';
import '../iris/dr_iris_welcome_page.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  final _codeCtrl = TextEditingController();
  bool _busy = false;
  String? _error;
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    final box = await Hive.openBox('app_prefs');
    setState(
      () => _phone = (box.get('pending_phone', defaultValue: '') as String),
    );
  }

  Future<void> _verify() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final code = _codeCtrl.text.trim();
      final ok = await OtpService.create().verifyCode(code);
      if (!ok) {
        final msg = PermissionManager.isSampleMode || AppConfig.useOfflineOtp
            ? 'Enter 000000 to continue.'
            : 'Invalid code. OTP via Firebase is disabled in this build.';
        setState(() => _error = msg);
        return;
      }
      final box = await Hive.openBox('app_prefs');
      await box.put('phone_verified', true);
      await box.delete('pending_phone');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DrIrisWelcomePage(autoStartCheckin: true),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hint = Theme.of(context).hintColor;
    return Scaffold(
      appBar: AppBar(title: const Text('Enter code')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_phone.isNotEmpty)
                Text('Code sent to: $_phone', style: TextStyle(color: hint)),
              const SizedBox(height: 12),
              TextField(
                controller: _codeCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Code',
                  hintText: '000000',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : _verify,
                  icon: _busy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.verified_outlined),
                  label: const Text('Verify and continue'),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'For privacy, no SMS is sent or auto‑read. Enter 000000 to continue.',
                style: TextStyle(color: hint),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
