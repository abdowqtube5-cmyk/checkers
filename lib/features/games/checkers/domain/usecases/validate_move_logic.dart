// lib/features/games/checkers/domain/usecases/validate_move_logic.dart
//
// التحقق من صحة الحركة قبل التنفيذ

import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:checkers/features/games/checkers/domain/usecases/calculate_available_moves.dart';

class ValidateMoveLogic {
  final CalculateAvailableMoves _calculator;

  ValidateMoveLogic({CalculateAvailableMoves? calculator})
      : _calculator = calculator ?? CalculateAvailableMoves();

  /// هل الحركة [move] صالحة للقطعة [color] على اللوحة [board]؟
  bool call(BoardState board, MoveModel move, PieceColor color) {
    final piece = board.get(move.from.row, move.from.col);
    if (piece == null || piece.color != color) return false;

    final validMoves = _calculator.forPiece(board, piece, color);
    return validMoves.any(
      (m) => m.from == move.from && m.to == move.to,
    );
  }
}