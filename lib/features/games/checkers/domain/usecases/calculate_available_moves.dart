// lib/features/games/checkers/domain/usecases/calculate_available_moves.dart

import 'package:checkers/core/utils/board_cloner.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

class CalculateAvailableMoves {
  /// نمرر [playerColor] لنعرف أن هذا اللون يبدأ من الأسفل واتجاهه دائماً لزيادة الصفوف
  List<MoveModel> call(BoardState board, PieceColor color, PieceColor playerColor) {
    final allCaptures = <MoveModel>[];
    final allNormal = <MoveModel>[];

    for (final piece in board.piecesOf(color)) {
      final captures = _getCaptures(board, piece, [], [], playerColor);
      final normals = _getNormalMoves(board, piece, playerColor);
      allCaptures.addAll(captures);
      allNormal.addAll(normals);
    }

    return allCaptures.isNotEmpty ? allCaptures : allNormal;
  }

  List<MoveModel> forPiece(BoardState board, PieceModel piece, PieceColor playerColor) {
    final colorMoves = call(board, piece.color, playerColor);
    final hasGlobalCapture = colorMoves.any((m) => m.isCapture);

    if (hasGlobalCapture) {
      return colorMoves
          .where((m) => m.from.row == piece.row && m.from.col == piece.col)
          .toList();
    }
    return _getNormalMoves(board, piece, playerColor);
  }

  // ════════════════════════════════════════
  // الحركات العادية (بدون أكل)
  // ════════════════════════════════════════
  List<MoveModel> _getNormalMoves(BoardState board, PieceModel piece, PieceColor playerColor) {
    final moves = <MoveModel>[];
    final dirs = _getMoveDirs(piece, board.variant, playerColor);

    for (final dir in dirs) {
      var r = piece.row + dir[0];
      var c = piece.col + dir[1];

      if (piece.isKing) {
        while (board.inBounds(r, c) && board.isEmpty(r, c)) {
          moves.add(MoveModel(
            from: Position(piece.row, piece.col),
            to: Position(r, c),
            path: [Position(piece.row, piece.col), Position(r, c)],
            capturedPieces: [],
          ));
          r += dir[0];
          c += dir[1];
        }
      } else {
        if (board.inBounds(r, c) && board.isEmpty(r, c)) {
          moves.add(MoveModel(
            from: Position(piece.row, piece.col),
            to: Position(r, c),
            path: [Position(piece.row, piece.col), Position(r, c)],
            capturedPieces: [],
          ));
        }
      }
    }
    return moves;
  }

  // ════════════════════════════════════════
  // حركات الأكل (مع السلسلة)
  // ════════════════════════════════════════
  List<MoveModel> _getCaptures(
    BoardState board,
    PieceModel piece,
    List<Position> currentPath,
    List<Position> alreadyCaptured,
    PieceColor playerColor,
  ) {
    final startPos = Position(piece.row, piece.col);
    final pathSoFar = currentPath.isEmpty ? [startPos] : currentPath;
    final results = <MoveModel>[];

    final captureDirs = _getCaptureDirs(piece, board.variant, playerColor);
    bool foundNextCapture = false;

    for (final dir in captureDirs) {
      final captures = _findCapturesInDirection(
        board, piece, dir, pathSoFar, alreadyCaptured, playerColor,
      );
      for (final capture in captures) {
        foundNextCapture = true;
        final newPiece = _promotedIfNeeded(capture.landPiece, board, playerColor);
        
        final nextCaptures = _getCaptures(
          capture.newBoard,
          newPiece,
          [...pathSoFar, capture.landPos],
          [...alreadyCaptured, capture.capturedPos],
          playerColor,
        );

        if (nextCaptures.isEmpty) {
          results.add(MoveModel(
            from: startPos,
            to: capture.landPos,
            path: [...pathSoFar, capture.landPos],
            captured: [...alreadyCaptured, capture.capturedPos],
            capturedPieces: [...alreadyCaptured, capture.capturedPos],
          ));
        } else {
          results.addAll(nextCaptures);
        }
      }
    }
    return results;
  }

