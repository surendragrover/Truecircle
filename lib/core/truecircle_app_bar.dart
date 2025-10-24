import 'package:flutter/material.dart';

/// TrueCircleAppBar
/// Reusable AppBar with brand styling, TrueCircle logo, upper menu, and bottom marquee
class TrueCircleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLogo;
  final bool showUpperMenu;

  const TrueCircleAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.showLogo = true, // Default में logo show करें
    this.showUpperMenu = true, // Default में upper menu show करें
  });

  static const String _privacyMessage =
      'TrueCircle pe uski nijta ka pura khyal rakhate hue ise phone verify hote hi lock kar diya gaya hai aur ab ye internet se connect nahin hogi. TrueCircle aap dwara jo bhi jankari bhari ati hai uski jankari sirf aap tak hi seemit rahati hai. isliye aap ismen har entry bina kisi sankoch ke kar sakte hain. sahi parinam pane ke liye entry karte samay nishpksh rahen aur sachchai bharen. apki ye jaankaroi sirf apki hai aur apki hi rahegi.';

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 28);

  /// Default upper menu actions
  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      PopupMenuButton<String>(
        icon: const Icon(Icons.more_vert),
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          const PopupMenuItem(value: 'profile', child: Text('Profile')),
          const PopupMenuItem(value: 'settings', child: Text('Settings')),
          const PopupMenuItem(value: 'help', child: Text('Help & Support')),
          const PopupMenuItem(value: 'about', child: Text('About TrueCircle')),
        ],
      ),
    ];
  }

  /// Handle menu actions
  void _handleMenuAction(BuildContext context, String action) {
    switch (action) {
      case 'profile':
        // TODO: Navigate to profile page
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profile coming soon!')));
        break;
      case 'settings':
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Settings coming soon!')));
        break;
      case 'help':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Help & Support coming soon!')),
        );
        break;
      case 'about':
        Navigator.pushNamed(context, '/about'); // About page पर navigate करें
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Default logo leading widget
    final defaultLeading = showLogo
        ? Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Image.asset(
              'assets/icons/truecircle_logo.png',
              height: 24,
              width: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Fallback if logo not found
                return const Icon(Icons.circle, size: 24);
              },
            ),
          )
        : null;

    // Combine provided actions with default upper menu
    final combinedActions = <Widget>[
      ...?actions, // User provided actions first
      if (showUpperMenu) ..._buildDefaultActions(context),
    ];

    return AppBar(
      title: Text(title),
      leading:
          leading ?? defaultLeading, // Use provided leading or default logo
      actions: combinedActions.isNotEmpty ? combinedActions : null,
      backgroundColor: theme.appBarTheme.backgroundColor,
      elevation: theme.appBarTheme.elevation ?? 0,
      centerTitle: theme.appBarTheme.centerTitle ?? false,
      iconTheme: theme.appBarTheme.iconTheme,
      // bottom marquee
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(28),
        child: Container(
          height: 28,
          width: double.infinity,
          color: Colors.orangeAccent.withValues(
            alpha: 0.95,
          ), // a readable background
          padding: const EdgeInsets.symmetric(horizontal: 12),
          alignment: Alignment.centerLeft,
          child: _MarqueeText(
            text: _privacyMessage,
            textStyle: const TextStyle(color: Colors.white, fontSize: 12),
            pauseDuration: Duration(seconds: 2),
            velocity: 40.0,
          ),
        ),
      ),
    );
  }
}

class _MarqueeText extends StatefulWidget {
  final String text;
  final TextStyle textStyle;
  final double velocity; // pixels per second
  final Duration pauseDuration;

  const _MarqueeText({
    super.key,
    required this.text,
    required this.textStyle,
    this.velocity = 50.0,
    this.pauseDuration = const Duration(seconds: 1),
  });

  @override
  State<_MarqueeText> createState() => _MarqueeTextState();
}

class _MarqueeTextState extends State<_MarqueeText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final containerWidth = constraints.maxWidth;
        final textPainter = TextPainter(
          text: TextSpan(text: widget.text, style: widget.textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final textWidth = textPainter.width;

        // If text fits, render normally
        if (textWidth <= containerWidth) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text(
              widget.text,
              style: widget.textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        // distance to travel before repeating
        const gap = 48.0;
        final distance = textWidth + gap;
        final durationMs = (distance / widget.velocity * 1000).toInt().clamp(
          3000,
          60000,
        );
        final duration = Duration(milliseconds: durationMs);

        if (_controller.duration != duration) {
          _controller.duration = duration;
          _controller.repeat();
        }

        return ClipRect(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final offset = -(_controller.value * distance);
              return Transform.translate(
                offset: Offset(offset, 0),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Text(widget.text, style: widget.textStyle),
                    SizedBox(width: gap),
                    Text(widget.text, style: widget.textStyle),
                    const SizedBox(width: 12),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
