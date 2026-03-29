import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart' show GetNavigation;

class ThemeToggleButton extends StatelessWidget {
  final bool isDark;

  const ThemeToggleButton({super.key, required this.isDark});
  
 
  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: () {
        Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
      },
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      tooltip: isDark ? 'الوضع الفاتح' : 'الوضع الداكن',
    );
  }
}