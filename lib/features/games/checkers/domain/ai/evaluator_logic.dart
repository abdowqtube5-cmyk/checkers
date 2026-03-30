// lib/features/games/checkers/domain/ai/evaluator_logic.dart
//
// دالة تقييم حالة اللوحة للـ Minimax.
// القيمة الموجبة = جيد للأسود (AI)
// القيمة السالبة = جيد للأبيض (اللاعب)

import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

class EvaluatorLogic {
  /// قيّم اللوحة من منظور الذكاء الاصطناعي بناءً على لونه
  int call(BoardState board, PieceColor aiColor) {
    var score = 0;

    for (var r = 0; r < board.size; r++) {
      for (var c = 0; c < board.size; c++) {
        final piece = board.get(r, c);
        if (piece == null) continue;

        final baseValue = piece.isKing
            ? GameConstants.kingPieceValue
            : GameConstants.regularPieceValue;

        final centerBonus = _centerBonus(r, c, board.size);
        final advanceBonus = _advanceBonus(piece, r, board.size);
        final pieceScore = baseValue + centerBonus + advanceBonus;

        // التعديل هنا: إذا كانت القطعة تابعة للكمبيوتر نزيد النقاط، وإلا ننقصها
        if (piece.color == aiColor) {
          score += pieceScore;
        } else {
          score -= pieceScore;
        }
      }
    }

    return score;
  }

  int _centerBonus(int row, int col, int size) {
    final midRow = (size - 1) / 2;
    final midCol = (size - 1) / 2;
    final distRow = (row - midRow).abs();
    final distCol = (col - midCol).abs();
    // كلما قرب من المركز كلما زادت المكافأة
    final maxDist = midRow + midCol;
    return ((maxDist - distRow - distCol) / maxDist * 3).round();
  }

  int _advanceBonus(PieceModel piece, int row, int size) {
    if (piece.isKing) return 0; // الداما لا تحتاج مكافأة تقدم
    if (piece.color == PieceColor.white) {
      // أبيض يتقدم نحو الصفوف العالية
      return (row / size * 4).round();
    } else {
      // أسود يتقدم نحو الصفوف المنخفضة
      return ((size - 1 - row) / size * 4).round();
    }
  }
}