import 'package:checkers/features/games/checkers/presentation/manager/game_controller.dart';
import 'package:checkers/features/games/checkers/presentation/manager/game_state.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:get/get.dart';

import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/core/utils/coordinate_converter.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

import 'package:checkers/features/games/checkers/presentation/flame/components/board_component.dart';
import 'package:checkers/features/games/checkers/presentation/flame/components/hint_component.dart';
import 'package:checkers/features/games/checkers/presentation/flame/components/piece_component.dart';

class CheckersGame extends FlameGame with TapCallbacks {
  final GameController _controller = Get.find<GameController>();

  late CoordinateConverter _coords;
  late BoardComponent _boardComponent;

  final Map<String, PieceComponent> _pieceMap = {};
  final List<HintComponent> _hints = [];

  double get _tileSize => _coords.tileSize;

  // lib/features/games/checkers/presentation/flame/checkers_game.dart

// استبدل onLoad بهذا:

@override
Future<void> onLoad() async {
  await super.onLoad();

  final tileSize = (size.x < size.y ? size.x : size.y) / GameConstants.boardSize;
  final boardPx = tileSize * GameConstants.boardSize;
  final boardLeft = (size.x - boardPx) / 2;
  final boardTop = (size.y - boardPx) / 2;

  _coords = CoordinateConverter(
    tileSize: tileSize,
    boardLeft: boardLeft,
    boardTop: boardTop,
  );

  _boardComponent = BoardComponent(
    tileSize: tileSize,
    variant: _controller.state.variant,
    position: Vector2(boardLeft, boardTop),
  );
  add(_boardComponent);

  // ═══════════════════════════════════════════════════════
  // DEBUG: طباعة حالة اللعبة قبل بناء القطع
  // ═══════════════════════════════════════════════════════
  final state = _controller.state;
  print('=== CHECKERS GAME START ===');
  print('variant: ${state.variant}');
  print('playerColor: ${state.playerColor}');
  print('currentTurn: ${state.currentTurn}');
  print('isPlayerTurn: ${state.isPlayerTurn}');
  print('isAiTurn: ${state.isAiTurn}');
  
  final whitePieces = state.board.piecesOf(PieceColor.white);
  final blackPieces = state.board.piecesOf(PieceColor.black);
  print('White pieces: ${whitePieces.length}');
  print('Black pieces: ${blackPieces.length}');
  
  for (final p in whitePieces) {
    print('  White at (${p.row},${p.col})');
  }
  for (final p in blackPieces) {
    print('  Black at (${p.row},${p.col})');
  }

  _buildPiecesFromBoard(_controller.state.board);

  _controller.onAnimateMove = _handleAnimateMove;
  ever(_controller.stateRx, _onStateChanged);
}

  void _buildPiecesFromBoard(BoardState board) {
    _pieceMap.clear(); // تنظيف الخريطة قبل البناء
    for (var row = 0; row < board.size; row++) {
      for (var col = 0; col < board.size; col++) {
        final piece = board.get(row, col);
        if (piece != null) _addPieceComponent(piece);
      }
    }
  }

  void _addPieceComponent(PieceModel piece) {
    final pos = Vector2(_coords.colToX(piece.col), _coords.rowToY(piece.row));
    final comp = PieceComponent(model: piece, tileSize: _tileSize, position: pos);
    add(comp);
    _pieceMap['${piece.row},${piece.col}'] = comp;
  }

  void _handleAnimateMove(MoveModel move, bool isAi) {
    final pieceComp = _pieceMap['${move.from.row},${move.from.col}'];
    if (pieceComp == null) {
      _controller.animationCompleted();
      return;
    }
    _animatePath(pieceComp, move, 0);
  }

  void _animatePath(PieceComponent comp, MoveModel move, int pathIndex) {
    if (pathIndex >= move.path.length - 1) {
      _finishAnimation(comp, move);
      return;
    }

    final nextPos = move.path[pathIndex + 1];
    final targetVec = Vector2(_coords.colToX(nextPos.col), _coords.rowToY(nextPos.row));

    comp.moveTo(targetVec, onComplete: () {
      if (pathIndex < move.captured.length) {
        final capPos = move.captured[pathIndex];
        final capComp = _pieceMap.remove('${capPos.row},${capPos.col}');
        capComp?.playDeathAnimation();
      }
      _animatePath(comp, move, pathIndex + 1);
    });
  }

  void _finishAnimation(PieceComponent comp, MoveModel move) {
    _pieceMap.remove('${move.from.row},${move.from.col}');
    _pieceMap['${move.to.row},${move.to.col}'] = comp;
    _controller.animationCompleted();
  }

  void _onStateChanged(GameState state) {
    _boardComponent.updateSelection(state.selectedPiece);
    _clearHints();
    
    if (state.selectedPiece != null && state.isPlayerTurn) {
      _showHints(state.validMoves);
    }

    if (state.isGameOver) {
      overlays.add(GameConstants.gameOverOverlayKey);
    } else {
      overlays.remove(GameConstants.gameOverOverlayKey);
    }
  }

  void _clearHints() {
    for (final h in _hints) h.removeFromParent();
    _hints.clear();
  }

  void _showHints(List<MoveModel> moves) {
    for (final move in moves) {
      final hint = HintComponent(
        tileSize: _tileSize,
        isCapture: move.isCapture,
        position: Vector2(_coords.colToX(move.to.col), _coords.rowToY(move.to.row)),
        variant: _controller.state.variant,
      );
      add(hint);
      _hints.add(hint);
    }
  }

  @override
  void onTapUp(TapUpEvent event) {
    final tapPos = event.canvasPosition;
    if (!_coords.isInBounds(tapPos.x, tapPos.y)) return;

    // قفل اللمس: لا يستجيب إلا في دور اللاعب وحالة اللعب (ليست أنيميشن أو تفكير AI)
    if (_controller.state.isPlayerTurn && _controller.state.phase == GamePhase.playing) {
      final row = _coords.yToRow(tapPos.y);
      final col = _coords.xToCol(tapPos.x);
      _controller.handleTap(row, col);
    }
  }

  @override
  void onRemove() {
    _controller.onAnimateMove = null; // تنظيف الذاكرة
    super.onRemove();
  }
}