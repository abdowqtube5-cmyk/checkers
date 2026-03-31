// lib/features/games/checkers/manager/game_controller.dart
//
// الـ Manager — الجسر بين Domain (المنطق) و Flame (العرض البصري)

import 'dart:async';

import 'package:checkers/features/games/checkers/domain/ai/minimax_engine.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:checkers/features/games/checkers/domain/usecases/apply_move_function.dart';
import 'package:checkers/features/games/checkers/domain/usecases/calculate_available_moves.dart';
import 'package:checkers/features/games/checkers/presentation/manager/game_state.dart';
import 'package:get/get.dart';

class GameController extends GetxController {
  // ══════════════════════════════
  // Dependencies (Domain layer)
  // ══════════════════════════════
  final CalculateAvailableMoves _moveCalc = CalculateAvailableMoves();
  final ApplyMoveFunction _applyMove = ApplyMoveFunction();
  final MinimaxEngine _minimax = MinimaxEngine();

  // ══════════════════════════════
  // Reactive State
  // ══════════════════════════════
  final Rx<GameState> stateRx = Rx<GameState>(GameState.initial(GameVariant.german, PieceColor.white));
  GameState get state => stateRx.value;

  /// Callback — يستدعيه Controller ليُخبر Flame بأنيميشن حركة
  void Function(MoveModel move, bool isAi)? onAnimateMove;

  /// Callback — عند الانتهاء من الأنيميشن يُخبر Controller
  void animationCompleted() => _onAnimationComplete();

  // ══════════════════════════════
  // Private state tracking
  // ══════════════════════════════
  MoveModel? _lastAppliedMove;
  
  // ═══════════════════════════════════════════════════════
  // إضافة: تتبع من كان يلعب قبل الأنيميشن
  // ═══════════════════════════════════════════════════════
  bool _lastMoveWasAi = false;

  // ══════════════════════════════
  // Public API — called from Flame
  // ══════════════════════════════

  /// اللاعب ضغط على مربع (row, col)
  void handleTap(int row, int col) {
    if (!state.isPlayerTurn) return;

    final board = state.board;
    final piece = board.get(row, col);
    final selected = state.selectedPiece;

    // ────────────────────────────────────
    // الحالة 1: ضغط على قطعة من نفس اللون → اختيارها
    // ────────────────────────────────────
    if (piece != null && piece.color == state.playerColor) {
      _selectPiece(row, col, piece);
      return;
    }

    // ────────────────────────────────────
    // الحالة 2: قطعة محددة + ضغط على مربع وجهة
    // ────────────────────────────────────
    if (selected != null) {
      final move = _findMove(selected, row, col);
      if (move != null) {
        _executePlayerMove(move);
        return;
      }
    }

    // ────────────────────────────────────
    // الحالة 3: ضغط على مكان فارغ → إلغاء الاختيار
    // ────────────────────────────────────
    _clearSelection();
  }

  /// ابدأ لعبة جديدة
void startGame(GameVariant variant, PieceColor playerColor) {
    // تأكد أن initial تضع الدور دائماً للأبيض
    stateRx.value = GameState.initial(variant, playerColor).copyWith(
      blackCaptured: 0,
      whiteCaptured: 0,
    );
    
    _lastAppliedMove = null;
    _lastMoveWasAi = false;
    
    // إذا كان اللاعب أسود، يعني الأبيض (AI) هو من يبدأ
    if (playerColor == PieceColor.black) {
      // ننتظر قليلاً للتأكد من بناء الواجهة ثم نطلب من الـ AI التحرك
      Future.delayed(const Duration(milliseconds: 500), () {
        _triggerAi(state.board);
      });
    }
  }

  /// استسلام اللاعب
  void resign() {
    stateRx.value = state.copyWith(
      phase: GamePhase.gameOver,
      result: GameResult.aiWin,
    );
  }

  // ══════════════════════════════
  // Private helpers
  // ══════════════════════════════

  void _selectPiece(int row, int col, PieceModel piece) {
    final validMoves = _moveCalc.forPiece(state.board, piece, state.playerColor);
    stateRx.value = state.copyWith(
      selectedPiece: Position(row, col),
      validMoves: validMoves,
    );
  }

  void _clearSelection() {
    stateRx.value = state.copyWith(clearSelection: true);
  }

  MoveModel? _findMove(Position from, int toRow, int toCol) {
    return state.validMoves.firstWhereOrNull(
      (m) => m.from == from && m.to == Position(toRow, toCol),
    );
  }

  void _executePlayerMove(MoveModel move) {
    // ═══════════════════════════════════════════════════════
    // إضافة: تسجيل أن اللاعب هو من يلعب
    // ═══════════════════════════════════════════════════════
    _lastMoveWasAi = false;
    
    // تسجيل الحركة قبل الأنيميشن
    registerMove(move);
    
    stateRx.value = state.copyWith(
      phase: GamePhase.animating,
      clearSelection: true,
    );

    // أخبر Flame بتشغيل الأنيميشن
    onAnimateMove?.call(move, false);
  }

