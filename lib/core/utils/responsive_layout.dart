import 'package:flutter/material.dart';
import '../constants/app_dimensions.dart';

/// Kiểu hiển thị màn hình
enum ScreenType { mobile, tablet, desktop }

/// Widget hỗ trợ xây dựng bố cục thích ứng (responsive) theo kích thước màn hình
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < AppDimensions.mobileBreakpoint) {
      return ScreenType.mobile;
    } else if (width < AppDimensions.tabletBreakpoint) {
      return ScreenType.tablet;
    } else {
      return ScreenType.desktop;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= AppDimensions.tabletBreakpoint) {
          return desktop;
        } else if (constraints.maxWidth >= AppDimensions.mobileBreakpoint) {
          return tablet ?? desktop;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Extension tiện ích trên BuildContext để kiểm tra nhanh kích thước màn hình
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;
  double get screenHeight => MediaQuery.sizeOf(this).height;

  bool get isMobile => screenWidth < AppDimensions.mobileBreakpoint;
  bool get isTablet =>
      screenWidth >= AppDimensions.mobileBreakpoint &&
      screenWidth < AppDimensions.tabletBreakpoint;
  bool get isDesktop => screenWidth >= AppDimensions.tabletBreakpoint;
}
