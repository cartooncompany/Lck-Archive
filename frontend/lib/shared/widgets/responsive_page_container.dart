import 'package:flutter/material.dart';

final class AppResponsiveBreakpoints {
  static const double compact = 600;
  static const double medium = 960;
  static const double wide = 1200;
  static const double extraWide = 1440;
}

class ResponsivePageContainer extends StatelessWidget {
  const ResponsivePageContainer({
    required this.child,
    this.maxWidth = 1120,
    this.alignment = Alignment.topCenter,
    super.key,
  });

  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        return Align(
          alignment: alignment,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _horizontalPaddingFor(availableWidth),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }

  double _horizontalPaddingFor(double width) {
    if (width >= AppResponsiveBreakpoints.extraWide) {
      return 32;
    }
    if (width >= AppResponsiveBreakpoints.wide) {
      return 28;
    }
    if (width >= AppResponsiveBreakpoints.compact) {
      return 24;
    }
    return 16;
  }
}
