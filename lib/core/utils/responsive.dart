import 'package:flutter/material.dart';

class Responsive {
  static bool isMobileSmall(BuildContext context) =>
      MediaQuery.of(context).size.width <= 320;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width <= 375;

  static double getResponsivePadding(BuildContext context) =>
      isMobileSmall(context) ? 16.0 : 24.0;

  static double getResponsiveFontSize(BuildContext context, double baseSize) =>
      isMobileSmall(context) ? baseSize * 0.9 : baseSize;
}
