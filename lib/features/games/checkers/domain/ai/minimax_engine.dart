// lib/features/games/checkers/domain/ai/minimax_engine.dart

import 'dart:math';
import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/features/games/checkers/domain/ai/evaluator_logic.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:checkers/features/games/checkers/domain/usecases/apply_move_function.dart';
import 'package:checkers/features/games/checkers/domain/usecases/calculate_available_moves.dart';

class MinimaxEngine {
  final CalculateAvailableMoves _moveCalc;
  final ApplyMoveFunction _applyMove;
  final EvaluatorLogic _evaluator;
  final _random = Random();

  MinimaxEngine({
    CalculateAvailableMoves? moveCalc,
    ApplyMoveFunction? applyMove,
    EvaluatorLogic? evaluator,
  })  : _moveCalc = moveCalc ?? CalculateAvailableMoves(),
        _applyMove = applyMove ?? ApplyMoveFunction(),
        _evaluator = evaluator ?? EvaluatorLogic();

  /// التعديل: نمرر لون الـ AI ولون اللاعب (الذي في الأسفل)
  MoveModel? getBestMove(BoardState board, PieceColor aiColor, PieceColor playerColor) {
    // حساب الحركات المتاحة للـ AI بناءً على موقعه في اللوحة
    final moves = _moveCalc(board, aiColor, playerColor);
    
    if (moves.isEmpty) return null;
    if (moves.length == 1) return moves.first;

    MoveModel? best;
    var bestScore = -999999;

    for (final move in moves) {
      final newBoard = _applyMove(board, move, playerColor);
      final score = _minimax(
        newBoard,
        GameConstants.minimaxDepth - 1,
        -999999,
        999999,
        false, // الدور القادم للاعب (Minimizer)
        aiColor,
        playerColor,
      );

      if (score > bestScore || (score == bestScore && _random.nextBool())) {
        bestScore = score;
        best = move;
      }
    }

    return best;
  }

  int _minimax(
    BoardState board,
    int depth,
    int alpha,
    int beta,
    bool isMaximizing,
    PieceColor aiColor,
    PieceColor playerColor,
  ) {
    // تحديد اللون الحالي بناءً على من هو الـ Maximizer
    final currentColor = isMaximizing ? aiColor : playerColor;
    final moves = _moveCalc(board, currentColor, playerColor);

    // حالة نهائية: لا حركات أو وصلنا للعمق الأقصى
    if (depth == 0 || moves.isEmpty) {
      // المقيم (Evaluator) يحتاج لمعرفة من هو اللاعب الذي في الأسفل لحساب "التقدم"
      return _evaluator(board, aiColor);
    }

    if (isMaximizing) {
      var maxEval = -999999;
      for (final move in moves) {
        final newBoard = _applyMove(board, move, playerColor);
        final eval = _minimax(newBoard, depth - 1, alpha, beta, false, aiColor, playerColor);
        if (eval > maxEval) maxEval = eval;
        if (eval > alpha) alpha = eval;
        if (beta <= alpha) break; // Alpha-Beta Pruning
      }
      return maxEval;
    } else {
      var minEval = 999999;
      for (final move in moves) {
        final newBoard = _applyMove(board, move, playerColor);
        final eval = _minimax(newBoard, depth - 1, alpha, beta, true, aiColor, playerColor);
        if (eval < minEval) minEval = eval;
        if (eval < beta) beta = eval;
        if (beta <= alpha) break; // Alpha-Beta Pruning
      }
      return minEval;
    }
  }
}