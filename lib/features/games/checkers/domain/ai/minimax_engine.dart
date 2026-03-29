// lib/features/games/checkers/domain/ai/minimax_engine.dart
//
// خوارزمية Minimax مع Alpha-Beta Pruning
//
// المبدأ (كما في المخطط):
// - الـ AI لا يحرك القطع مباشرة، بل يُعيد "أفضل حركة" وجدها
// - الـ Manager هو من يُرسلها للـ Flame لتحريك القطعة بصرياً
// - الأسود = Maximizer (AI) — يريد تعظيم التقييم
// - الأبيض = Minimizer (اللاعب) — يريد تصغير التقييم

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

  /// يُعيد أفضل حركة للـ AI (الأسود) — لا يُحرّك القطع
  MoveModel? getBestMove(BoardState board, PieceColor currentTurn) {
    final moves = _moveCalc(board, PieceColor.black);
    if (moves.isEmpty) return null;
    if (moves.length == 1) return moves.first;

    MoveModel? best;
    var bestScore = -999999;

    for (final move in moves) {
      final newBoard = _applyMove(board, move);
      final score = _minimax(
        newBoard,
        GameConstants.minimaxDepth - 1,
        -999999,
        999999,
        false, // المرحلة التالية: دور الأبيض (minimizer)
      );
      if (score > bestScore ||
          (score == bestScore && _random.nextBool())) {
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
  ) {
    final color = isMaximizing ? PieceColor.black : PieceColor.white;
    final moves = _moveCalc(board, color);

    // حالة نهائية: لا حركات أو وصلنا للعمق الأقصى
    if (depth == 0 || moves.isEmpty) {
      return _evaluator(board);
    }

    if (isMaximizing) {
      var maxEval = -999999;
      for (final move in moves) {
        final newBoard = _applyMove(board, move);
        final eval = _minimax(newBoard, depth - 1, alpha, beta, false);
        if (eval > maxEval) maxEval = eval;
        if (eval > alpha) alpha = eval;
        if (beta <= alpha) break; // Alpha-Beta Pruning
      }
      return maxEval;
    } else {
      var minEval = 999999;
      for (final move in moves) {
        final newBoard = _applyMove(board, move);
        final eval = _minimax(newBoard, depth - 1, alpha, beta, true);
        if (eval < minEval) minEval = eval;
        if (eval < beta) beta = eval;
        if (beta <= alpha) break; // Alpha-Beta Pruning
      }
      return minEval;
    }
  }
}