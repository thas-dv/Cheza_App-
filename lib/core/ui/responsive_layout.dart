import 'package:flutter/widgets.dart';

class Breakpoints {
  static const double mobileMax = 767;
  static const double tabletMax = 1199;

  static bool isMobile(double width) => width <= mobileMax;
  static bool isTablet(double width) => width > mobileMax && width <= tabletMax;
  static bool isDesktop(double width) => width > tabletMax;
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        if (Breakpoints.isDesktop(width)) {
          return desktop;
        }

        if (Breakpoints.isTablet(width) && tablet != null) {
          return tablet!;
        }

        return mobile;
      },
    );
  }
}
