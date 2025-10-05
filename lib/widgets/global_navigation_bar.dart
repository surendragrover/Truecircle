import 'package:flutter/material.dart';
import '../pages/how_truecircle_works_page.dart';

class GlobalNavigationBar extends StatelessWidget {
  final bool isHindi;
  final VoidCallback? onBack;
  final VoidCallback? onNext;
  const GlobalNavigationBar({
    super.key,
    this.isHindi = false,
    this.onBack,
    this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: onBack ??
                () {
                  Navigator.maybePop(context);
                },
            child: Text(isHindi ? 'पीछे' : 'Back'),
          ),
          TextButton(
            onPressed: onNext ??
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HowTrueCircleWorksPage(),
                    ),
                  );
                },
            child: Text(isHindi ? 'आगे' : 'Next'),
          ),
        ],
      ),
    );
  }
}
