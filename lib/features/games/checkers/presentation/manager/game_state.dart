// lib/features/games/checkers/presentation/manager/game_state.dart

import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

/// مرحلة اللعبة الحالية
enum GamePhase {
  playing,     // جارية
  aiThinking,  // الذكاء الاصطناعي يفكر
  animating,   // يُشغّل أنيميشن
  gameOver,    // انتهت
}

/// نتيجة اللعبة
enum GameResult {
  playerWin,  // اللاعب فاز
  aiWin,      // الذكاء الاصطناعي فاز
  draw,       // تعادل
}


/// حالة اللعبة الكاملة — تُخزّن في الـ GameController
class GameState {
  final BoardState board;
  final PieceColor currentTurn;       // من يلعب الآن
  final GamePhase phase;
  final GameResult? result;            // نتيجة اللعبة (عند الانتهاء)
  final Position? selectedPiece;       // القطعة المحددة من اللاعب
  final List<MoveModel> validMoves;    // الحركات المتاحة للقطعة المحددة
  final int whiteCaptured;             // عدد قطع الأبيض المأكولة
  final int blackCaptured;             // عدد قطع الأسود المأكولة
  final GameVariant variant;
  final PieceColor playerColor;        // لون اللاعب البشري (عادةً أبيض)

  const GameState({
    required this.board,
    required this.currentTurn,
    required this.phase,
    required this.variant,
    this.result,
    this.selectedPiece,
    this.validMoves = const [],
    this.whiteCaptured = 0,
    this.blackCaptured = 0,
    this.playerColor = PieceColor.white,
  });

  bool get isPlayerTurn => currentTurn == playerColor && phase == GamePhase.playing;
  bool get isAiTurn => currentTurn != playerColor;
  bool get isGameOver => phase == GamePhase.gameOver;

  // ═══════════════════════════════════════════════════════
  // copyWith - دالة نسخ الحالة مع تعديلات
  // ═══════════════════════════════════════════════════════
  GameState copyWith({
    BoardState? board,
    PieceColor? currentTurn,
    GamePhase? phase,
    GameResult? result,
    Position? selectedPiece,
    bool clearSelection = false,
    List<MoveModel>? validMoves,
    int? whiteCaptured,
    int? blackCaptured,
    GameVariant? variant,
    PieceColor? playerColor,
  }) {
    return GameState(
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      phase: phase ?? this.phase,
      result: result ?? this.result,
      selectedPiece: clearSelection ? null : (selectedPiece ?? this.selectedPiece),
      validMoves: validMoves ?? this.validMoves,
      whiteCaptured: whiteCaptured ?? this.whiteCaptured,
      blackCaptured: blackCaptured ?? this.blackCaptured,
      variant: variant ?? this.variant,
      playerColor: playerColor ?? this.playerColor,
    );
  }

  // ═══════════════════════════════════════════════════════
  // factory GameState.initial - المُنشئ الأولي
  // ═══════════════════════════════════════════════════════
  factory GameState.initial(GameVariant variant, PieceColor playerColor) {
    final board = BoardState.initial(variant);
    
    // ═══════════════════════════════════════════════════════
    // الإصلاح: تحديد من يبدأ بناءً على قواعد المتغير
    // قواعد الألماني/التركي: الأبيض يتحرك دائمًا أولاً
    // لكننا نحتاج لتتبع دور من يكون بشكل صحيح
    // ═══════════════════════════════════════════════════════
    
    return GameState(
      board: board,
      variant: variant,
      playerColor: playerColor,
      // الأبيض يبدأ دائمًا في كل من الداما الألمانية والتركية
      currentTurn: PieceColor.white, 
      selectedPiece: null,
      validMoves: [],
      phase: playerColor == PieceColor.white 
          ? GamePhase.playing      // دور اللاعب (أبيض)
          : GamePhase.aiThinking,  // دور الذكاء الاصطناعي (أبيض)، AI يلعب أولاً
      whiteCaptured: 0,
      blackCaptured: 0,
      result: null,
    );
  }
}