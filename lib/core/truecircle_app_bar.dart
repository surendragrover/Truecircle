import 'package:flutter/material.dart';

/// TrueCircleAppBar
/// Reusable AppBar with brand styling and a bottom marquee for privacy message.
class TrueCircleAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  const TrueCircleAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
  }) : super(key: key);

  static const String _privacyMessage =
      'TrueCircle pe uski nijta ka pura khyal rakhate hue ise phone verify hote hi lock kar diya gaya hai aur ab ye internet se connect nahin hogi. TrueCircle aap dwara jo bhi jankari bhari ati hai uski jankari sirf aap tak hi seemit rahati hai. isliye aap ismen har entry bina kisi sankoch ke kar sakte hain. sahi parinam pane ke liye entry karte samay nishpksh rahen aur sachchai bharen. apki ye jaankaroi sirf apki hai aur apki hi rahegi.';

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 28);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(title),
      leading: leading,
      actions: actions,
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
          color: Colors.orangeAccent.withOpacity(0.95), // a readable background
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
    Key? key,
    required this.text,
    required this.textStyle,
    this.velocity = 50.0,
    this.pauseDuration = const Duration(seconds: 1),
  }) : super(key: key);

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
