import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppThemeController {
  static const String _themeColorKey = 'themeSeedColor';
  static const Color defaultColor = Color(0xFF2563EB);

  static final ValueNotifier<Color> seedColor = ValueNotifier<Color>(
    defaultColor,
  );

  static const List<AppThemeOption> options = [
    AppThemeOption(
      name: 'Notebook Blue',
      description: 'Clean and familiar for everyday study.',
      color: Color(0xFF2563EB),
      icon: Icons.menu_book,
    ),
    AppThemeOption(
      name: 'Forest Focus',
      description: 'Calm, grounded, and easy on long sessions.',
      color: Color(0xFF16803C),
      icon: Icons.eco,
    ),
    AppThemeOption(
      name: 'Teal Lab',
      description: 'Sharp and technical without feeling cold.',
      color: Color(0xFF0F766E),
      icon: Icons.science,
    ),
    AppThemeOption(
      name: 'Ember Plan',
      description: 'Warm energy for tasks, deadlines, and momentum.',
      color: Color(0xFFEA580C),
      icon: Icons.local_fire_department,
    ),
    AppThemeOption(
      name: 'Berry Notes',
      description: 'Expressive, rich, and good for creative study.',
      color: Color(0xFFBE185D),
      icon: Icons.brush,
    ),
    AppThemeOption(
      name: 'Indigo Desk',
      description: 'Deep academic tone for focused review.',
      color: Color(0xFF4F46E5),
      icon: Icons.school,
    ),
  ];

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedColor = prefs.getInt(_themeColorKey);

    if (savedColor != null) {
      seedColor.value = Color(savedColor);
    }
  }

  static Future<void> updateColor(Color color) async {
    seedColor.value = color;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, color.toARGB32());
  }

  static AppThemeOption optionFor(Color color) {
    return options.firstWhere(
      (option) => option.color.toARGB32() == color.toARGB32(),
      orElse: () => options.first,
    );
  }
}

class AppThemeOption {
  final String name;
  final String description;
  final Color color;
  final IconData icon;

  const AppThemeOption({
    required this.name,
    required this.description,
    required this.color,
    required this.icon,
  });
}
