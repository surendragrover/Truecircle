import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../l10n/app_strings.dart';
import '../../services/app_language_service.dart';
import '../../theme/truecircle_theme.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  Future<void> _selectLanguage(BuildContext context, String code) async {
    await AppLanguageService.setLanguageCode(code);
    if (Hive.isBoxOpen('appBox')) {
      await Hive.box('appBox').put('language_selection_done', true);
    }
    if (!context.mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: TrueCircleTheme.appBackgroundGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Spacer(),
                Text(
                  AppStrings.t(context, 'choose_your_language'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  AppStrings.t(context, 'choose_language_desc'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => _selectLanguage(context, 'en'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                  ),
                  child: Text(AppStrings.t(context, 'english')),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => _selectLanguage(context, 'hi'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: const Color(0xFFFFF4D6),
                    foregroundColor: Colors.black87,
                  ),
                  child: Text(AppStrings.t(context, 'hindi')),
                ),
                const SizedBox(height: 14),
                Text(
                  AppStrings.t(context, 'change_later_settings'),
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
