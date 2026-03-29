// lib/features/games/checkers/presentation/flame/components/piece_component.dart
//
// المكوّن البصري للقطعة داخل Flame.
// يرث من PositionComponent وينفّذ:
//   - رسم القطعة (عادية / داما)
//   - أنيميشن الانزلاق (MoveEffect)
//   - أنيميشن الموت (تأثير الكسر/التلاشي)

import 'dart:math' as math;
import 'dart:ui';
import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:checkers/features/games/checkers/presentation/flame/styles/game_colors.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';

import 'dart:ui' as ui;



class PieceComponent extends PositionComponent {
  final PieceModel model;
  final double tileSize;

  bool _dying = false;
  double _deathProgress = 0.0; // 0..1

  // الـ Paint objects (مُعرَّفة مرة واحدة لتفادي إنشائها في كل frame)
  late final ui.Paint _fillPaint;
  late final ui.Paint _strokePaint;
  late final ui.Paint _shadePaint;
  late final ui.Paint _crownPaint;
  late final ui.Paint _crownStrokePaint;

  PieceComponent({
    required this.model,
    required this.tileSize,
    required Vector2 position,
  }) : super(
          position: position,
          size: Vector2.all(tileSize),
          anchor: Anchor.topLeft,
        );

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _initPaints();
  }

  void _initPaints() {
    final isWhite = model.color == PieceColor.white;

    _fillPaint = ui.Paint()
      ..color = isWhite ? GameColors.whitePiece : GameColors.blackPiece
      ..style = ui.PaintingStyle.fill;

    _strokePaint = ui.Paint()
      ..color = isWhite ? GameColors.whitePieceStroke : GameColors.blackPieceStroke
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = tileSize * 0.035;

    _shadePaint = ui.Paint()
      ..color = isWhite ? GameColors.whitePieceShade : GameColors.blackPieceShade
      ..style = ui.PaintingStyle.fill;

    _crownPaint = ui.Paint()
      ..color = GameColors.crownGold
      ..style = ui.PaintingStyle.fill;

    _crownStrokePaint = ui.Paint()
      ..color = GameColors.crownGoldStroke
      ..style = ui.PaintingStyle.stroke
      ..strokeWidth = tileSize * 0.025;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_dying) {
      _deathProgress += dt / GameConstants.deathAnimationDuration;
      if (_deathProgress >= 1.0) {
        removeFromParent();
      }
    }
  }

  @override
  void render(ui.Canvas canvas) {
    if (_dying) {
      // أنيميشن الموت: تلاشٍ + تصغير
      canvas.save();
      final center = Offset(tileSize / 2, tileSize / 2);
      final scale = 1.0 - _deathProgress;
      canvas.translate(center.dx, center.dy);
      canvas.scale(scale);
      canvas.translate(-center.dx, -center.dy);
      final opacity = (1.0 - _deathProgress).clamp(0.0, 1.0);
      _fillPaint.color = _fillPaint.color.withOpacity(opacity);
      _drawPiece(canvas);
      canvas.restore();
      return;
    }
    _drawPiece(canvas);
  }

  void _drawPiece(ui.Canvas canvas) {
    final radius = tileSize * GameConstants.pieceRadiusRatio;
    final center = Offset(tileSize / 2, tileSize / 2);

    // ظل خفيف
    canvas.drawCircle(
      center.translate(radius * 0.08, radius * 0.08),
      radius,
      _shadePaint,
    );

    // جسم القطعة
    canvas.drawCircle(center, radius, _fillPaint);

    // حدود القطعة
    canvas.drawCircle(center, radius, _strokePaint);

    // تأثير لمعان داخلي
    final gloss = ui.Paint()
      ..shader = ui.Gradient.radial(
        center.translate(-radius * 0.2, -radius * 0.2),
        radius * 0.6,
        [
          const ui.Color(0x33FFFFFF),
          const ui.Color(0x00FFFFFF),
        ],
      );
    canvas.drawCircle(center, radius, gloss);

    // رسم التاج إذا كانت قطعة داما
    if (model.isKing) {
      _drawCrown(canvas, center, radius);
    }
  }

  void _drawCrown(ui.Canvas canvas, Offset center, double pieceRadius) {
    final cr = pieceRadius * GameConstants.crownRadiusRatio;
    final path = ui.Path();
    // رسم تاج بسيط من 5 نقاط
    const points = 5;
    final outerR = cr;
    final innerR = cr * 0.55;

    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r = i.isEven ? outerR : innerR;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, _crownPaint);
    canvas.drawPath(path, _crownStrokePaint);
  }

  // ══════════════════════════
  // Public API
  // ══════════════════════════

  /// تحريك القطعة بأنيميشن انزلاق نحو [targetPosition]
  void moveTo(Vector2 targetPosition, {VoidCallback? onComplete}) {
    add(
      MoveToEffect(
        targetPosition,
        EffectController(duration: GameConstants.moveAnimationDuration),
        onComplete: onComplete,
      ),
    );
  }

  /// تشغيل تأثير الموت (كسر + تلاشٍ)
  void playDeathAnimation() {
    _dying = true;
  }

  /// ترقية القطعة إلى ملك (تأثير بصري + تحديث النموذج)
  void promoteToKing() {
    // إعادة التهيئة بالنموذج الجديد — نستدعي هذا من CheckersGame
    // لا حاجة لنموذج جديد هنا: نُغيّر فقط رسم التاج
    // (الـ CheckersGame يستبدل PieceComponent عند الترقية)
  }
}

typedef VoidCallback = void Function();