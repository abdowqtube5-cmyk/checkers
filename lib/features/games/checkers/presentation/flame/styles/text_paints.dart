// lib/features/games/checkers/presentation/flame/styles/text_paints.dart

import 'package:flutter/material.dart'; // استخدم هذا بدلاً من dart:ui
import 'package:flame/components.dart';

class GameTextPaints {
  GameTextPaints._();

  /// نص الأرقام على حواف اللوحة
  static final boardLabel = TextPaint(
    style: const TextStyle( // لا نحتاج بادئة ui. هنا
      fontSize: 12,
      color: Color(0xFFBCAAA4),
      fontWeight: FontWeight.w500,
    ),
  );

  /// نص كبير (مثل عداد القطع)
  static final scoreLabel = TextPaint(
    style: const TextStyle(
      fontSize: 20,
      color: Color(0xFFFFF8E1),
      fontWeight: FontWeight.bold,
    ),
  );
}