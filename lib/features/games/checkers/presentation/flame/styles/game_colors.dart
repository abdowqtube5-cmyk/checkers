// lib/features/games/checkers/presentation/flame/styles/game_colors.dart
//
// ألوان اللعبة داخل Flame — تُعرَّف بـ ui.Color

import 'dart:ui' as ui;

class GameColors {
  GameColors._();

  // ── اللوحة ──────────────────────────────
  static const ui.Color lightSquare = ui.Color(0xFFF0D9B5); // بيج فاتح
  static const ui.Color darkSquare  = ui.Color(0xFFB58863); // بني داكن
  static const ui.Color boardBorder = ui.Color(0xFF5D4037);

  // ── القطع ──────────────────────────────
  static const ui.Color whitePiece       = ui.Color(0xFFFFF8E1);
  static const ui.Color whitePieceStroke = ui.Color(0xFF8D6E63);
  static const ui.Color whitePieceShade  = ui.Color(0xFFD7CCC8);

  static const ui.Color blackPiece       = ui.Color(0xFF212121);
  static const ui.Color blackPieceStroke = ui.Color(0xFF757575);
  static const ui.Color blackPieceShade  = ui.Color(0xFF424242);

  // ── التاج (الداما) ─────────────────────
  static const ui.Color crownGold        = ui.Color(0xFFFFD700);
  static const ui.Color crownGoldStroke  = ui.Color(0xFFFFA000);

  // ── الإشارات (hints) ──────────────────
  static const ui.Color hintNormal       = ui.Color(0x7022CC00); // أخضر شفاف
  static const ui.Color hintCapture      = ui.Color(0x70CC2200); // أحمر شفاف

  // ── الاختيار ──────────────────────────
  static const ui.Color selectedSquare   = ui.Color(0xAAFFEB3B); // أصفر شفاف

  // ── تأثير الموت ───────────────────────
  static const ui.Color deathSmoke       = ui.Color(0x88888888);

  // ── واجهة المستخدم (overlay) ───────────
  static const ui.Color overlayBg        = ui.Color(0xDD1A1208);
  static const ui.Color textLight        = ui.Color(0xFFFFF8E1);
}