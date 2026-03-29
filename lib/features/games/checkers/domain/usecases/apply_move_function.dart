// lib/features/games/checkers/domain/usecases/apply_move_function.dart
//
// تنفيذ الحركة على اللوحة — تُعيد لوحة جديدة بعد الحركة

import 'package:checkers/core/utils/board_cloner.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

class ApplyMoveFunction {
  /// تُطبّق [move] على [board] وتُعيد لوحة جديدة (بدون تعديل الأصل)
  BoardState call(BoardState board, MoveModel move) {
    final newGrid = cloneBoard(board.grid);

    final from = move.from;
    final to = move.to;

    // احصل على القطعة
    final piece = newGrid[from.row][from.col]!;

    // احذف القطعة من موضعها
    newGrid[from.row][from.col] = null;

    // احذف القطع المأكولة
    for (final cap in move.captured) {
      newGrid[cap.row][cap.col] = null;
    }

    // هل يجب ترقية القطعة إلى ملك؟
    final promoted = _shouldPromote(piece, to, board.size);

    // ضع القطعة في موضعها الجديد
    newGrid[to.row][to.col] = PieceModel(
      row: to.row,
      col: to.col,
      color: piece.color,
      isKing: promoted || piece.isKing,
    );

    return BoardState(grid: newGrid, variant: board.variant, size: board.size);
  }

  /// تحقق من ترقية القطعة إلى ملك
  bool _shouldPromote(PieceModel piece, Position to, int boardSize) {
    if (piece.isKing) return false;
    if (piece.color == PieceColor.white && to.row == boardSize - 1) return true;
    if (piece.color == PieceColor.black && to.row == 0) return true;
    return false;
  }
}