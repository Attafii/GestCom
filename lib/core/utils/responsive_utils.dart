import 'package:flutter/material.dart';

/// Responsive breakpoints for the application
class ResponsiveBreakpoints {
  static const double mobile = 768;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

/// Responsive utility class for adaptive layouts
class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  /// Get screen width
  double get screenWidth => MediaQuery.of(context).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(context).size.height;

  /// Check if screen is mobile
  bool get isMobile => screenWidth < ResponsiveBreakpoints.mobile;

  /// Check if screen is tablet
  bool get isTablet =>
      screenWidth >= ResponsiveBreakpoints.mobile &&
      screenWidth < ResponsiveBreakpoints.tablet;

  /// Check if screen is desktop
  bool get isDesktop => screenWidth >= ResponsiveBreakpoints.tablet;

  /// Get adaptive padding based on screen size
  EdgeInsets get screenPadding {
    if (isMobile) {
      return const EdgeInsets.all(12);
    } else if (isTablet) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(24);
    }
  }

  /// Get adaptive horizontal padding
  double get horizontalPadding {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 24;
  }

  /// Get adaptive vertical padding
  double get verticalPadding {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 24;
  }

  /// Get adaptive spacing
  double get spacing {
    if (isMobile) return 12;
    if (isTablet) return 16;
    return 24;
  }

  /// Get adaptive small spacing
  double get smallSpacing {
    if (isMobile) return 8;
    if (isTablet) return 12;
    return 16;
  }

  /// Get adaptive font size for headers
  double get headerFontSize {
    if (isMobile) return 20;
    if (isTablet) return 24;
    return 28;
  }

  /// Get adaptive font size for subheaders
  double get subHeaderFontSize {
    if (isMobile) return 16;
    if (isTablet) return 18;
    return 20;
  }

  /// Get adaptive font size for body text
  double get bodyFontSize {
    if (isMobile) return 13;
    if (isTablet) return 14;
    return 14;
  }

  /// Get adaptive button height
  double get buttonHeight {
    if (isMobile) return 40;
    if (isTablet) return 44;
    return 48;
  }

  /// Get adaptive icon size
  double get iconSize {
    if (isMobile) return 20;
    if (isTablet) return 22;
    return 24;
  }

  /// Get adaptive table min width
  double get tableMinWidth {
    if (isMobile) return screenWidth - 48;
    if (isTablet) return 700;
    return 900;
  }

  /// Get number of columns for grid layouts
  int get gridColumns {
    if (isMobile) return 1;
    if (isTablet) return 2;
    if (screenWidth < ResponsiveBreakpoints.desktop) return 3;
    return 4;
  }

  /// Build responsive value based on screen size
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isMobile) return mobile;
    if (isTablet) return tablet ?? mobile;
    return desktop ?? tablet ?? mobile;
  }
}

/// Extension to easily access responsive utils from BuildContext
extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);
}
