import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Extra small screens (very small phones like iPhone SE 1st gen)
  static bool isExtraSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width < 340;
  }

  static bool isSmallScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 340 &&
        MediaQuery.of(context).size.width < 360;
  }

  static bool isMediumScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 360 &&
        MediaQuery.of(context).size.width < 600;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600;
  }

  // Check if screen height is very small
  static bool isShortScreen(BuildContext context) {
    return MediaQuery.of(context).size.height < 600;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return const EdgeInsets.all(8);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.all(12);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.all(16);
    } else {
      return const EdgeInsets.all(20);
    }
  }

  // Responsive horizontal padding
  static EdgeInsets getResponsiveHorizontalPadding(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 8);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 20);
    }
  }

  // Responsive vertical padding
  static EdgeInsets getResponsiveVerticalPadding(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return const EdgeInsets.symmetric(vertical: 6);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(vertical: 8);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.symmetric(vertical: 12);
    } else {
      return const EdgeInsets.symmetric(vertical: 16);
    }
  }

  // Responsive font sizes
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isExtraSmallScreen(context)) {
      return baseSize * 0.85;
    } else if (isSmallScreen(context)) {
      return baseSize * 0.9;
    } else if (isMediumScreen(context)) {
      return baseSize;
    } else {
      return baseSize * 1.1;
    }
  }

  // Responsive card width
  static double getCardWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isExtraSmallScreen(context)) {
      return screenWidth * 0.9;
    } else if (isSmallScreen(context)) {
      return screenWidth * 0.85;
    } else if (isMediumScreen(context)) {
      return screenWidth * 0.8;
    } else {
      return 400;
    }
  }

  // Responsive spacing
  static double getResponsiveSpacing(BuildContext context, double baseSpacing) {
    if (isExtraSmallScreen(context)) {
      return baseSpacing * 0.65;
    } else if (isSmallScreen(context)) {
      return baseSpacing * 0.75;
    } else if (isMediumScreen(context)) {
      return baseSpacing;
    } else {
      return baseSpacing * 1.25;
    }
  }

  // Responsive icon size
  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isExtraSmallScreen(context)) {
      return baseSize * 0.8;
    } else if (isSmallScreen(context)) {
      return baseSize * 0.9;
    } else {
      return baseSize;
    }
  }

  // Responsive button height
  static double getResponsiveButtonHeight(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return 44;
    } else if (isSmallScreen(context)) {
      return 48;
    } else {
      return 52;
    }
  }

  // Responsive dialog width
  static double getResponsiveDialogWidth(BuildContext context) {
    final screenWidth = getScreenWidth(context);
    if (isExtraSmallScreen(context)) {
      return screenWidth * 0.95;
    } else if (isSmallScreen(context)) {
      return screenWidth * 0.9;
    } else if (isMediumScreen(context)) {
      return screenWidth * 0.85;
    } else {
      return 500;
    }
  }

  // Safe text widget that prevents overflow
  static Widget safeText(
    String text, {
    TextStyle? style,
    int? maxLines,
    TextOverflow? overflow,
    TextAlign? textAlign,
  }) {
    return Text(
      text,
      style: style,
      maxLines: maxLines ?? 2,
      overflow: overflow ?? TextOverflow.ellipsis,
      textAlign: textAlign,
      softWrap: true,
    );
  }

  // Flexible container that adapts to screen size
  static Widget flexibleContainer({
    required Widget child,
    required BuildContext context,
    EdgeInsets? padding,
    double? maxWidth,
  }) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: maxWidth ?? getCardWidth(context)),
      padding: padding ?? getResponsivePadding(context),
      child: child,
    );
  }

  // Scrollable column for preventing overflow
  static Widget scrollableColumn({
    required List<Widget> children,
    EdgeInsets? padding,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return SingleChildScrollView(
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Responsive row that wraps on small screens
  static Widget responsiveRow({
    required BuildContext context,
    required List<Widget> children,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    if (isExtraSmallScreen(context) || isSmallScreen(context)) {
      return Column(
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
        children: children,
      );
    } else {
      return Row(
        mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
        crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.center,
        children: children,
      );
    }
  }

  // Flexible sized box
  static Widget flexibleSizedBox({
    required BuildContext context,
    double? height,
    double? width,
  }) {
    return SizedBox(
      height: height != null ? getResponsiveSpacing(context, height) : null,
      width: width != null ? getResponsiveSpacing(context, width) : null,
    );
  }

  // Responsive grid column count
  static int getGridColumnCount(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return 1;
    } else if (isSmallScreen(context)) {
      return 2;
    } else if (isMediumScreen(context)) {
      return 2;
    } else {
      return 3;
    }
  }

  // Responsive list tile padding
  static EdgeInsets getListTilePadding(BuildContext context) {
    if (isExtraSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 6);
    } else if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  // Responsive border radius
  static double getResponsiveBorderRadius(
    BuildContext context,
    double baseRadius,
  ) {
    if (isExtraSmallScreen(context)) {
      return baseRadius * 0.8;
    } else {
      return baseRadius;
    }
  }

  // Safe area wrapper
  static Widget safeAreaWrapper({
    required Widget child,
    bool top = true,
    bool bottom = true,
    bool left = true,
    bool right = true,
  }) {
    return SafeArea(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: child,
    );
  }

  // Constrained box for dialogs
  static Widget constrainedDialog({
    required BuildContext context,
    required Widget child,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: getResponsiveDialogWidth(context),
        maxHeight: getScreenHeight(context) * 0.9,
      ),
      child: child,
    );
  }
}
