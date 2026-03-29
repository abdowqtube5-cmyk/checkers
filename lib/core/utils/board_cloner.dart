// lib/core/utils/board_cloner.dart
//
// النسخ العميق للوحة — ضروري لخوارزمية Minimax لتجربة الحركات
// الـ PieceModel غير قابل للتغيير (immutable) لذا يكفي نسخ القوائم

import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

/// نسخة عميقة من مصفوفة اللوحة
List<List<PieceModel?>> cloneBoard(List<List<PieceModel?>> board) {
  return board.map((row) => List<PieceModel?>.from(row)).toList();
}