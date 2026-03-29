// lib/features/games/checkers/presentation/flame/components/hint_component.dart
//
// نقاط الإشارة التي تظهر على المربعات التي يمكن الحركة إليها.
//
// الوضع الألماني: دائرة خضراء/حمراء داخل المربع الداكن
// الوضع التركي:  إطار مربع خضراء/حمراء يُحيط المربع بالكامل
//                (لأن كل المربعات فاتحة والدائرة لا تظهر جيداً)

import 'dart:ui' as ui;
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:flame/components.dart';
import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/presentation/flame/styles/game_colors.dart';

class HintComponent extends PositionComponent {
  final bool isCapture;
  final double tileSize;
  final GameVariant variant;

  late final ui.Paint _fillPaint;
  late final ui.Paint _strokePaint;
  late final ui.Paint _cornerPaint;

  HintComponent({
    required this.tileSize,
    required this.isCapture,
    required this.variant,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(tileSize),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final baseColor = isCapture ? GameColors.hintCapture : GameColors.hintNormal;
    final solidColor = isCapture
        ? const ui.Color(0xAACC2200)
        : const ui.Color(0xAA22CC00);

    _fillPaint = ui.Paint()
      ..color = baseColor
      ..style = ui.PaintingStyle.fill;

    _strokePaint = ui.Paint()
      ..color = solidColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = tileSize * 0.055;

    _cornerPaint = ui.Paint()
      ..color = solidColor
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = tileSize * 0.07
      ..strokeCap = ui.StrokeCap.square;
  }

  @override
  void render(ui.Canvas canvas) {
    if (variant == GameVariant.german) {
      _renderGermanHint(canvas);
    } else {
      _renderTurkishHint(canvas);
    }
  }

  // ── الوضع الألماني: دائرة داخل المربع ──────────────

  void _renderGermanHint(ui.Canvas canvas) {
    final radius = tileSize * GameConstants.hintRadiusRatio;
    final center = ui.Offset(tileSize / 2, tileSize / 2);

    // ظل خارجي خفيف
    canvas.drawCircle(
      center,
      radius + tileSize * 0.03,
      ui.Paint()
        ..color = _fillPaint.color.withOpacity(0.15)
        ..style = ui.PaintingStyle.fill,
    );

    // دائرة مملوءة
    canvas.drawCircle(center, radius, _fillPaint);

    // حلقة خارجية واضحة
    canvas.drawCircle(center, radius - tileSize * 0.01, _strokePaint);
  }

  // ── الوضع التركي: إطار بزوايا L يُحيط المربع ──────

  void _renderTurkishHint(ui.Canvas canvas) {
    final padding = tileSize * 0.10;
    final cornerLen = tileSize * 0.28; // طول ذراع الزاوية
    final p = padding;
    final cl = cornerLen;
    final s = tileSize;

    // ملء شفاف للمربع بالكامل
    canvas.drawRect(
      ui.Rect.fromLTWH(p, p, s - p * 2, s - p * 2),
      _fillPaint,
    );

    // رسم 4 زوايا بشكل L
    // زاوية أعلى يسار
    _drawCorner(canvas, p, p, 1, 1, cl);
    // زاوية أعلى يمين
    _drawCorner(canvas, s - p, p, -1, 1, cl);
    // زاوية أسفل يسار
    _drawCorner(canvas, p, s - p, 1, -1, cl);
    // زاوية أسفل يمين
    _drawCorner(canvas, s - p, s - p, -1, -1, cl);
  }

  /// يرسم زاوية L في نقطة (x,y) بإتجاه (dx,dy)
  void _drawCorner(
    ui.Canvas canvas,
    double x,
    double y,
    double dx,
    double dy,
    double len,
  ) {
    // خط أفقي
    canvas.drawLine(
      ui.Offset(x, y),
      ui.Offset(x + dx * len, y),
      _cornerPaint,
    );
    // خط عمودي
    canvas.drawLine(
      ui.Offset(x, y),
      ui.Offset(x, y + dy * len),
      _cornerPaint,
    );
  }
}