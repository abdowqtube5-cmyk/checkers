// lib/core/constants/game_constants.dart

/// ثوابت اللعبة الأساسية
class GameConstants {
  GameConstants._();

  /// عدد صفوف و أعمدة اللوحة
  static const int boardSize = 8;

  /// سرعة تحريك القطعة بالثانية (للأنيميشن)
  static const double pieceSpeed = 400.0; // pixels per second

  /// معامل تسرع الأنيميشن (ثواني)
  static const double moveAnimationDuration = 0.35;

  /// مدة أنيميشن موت القطعة (ثواني)
  static const double deathAnimationDuration = 0.4;

  /// عمق البحث للـ Minimax (كلما زاد كلما أبطأ وأذكى)
  static const int minimaxDepth = 5;

  /// قيمة القطعة العادية في دالة التقييم
  static const int regularPieceValue = 10;

  /// قيمة قطعة الداما (الملك) في دالة التقييم
  static const int kingPieceValue = 30;

  /// اسم overlay انتهاء اللعبة
  static const String gameOverOverlayKey = 'GameOverOverlay';

  /// نسبة حجم القطعة من حجم المربع
  static const double pieceRadiusRatio = 0.40;

  /// نسبة حجم التاج من حجم القطعة
  static const double crownRadiusRatio = 0.45;

  /// نسبة حجم نقطة الإشارة (hint) من حجم المربع
  static const double hintRadiusRatio = 0.20;
}