  List<_CaptureResult> _findCapturesInDirection(
    BoardState board,
    PieceModel piece,
    List<int> dir,
    List<Position> path,
    List<Position> alreadyCaptured,
    PieceColor playerColor,
  ) {
    final results = <_CaptureResult>[];
    if (piece.isKing) {
      var r = piece.row + dir[0];
      var c = piece.col + dir[1];
      PieceModel? foundEnemy;
      Position? enemyPos;

      while (board.inBounds(r, c)) {
        final cell = board.get(r, c);
        if (cell != null) {
          if (cell.color != piece.color && !alreadyCaptured.contains(Position(r, c))) {
            foundEnemy = cell;
            enemyPos = Position(r, c);
          }
          break;
        }
        r += dir[0];
        c += dir[1];
      }

      if (foundEnemy != null && enemyPos != null) {
        var lr = enemyPos.row + dir[0];
        var lc = enemyPos.col + dir[1];
        while (board.inBounds(lr, lc) && board.isEmpty(lr, lc)) {
          final landPos = Position(lr, lc);
          final newBoard = _applyCapture(board, piece, landPos, enemyPos);
          results.add(_CaptureResult(
            newBoard: newBoard,
            landPos: landPos,
            capturedPos: enemyPos,
            landPiece: piece.copyWith(row: lr, col: lc),
          ));
          lr += dir[0];
          lc += dir[1];
        }
      }
    } else {
      final er = piece.row + dir[0];
      final ec = piece.col + dir[1];
      final lr = piece.row + dir[0] * 2;
      final lc = piece.col + dir[1] * 2;

      if (board.inBounds(lr, lc)) {
        final enemy = board.get(er, ec);
        final enemyPos = Position(er, ec);
        if (enemy != null && enemy.color != piece.color && 
            !alreadyCaptured.contains(enemyPos) && board.isEmpty(lr, lc)) {
          final newBoard = _applyCapture(board, piece, Position(lr, lc), enemyPos);
          results.add(_CaptureResult(
            newBoard: newBoard,
            landPos: Position(lr, lc),
            capturedPos: enemyPos,
            landPiece: piece.copyWith(row: lr, col: lc),
          ));
        }
      }
    }
    return results;
  }

  BoardState _applyCapture(BoardState board, PieceModel piece, Position land, Position cap) {
    final newGrid = board.grid.map((r) => List<PieceModel?>.from(r)).toList();
    newGrid[piece.row][piece.col] = null;
    newGrid[cap.row][cap.col] = null;
    newGrid[land.row][land.col] = piece.copyWith(row: land.row, col: land.col);
    return BoardState(grid: newGrid, variant: board.variant, size: board.size);
  }

  /// الترقية بناءً على الوصول للطرف المقابل
  PieceModel _promotedIfNeeded(PieceModel piece, BoardState board, PieceColor playerColor) {
    if (piece.isKing) return piece;
    // إذا كانت قطعة اللاعب، تترقى عند الصف الأخير (7)
    // إذا كانت قطعة الخصم، تترقى عند الصف الأول (0)
    final targetRow = (piece.color == playerColor) ? 7: 0;
    if (piece.row == targetRow) {
      return piece.copyWith(isKing: true);
    }
    return piece;
  }

  // ════════════════════════════════════════
  // الحل السحري: الاتجاه يعتمد على playerColor
  // ════════════════════════════════════════
  List<List<int>> _getMoveDirs(PieceModel piece, GameVariant variant, PieceColor playerColor) {
    if (piece.isKing) {
      return variant == GameVariant.german
          ? [[1, 1], [1, -1], [-1, 1], [-1, -1]]
          : [[1, 0], [-1, 0], [0, 1], [0, -1]];
    }

    // اتجاه الأمام: +1 لمن بدأ في الأسفل، -1 لمن بدأ في الأعلى
    final int forward = (piece.color == playerColor) ? 1 : -1;

    if (variant == GameVariant.german) {
      return [[forward, 1], [forward, -1]];
    } else {
      return [[forward, 0], [0, 1], [0, -1]];
    }
  }

  List<List<int>> _getCaptureDirs(PieceModel piece, GameVariant variant, PieceColor playerColor) {
    if (piece.isKing) {
      return variant == GameVariant.german
          ? [[1, 1], [1, -1], [-1, 1], [-1, -1]]
          : [[1, 0], [-1, 0], [0, 1], [0, -1]];
    }
    // للقطعة العادية: نحدد اتجاه الأمام بناءً على جهة البداية
    final int forward = (piece.color == playerColor) ? 1 : -1;

    if (variant == GameVariant.german) {
      // التعديل هنا: منعنا الأكل للخلف، وجعلناه قطرياً للأمام فقط
      return [[forward, 1], [forward, -1]];
    } else {
      // التركي: للأمام والجانبين فقط (بدون الخلف)
      return [[forward, 0], [0, 1], [0, -1]];
    }
  }
}

class _CaptureResult {
  final BoardState newBoard;
  final Position landPos;
  final Position capturedPos;
  final PieceModel landPiece;
  _CaptureResult({required this.newBoard, required this.landPos, required this.capturedPos, required this.landPiece});
}