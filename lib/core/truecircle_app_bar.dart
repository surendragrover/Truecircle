import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/marketplace_discount_widget.dart';
import '../widgets/coin_display_widget.dart';

/// TrueCircleAppBar - Clean & Modern
class TrueCircleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showCoins;

  const TrueCircleAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showCoins = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.light,
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // TrueCircle Logo - New branded logo 🌟
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 12),
            child: ClipOval(
              child: Image.asset(
                'assets/images/TrueCircle-Logo.png',
                width: 30,
                height: 30,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF14B8A6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
      leading: leading,
      actions: [
        if (showCoins) ...[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: SimpleCoinDisplay(
              userId: 'default_user', // Replace with actual user ID
              onTap: () => _showCoinDetailsModal(context),
            ),
          ),
        ],
        ...?actions,
      ],
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFEF4444), // Joy Red
              Color(0xFFF59E0B), // Hope Orange
              Color(0xFF10B981), // Calm Green
              Color(0xFF3B82F6), // Clarity Blue
              Color(0xFF8B5CF6), // Serenity Purple
              Color(0xFFEC4899), // Warm Pink
            ],
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
      ),
    );
  }

  void _showCoinDetailsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Image.asset(
                    'assets/images/TrueCircle_Coin.png',
                    width: 24,
                    height: 24,
                    color: Colors.amber,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.monetization_on,
                        color: Colors.amber,
                        size: 24,
                      );
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    'आपके TrueCircle Coins',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(),
            const Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: CoinDisplayWidget(
                  userId: 'default_user', // Replace with actual user ID
                  showHistory: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
