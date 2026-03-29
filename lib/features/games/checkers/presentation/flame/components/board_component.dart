// lib/features/games/checkers/presentation/flame/components/board_component.dart
//
// يرسم لوحة 8×8 بطريقتين حسب المتغير:
//
// ── الألمانية (German) ─────────────────────────────────────
//   مربعات فاتحة وداكنة متعاقبة (شطرنج كلاسيكي)
//   القطع تُوضع على المربعات الداكنة فقط
//
// ── التركية (Turkish) ──────────────────────────────────────
//   خلفية موحدة اللون + شبكة خطوط متقاطعة أفقية وعمودية
//   المربعات الناتجة بين الخطوط هي مواضع القطع
//   (كل المربعات قابلة للعب)

import 'dart:ui' as ui;
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:flame/components.dart';
import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/presentation/flame/styles/game_colors.dart';

class BoardComponent extends PositionComponent {
  final double tileSize;
  final GameVariant variant;

  Position? _selectedPos;

  // ── Paints مشتركة ───────────────────────────
  late final ui.Paint _lightSquarePaint;
  late final ui.Paint _darkSquarePaint;
  late final ui.Paint _selectedPaint;
  late final ui.Paint _borderOuterPaint;

  // ── Paints خاصة بالوضع التركي ───────────────
  late final ui.Paint _turkishBgPaint;
  late final ui.Paint _turkishGridPaint;
  late final ui.Paint _turkishGridThickPaint;
  late final ui.Paint _turkishCellBorderPaint;

  BoardComponent({
    required this.tileSize,
    required this.variant,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(tileSize * GameConstants.boardSize),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    // ── مشتركة ──────────────────────────────
    _lightSquarePaint = ui.Paint()
      ..color = GameColors.lightSquare
      ..style = ui.PaintingStyle.fill;

    _darkSquarePaint = ui.Paint()
      ..color = GameColors.darkSquare
      ..style = ui.PaintingStyle.fill;

    _selectedPaint = ui.Paint()
      ..color = GameColors.selectedSquare
      ..style = ui.PaintingStyle.fill;

    _borderOuterPaint = ui.Paint()
      ..color = GameColors.boardBorder
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 4.0;

    // ── خاصة بالوضع التركي ──────────────────
    // خلفية المربعات: بيج دافئ موحد
    _turkishBgPaint = ui.Paint()
      ..color = const ui.Color(0xFFF5E6C8)
      ..style = ui.PaintingStyle.fill;

    // خطوط الشبكة الداخلية الرفيعة
    _turkishGridPaint = ui.Paint()
      ..color = const ui.Color(0xFF8B5E3C)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = ui.StrokeCap.square;

    // خطوط الشبكة السميكة (كل 4 مربعات — للتمييز البصري)
    _turkishGridThickPaint = ui.Paint()
      ..color = const ui.Color(0xFF6B3F1E)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = ui.StrokeCap.square;

    // حدود المربع المحدد (للوضع التركي)
    _turkishCellBorderPaint = ui.Paint()
      ..color = const ui.Color(0xFFFFEB3B)
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = 3.0;
  }

  // ════════════════════════════════════════════
  // الرسم الرئيسي
  // ════════════════════════════════════════════

  @override
  void render(ui.Canvas canvas) {
    if (variant == GameVariant.german) {
      _renderGerman(canvas);
    } else {
      _renderTurkish(canvas);
    }
  }

  // ────────────────────────────────────────────
  // الوضع الألماني: مربعات فاتحة/داكنة كلاسيكية
  // ────────────────────────────────────────────

  void _renderGerman(ui.Canvas canvas) {
    final boardPx = tileSize * GameConstants.boardSize;

    for (var row = 0; row < GameConstants.boardSize; row++) {
      for (var col = 0; col < GameConstants.boardSize; col++) {
        final screenRow = GameConstants.boardSize - 1 - row;
        final rect = ui.Rect.fromLTWH(
          col * tileSize,
          screenRow * tileSize,
          tileSize,
          tileSize,
        );

        // المربعات الداكنة = (row+col) فردي
        final isDark = (row + col) % 2 == 1;
        canvas.drawRect(rect, isDark ? _darkSquarePaint : _lightSquarePaint);

        // تظليل المربع المحدد
        if (_isSelected(row, col)) {
          canvas.drawRect(rect, _selectedPaint);
        }
      }
    }

    // إطار خارجي
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, boardPx, boardPx),
      _borderOuterPaint,
    );
  }

  // ────────────────────────────────────────────
  // الوضع التركي: شبكة خطوط متقاطعة
  // ────────────────────────────────────────────

  void _renderTurkish(ui.Canvas canvas) {
    final boardPx = tileSize * GameConstants.boardSize;
    final n = GameConstants.boardSize; // 8

    // ── 1. خلفية موحدة للوحة كاملة ─────────
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, boardPx, boardPx),
      _turkishBgPaint,
    );

    // ── 2. تظليل المربع المحدد (قبل الخطوط) ─
    if (_selectedPos != null) {
      final row = _selectedPos!.row;
      final col = _selectedPos!.col;
      final screenRow = n - 1 - row;
      final selRect = ui.Rect.fromLTWH(
        col * tileSize,
        screenRow * tileSize,
        tileSize,
        tileSize,
      );
      // ملء خلفية المربع المحدد
      canvas.drawRect(selRect, _selectedPaint);
    }

    // ── 3. رسم الخطوط الأفقية ───────────────
    for (var i = 0; i <= n; i++) {
      final y = i * tileSize;
      // الخطوط الحدودية (أول وآخر) تكون سميكة
      final isBoundary = i == 0 || i == n;
      // كل 4 خطوط تكون أثقل قليلاً للتقسيم البصري
      final isMid = i == n ~/ 2;
      final paint = (isBoundary || isMid)
          ? _turkishGridThickPaint
          : _turkishGridPaint;

      canvas.drawLine(
        ui.Offset(0, y),
        ui.Offset(boardPx, y),
        paint,
      );
    }

    // ── 4. رسم الخطوط العمودية ──────────────
    for (var i = 0; i <= n; i++) {
      final x = i * tileSize;
      final isBoundary = i == 0 || i == n;
      final isMid = i == n ~/ 2;
      final paint = (isBoundary || isMid)
          ? _turkishGridThickPaint
          : _turkishGridPaint;

      canvas.drawLine(
        ui.Offset(x, 0),
        ui.Offset(x, boardPx),
        paint,
      );
    }

    // ── 5. حدود المربع المحدد (فوق الخطوط) ──
    if (_selectedPos != null) {
      final row = _selectedPos!.row;
      final col = _selectedPos!.col;
      final screenRow = n - 1 - row;
      final selRect = ui.Rect.fromLTWH(
        col * tileSize + 1.5,
        screenRow * tileSize + 1.5,
        tileSize - 3.0,
        tileSize - 3.0,
      );
      canvas.drawRect(selRect, _turkishCellBorderPaint);
    }

    // ── 6. إطار خارجي سميك ──────────────────
    canvas.drawRect(
      ui.Rect.fromLTWH(0, 0, boardPx, boardPx),
      _borderOuterPaint,
    );
  }

  // ════════════════════════════════════════════
  // Helpers
  // ════════════════════════════════════════════

  bool _isSelected(int row, int col) =>
      _selectedPos != null &&
      _selectedPos!.row == row &&
      _selectedPos!.col == col;

  /// تحديث المربع المحدد — يُستدعى من CheckersGame
  void updateSelection(Position? pos) {
    _selectedPos = pos;
  }
}