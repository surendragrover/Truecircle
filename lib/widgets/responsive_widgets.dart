import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType, double screenWidth) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = _getDeviceType(screenWidth);

    return builder(context, deviceType, screenWidth);
  }

  DeviceType _getDeviceType(double width) {
    if (width < 600) return DeviceType.mobile;
    if (width < 1024) return DeviceType.tablet;
    return DeviceType.desktop;
  }
}

enum DeviceType {
  mobile,
  tablet,
  desktop,
}

class ResponsiveWidget extends StatelessWidget {
  final Widget? mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveWidget({
    super.key,
    this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < 600) {
      return mobile ?? tablet ?? desktop ?? const SizedBox.shrink();
    } else if (screenWidth < 1024) {
      return tablet ?? mobile ?? desktop ?? const SizedBox.shrink();
    } else {
      return desktop ?? tablet ?? mobile ?? const SizedBox.shrink();
    }
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Adaptive padding based on screen size
    EdgeInsetsGeometry adaptivePadding = padding ?? const EdgeInsets.all(16);
    if (screenWidth < 600) {
      adaptivePadding = const EdgeInsets.all(16);
    } else if (screenWidth < 1024) {
      adaptivePadding = const EdgeInsets.all(24);
    } else {
      adaptivePadding = const EdgeInsets.all(32);
    }

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? (screenWidth > 1024 ? 1200 : double.infinity),
      ),
      padding: adaptivePadding,
      child: child,
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;

  const ResponsiveGrid({
    super.key,
    required this.children,
    this.spacing = 16,
    this.runSpacing = 16,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, screenWidth) {
        int columns;
        switch (deviceType) {
          case DeviceType.mobile:
            columns = mobileColumns;
            break;
          case DeviceType.tablet:
            columns = tabletColumns;
            break;
          case DeviceType.desktop:
            columns = desktopColumns;
            break;
        }

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children.map((child) {
            final itemWidth = (screenWidth - (spacing * (columns - 1)) - 64) / columns;
            return SizedBox(
              width: itemWidth.clamp(200.0, double.infinity),
              child: child,
            );
          }).toList(),
        );
      },
    );
  }
}

// Responsive text sizes
class ResponsiveText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? mobileFontSize;
  final double? tabletFontSize;
  final double? desktopFontSize;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.mobileFontSize,
    this.tabletFontSize,
    this.desktopFontSize,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, screenWidth) {
        double fontSize = 16; // Default
        
        switch (deviceType) {
          case DeviceType.mobile:
            fontSize = mobileFontSize ?? 16;
            break;
          case DeviceType.tablet:
            fontSize = tabletFontSize ?? 18;
            break;
          case DeviceType.desktop:
            fontSize = desktopFontSize ?? 20;
            break;
        }

        return Text(
          text,
          style: (style ?? const TextStyle()).copyWith(fontSize: fontSize),
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

// Responsive spacing
class ResponsiveSpacing {
  static double small(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 8;
    if (width < 1024) return 12;
    return 16;
  }

  static double medium(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 1024) return 24;
    return 32;
  }

  static double large(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 24;
    if (width < 1024) return 32;
    return 48;
  }
}

// Responsive card with adaptive sizing
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;
  final double? elevation;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, screenWidth) {
        // Adaptive padding
        EdgeInsetsGeometry cardPadding = padding ?? const EdgeInsets.all(16);
        if (deviceType == DeviceType.mobile) {
          cardPadding = const EdgeInsets.all(12);
        } else if (deviceType == DeviceType.tablet) {
          cardPadding = const EdgeInsets.all(16);
        } else {
          cardPadding = const EdgeInsets.all(20);
        }

        return Card(
          color: color,
          elevation: elevation ?? 2,
          child: Padding(
            padding: cardPadding,
            child: child,
          ),
        );
      },
    );
  }
}

// Responsive app bar with adaptive actions
class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const ResponsiveAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, deviceType, screenWidth) {
        // Adaptive title size
        double titleSize = 20;
        if (deviceType == DeviceType.mobile) titleSize = 18;
        if (deviceType == DeviceType.tablet) titleSize = 20;
        if (deviceType == DeviceType.desktop) titleSize = 22;

        return AppBar(
          title: Text(
            title,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: foregroundColor ?? Colors.black87,
            ),
          ),
          backgroundColor: backgroundColor ?? Colors.blue[50],
          foregroundColor: foregroundColor ?? Colors.black87,
          elevation: 0,
          centerTitle: deviceType == DeviceType.mobile,
          leading: leading,
          actions: deviceType == DeviceType.mobile && actions != null && actions!.length > 3
              ? [
                  PopupMenuButton<int>(
                    itemBuilder: (context) => actions!
                        .asMap()
                        .entries
                        .map((entry) => PopupMenuItem<int>(
                              value: entry.key,
                              child: entry.value,
                            ))
                        .toList(),
                    onSelected: (index) {
                      // Handle action selection
                    },
                  ),
                ]
              : actions,
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
