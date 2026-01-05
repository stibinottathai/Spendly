import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CategoryUtils {
  static const Map<String, IconData> categoryIcons = {
    'Food': LucideIcons.utensils,
    'Transport': LucideIcons.car,
    'Shopping': LucideIcons.shoppingBag,
    'Grocery': LucideIcons.shoppingCart,
    'Drinks': LucideIcons.glassWater,
    'Bills': LucideIcons.receipt,
    'Entertainment': LucideIcons.film,
    'Game': LucideIcons.gamepad2,
    'Health': LucideIcons.heartPulse,
    'Family': LucideIcons.users,
    'Loans': LucideIcons.landmark,
    'Other': LucideIcons.moreHorizontal,
  };

  static const Map<String, Color> categoryColors = {
    'Food': Color(0xFFF97316), // Orange
    'Transport': Color(0xFF3B82F6), // Blue
    'Shopping': Color(0xFFEC4899), // Pink
    'Grocery': Color(0xFF22C55E), // Green
    'Drinks': Color(0xFFEAB308), // Yellow
    'Bills': Color(0xFFEF4444), // Red
    'Entertainment': Color(0xFF8B5CF6), // Purple
    'Game': Color(0xFF0EA5E9), // Light Blue
    'Health': Color(0xFF10B981), // Green
    'Family': Color(0xFF6366F1), // Indigo
    'Loans': Color(0xFFDC2626), // Dark Red
    'Other': Color(0xFF6B7280), // Grey
  };

  static IconData getIcon(String category) {
    return categoryIcons[category] ?? LucideIcons.moreHorizontal;
  }

  static Color getColor(String category) {
    return categoryColors[category] ?? const Color(0xFF6B7280);
  }
}