  void _onAnimationComplete() {
    // ═══════════════════════════════════════════════════════
    // إصلاح: استخدم المتغير بدلاً من التحقق من الحالة الحالية
    // ═══════════════════════════════════════════════════════
    if (_lastMoveWasAi) {
      _applyAiMove();
    } else {
      _applyPlayerMove();
    }
  }

void _applyPlayerMove() {
    final lastMove = _lastAppliedMove;
    if (lastMove == null) return;

    final newBoard = _applyMove(state.board, lastMove, state.playerColor);
    final captured = lastMove.captureCount;

    // المنطق الصحيح: إذا أكل اللاعب قطعاً، نزيد عداد اللون الذي "أُكل"
    // الخصم هو عكس لون اللاعب
    final opponentColor = _opponent(state.playerColor);

    stateRx.value = state.copyWith(
      board: newBoard,
      currentTurn: _opponent(state.currentTurn),
      phase: GamePhase.aiThinking,
      // إذا كان الخصم أسود نزيد blackCaptured، وإذا كان أبيض نزيد whiteCaptured
      blackCaptured: opponentColor == PieceColor.black 
          ? state.blackCaptured + captured 
          : state.blackCaptured,
      whiteCaptured: opponentColor == PieceColor.white 
          ? state.whiteCaptured + captured 
          : state.whiteCaptured,
    );

    _checkGameOver(newBoard);
    if (!state.isGameOver) _triggerAi(newBoard);
  }

  void _applyAiMove() {
    final lastMove = _lastAppliedMove;
    if (lastMove == null) return;

    final newBoard = _applyMove(state.board, lastMove, state.playerColor
    );
    final captured = lastMove.captureCount;

    // هنا الـ AI أكل قطع اللاعب
    final playerColor = state.playerColor;

    stateRx.value = state.copyWith(
      board: newBoard,
      currentTurn: state.playerColor,
      phase: GamePhase.playing,
      // نزيد عداد لون اللاعب لأنه هو من خسر قطعاً
      blackCaptured: playerColor == PieceColor.black 
          ? state.blackCaptured + captured 
          : state.blackCaptured,
      whiteCaptured: playerColor == PieceColor.white 
          ? state.whiteCaptured + captured 
          : state.whiteCaptured,
    );

    _checkGameOver(newBoard);
  }

  /// يُستدعى من Flame قبل تشغيل الأنيميشن لتخزين الحركة
  void registerMove(MoveModel move) {
    _lastAppliedMove = move;
  }

  void _triggerAi(BoardState board) {
    // ═══════════════════════════════════════════════════════
    // إضافة: تحديث الحالة إلى "الذكاء يفكر" فوراً
    // ═══════════════════════════════════════════════════════
    stateRx.value = state.copyWith(phase: GamePhase.aiThinking);
    
    // نشغّل Minimax بشكل غير متزامن لعدم تجميد الواجهة
    Future.microtask(() async {
      // انتظر قليلاً ليشعر اللاعب أن AI يفكر
      await Future.delayed(const Duration(milliseconds: 800));
      
      // ═══════════════════════════════════════════════════════
      // إصلاح: تمرير لون AI كمعامل ثاني
      // ═══════════════════════════════════════════════════════
      final aiColor = state.currentTurn;
      final bestMove = _minimax.getBestMove(board, aiColor, state.playerColor);
      
      if (bestMove == null) {
        // لا حركات للـ AI → اللاعب فاز
        stateRx.value = state.copyWith(
          phase: GamePhase.gameOver,
          result: GameResult.playerWin,
        );
        return;
      }
      
      // ═══════════════════════════════════════════════════════
      // إضافة: تسجيل أن AI هو من يلعب
      // ═══════════════════════════════════════════════════════
      _lastMoveWasAi = true;
      
      // تسجيل الحركة قبل الأنيميشن
      registerMove(bestMove);
      
      // نبدأ الأنيميشن للـ AI
      stateRx.value = state.copyWith(phase: GamePhase.animating);
      onAnimateMove?.call(bestMove, true);
    });
  }

  void _checkGameOver(BoardState board) {
    final whitePieces = board.piecesOf(PieceColor.white);
    final blackPieces = board.piecesOf(PieceColor.black);

    // كل القطع فُقدت
    if (whitePieces.isEmpty) {
      stateRx.value = state.copyWith(
        phase: GamePhase.gameOver,
        result: GameResult.aiWin,
      );
      return;
    }
    if (blackPieces.isEmpty) {
      stateRx.value = state.copyWith(
        phase: GamePhase.gameOver,
        result: GameResult.playerWin,
      );
      return;
    }

    // تعادل: كلاهما لديه ملك واحد فقط
    if (whitePieces.length == 1 &&
        blackPieces.length == 1 &&
        whitePieces.first.isKing &&
        blackPieces.first.isKing) {
      stateRx.value = state.copyWith(
        phase: GamePhase.gameOver,
        result: GameResult.draw,
      );
      return;
    }

    // لا حركات للاعب الحالي → الطرف الآخر يفوز
    final nextColor = _opponent(state.currentTurn);
    final moves = _moveCalc(board, nextColor, state.playerColor);
    if (moves.isEmpty) {
      final result = nextColor == state.playerColor
          ? GameResult.aiWin
          : GameResult.playerWin;
      stateRx.value = state.copyWith(
        phase: GamePhase.gameOver,
        result: result,
      );
    }
  }

  PieceColor _opponent(PieceColor color) =>
      color == PieceColor.white ? PieceColor.black : PieceColor.white;
}