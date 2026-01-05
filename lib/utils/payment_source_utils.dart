import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class PaymentSourceUtils {
  static const List<String> sources = [
    'GPay',
    'PhonePe',
    'ICICI Credit Card',
    'RBL Credit Card',
    'Axis Credit Card',
    'HDFC',
    'Cash',
    'Other',
  ];

  static const Map<String, IconData> sourceIcons = {
    'GPay': LucideIcons.smartphone,
    'PhonePe': LucideIcons.smartphone,
    'ICICI Credit Card': LucideIcons.creditCard,
    'RBL Credit Card': LucideIcons.creditCard,
    'Axis Credit Card': LucideIcons.creditCard,
    'HDFC': LucideIcons.landmark,
    'Cash': LucideIcons.wallet,
    'Other': LucideIcons.moreHorizontal,
  };

  static const Map<String, Color> sourceColors = {
    'GPay': Color(0xFF4285F4), // Google Blue
    'PhonePe': Color(0xFF5F259F), // PhonePe Purple
    'ICICI Credit Card': Color(0xFFE55B24), // ICICI Orange
    'RBL Credit Card': Color(0xFF1C3D72), // RBL Blue
    'Axis Credit Card': Color(0xFF97144D), // Axis Burgundy
    'HDFC': Color(0xFF004C8F), // HDFC Blue
    'Cash': Color(0xFF22C55E), // Green
    'Other': Color(0xFF6B7280), // Grey
  };

  static IconData getIcon(String source) {
    return sourceIcons[source] ?? LucideIcons.moreHorizontal;
  }

  static Color getColor(String source) {
    return sourceColors[source] ?? const Color(0xFF6B7280);
  }
}
