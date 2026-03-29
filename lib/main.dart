// lib/main.dart
//
// نقطة انطلاق التطبيق:
// - تهيئة GetX
// - تسجيل GameController
// - تعريف المسارات
// - ثيم Light / Dark

import 'package:checkers/features/games/checkers/presentation/manager/game_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:checkers/core/theme/app_theme.dart';

import 'package:checkers/features/games/checkers/presentation/pages/game_page.dart';
import 'package:checkers/features/main_menu/presentation/pages/main_menu_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // إخفاء شريط الحالة في وضع اللعبة
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const CheckersApp());
}

class CheckersApp extends StatelessWidget {
  const CheckersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'لعبة الداما',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,

      // ── حقن GameController عالمياً ──────────
      initialBinding: BindingsBuilder(() {
        Get.put<GameController>(GameController(), permanent: true);
      }),

      // ── تعريف المسارات ──────────────────────
      initialRoute: '/menu',
      getPages: [
        GetPage(
          name: '/menu',
          page: () => const MainMenuPage(),
          transition: Transition.fadeIn,
        ),
        GetPage(
          name: '/game',
          page: () => const GamePage(),
          transition: Transition.rightToLeft,
        ),
      ],

      // ── إعدادات النص (دعم العربية) ───────────
      textDirection: TextDirection.rtl,
      locale: const Locale('ar'),
    );
  }
}