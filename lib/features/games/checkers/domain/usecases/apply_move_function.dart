// lib/features/games/checkers/domain/usecases/apply_move_function.dart
//
// تنفيذ الحركة على اللوحة — تُعيد لوحة جديدة بعد الحركة

import 'package:checkers/core/utils/board_cloner.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

class ApplyMoveFunction {
  /// تُطبّق [move] على [board] وتُعيد لوحة جديدة (بدون تعديل الأصل)
  BoardState call(BoardState board, MoveModel move, PieceColor playerColor) {
    final newGrid = cloneBoard(board.grid);

    final from = move.from;
    final to = move.to;

    // احصل على القطعة
    final piece = newGrid[from.row][from.col]!;
    if (piece == null) return board;

    // احذف القطعة من موضعها
    newGrid[from.row][from.col] = null;

    // احذف القطع المأكولة
    for (final cap in move.captured) {
      newGrid[cap.row][cap.col] = null;
    }

    bool shouldBeKing = piece.isKing;
    final int promotionRow = (piece.color == playerColor) ? 7 : 0;

    if (promotionRow == to.row) {
      shouldBeKing = true;
    }

    // 5. وضع القطعة في المربع الجديد (مع تحديث حالتها كملك إذا لزم الأمر)
    newGrid[to.row][to.col] = piece.copyWith(
      row: to.row,
      col: to.col,
      isKing: shouldBeKing,
    );

    return BoardState(grid: newGrid, variant: board.variant, size: board.size);
  }

  /// تحقق من ترقية القطعة إلى ملك
}
