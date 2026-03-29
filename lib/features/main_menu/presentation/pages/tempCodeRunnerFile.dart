// lib/features/main_menu/presentation/pages/main_menu_page.dart
//
// القائمة الرئيسية:
// - اختيار طريقة اللعب (ألمانية / تركية)
// - اختيار لون الحجر
// - تبديل ثيم Light / Dark
 
import 'package:checkers/features/games/checkers/presentation/manager/game_controller.dart';
import 'package:checkers/features/main_menu/presentation/widgets/checkersBoardIcon.dart';
import 'package:checkers/features/main_menu/presentation/widgets/colorSelector.dart';
import 'package:checkers/features/main_menu/presentation/widgets/ruleRow.dart';
import 'package:checkers/features/main_menu/presentation/widgets/sectionCard.dart';
import 'package:checkers/features/main_menu/presentation/widgets/startButton.dart';
import 'package:checkers/features/main_menu/presentation/widgets/themeToggleButton.dart';
import 'package:checkers/features/main_menu/presentation/widgets/variantSelector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

 
class MainMenuPage extends StatefulWidget {
  const MainMenuPage({super.key});
 
  @override
  State<MainMenuPage> createState() => _MainMenuPageState();
}
 
class _MainMenuPageState extends State<MainMenuPage> {
  GameVariant _selectedVariant = GameVariant.german;
  PieceColor _selectedColor = PieceColor.white;
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
 
    return Scaffold(
      body: Stack(
        children: [
          // ── خلفية متدرجة ─────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [const Color(0xFF1A1208), const Color(0xFF2C1A0E)]
                    : [const Color(0xFFF5F0E8), const Color(0xFFE8D5C0)],
              ),
            ),
          ),
 
          // ── المحتوى ───────────────────────────
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // ── زر الثيم ─────────────────
                  Align(
                    alignment: Alignment.topRight,
                    child: ThemeToggleButton(isDark: isDark),
                  ),
                  const SizedBox(height: 12),
 
                  // ── العنوان ──────────────────
                  _buildTitle(theme),
                  const SizedBox(height: 40),
 
                  // ── اختيار طريقة اللعب ───────
                  SectionCard(
                    title: 'طريقة اللعب',
                    child: VariantSelector(
                      selected: _selectedVariant,
                      onChanged: (v) => setState(() => _selectedVariant = v),
                    ),
                  ),
                  const SizedBox(height: 16),
 
                  // ── اختيار اللون ──────────────
                  SectionCard(
                    title: 'لون قطعتك',
                    child: ColorSelector(
                      selected: _selectedColor,
                      onChanged: (c) => setState(() => _selectedColor = c),
                    ),
                  ),
                  const SizedBox(height: 32),
 
                  // ── زر البدء ─────────────────
                  StartButton(
                    onTap: _startGame,
                  ),
                  const SizedBox(height: 20),
 
                  // ── معلومات اللعبة ───────────
                  _buildRulesSummary(theme),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  void _startGame() {
    final controller = Get.find<GameController>();
    controller.startGame(_selectedVariant, _selectedColor);
    Get.toNamed('/game');
  }
 
  Widget _buildTitle(ThemeData theme) {
    return Column(
      children: [
        // رسم رمز اللوحة
        CheckersBoardIcon(),
        const SizedBox(height: 16),
        Text(
          'لعبة الداما',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'العب ضد الذكاء الاصطناعي',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }
 
  Widget _buildRulesSummary(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ملخص القواعد',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const RuleRow(
                icon: '⚪',
                text: 'الأبيض يبدأ أولاً'),
            const RuleRow(
                icon: '🏃',
                text: 'الأكل إجباري — لا يمكنك تجاهله'),
            const RuleRow(
                icon: '👑',
                text: 'اصل للسطر الأخير لتصبح ملكاً (داما)'),
            const RuleRow(
                icon: '🤖',
                text: 'الخصم ذكاء اصطناعي يفكر بعمق 5 خطوات'),
            const RuleRow(
                icon: '🏳️',
                text: 'يمكنك الاستسلام في أي وقت'),
          ],
        ),
      ),
    );
  }
}