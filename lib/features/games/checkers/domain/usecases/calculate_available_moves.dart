// lib/features/games/checkers/domain/usecases/calculate_available_moves.dart
//
// دالة حساب الحركات المتاحة لقطعة أو للون بأكمله.
// تطبق قواعد اللعبة للطريقتين الألمانية والتركية.
//
// قواعد مهمة:
// 1. إذا وُجدت أي حركة أكل متاحة، تصبح إجبارية (mandatory capture).
// 2. القطعة العادية لا تتحرك للخلف.
// 3. الداما (الملك) تتحرك في جميع الاتجاهات بأي مسافة.
// 4. سلسلة الأكل تستمر ما وجدت فرصة.


import 'package:checkers/core/utils/board_cloner.dart';
import 'package:checkers/features/games/checkers/domain/entities/board_state.dart';
import 'package:checkers/features/games/checkers/domain/entities/move_model.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

class CalculateAvailableMoves {
  /// الحركات المتاحة لجميع قطع [color] على اللوحة.
  /// إذا وُجدت حركات أكل، يُرجع فقط حركات الأكل (إجبارية).
  List<MoveModel> call(BoardState board, PieceColor color) {
    final allCaptures = <MoveModel>[];
    final allNormal = <MoveModel>[];

    for (final piece in board.piecesOf(color)) {
      final captures = _getCaptures(board, piece, [], []);
      final normals = _getNormalMoves(board, piece);
      allCaptures.addAll(captures);
      allNormal.addAll(normals);
    }

    // الأكل إجباري — إذا توفر أكل، لا نُرجع الحركات العادية
    return allCaptures.isNotEmpty ? allCaptures : allNormal;
  }

  /// الحركات المتاحة لقطعة واحدة [piece].
  List<MoveModel> forPiece(BoardState board, PieceModel piece) {
    // أولاً: هل يوجد أي أكل إجباري على مستوى اللوحة؟
    final colorMoves = call(board, piece.color);
    final hasGlobalCapture = colorMoves.any((m) => m.isCapture);

    if (hasGlobalCapture) {
      // أرجع فقط حركات الأكل الخاصة بهذه القطعة
      return colorMoves
          .where((m) => m.from.row == piece.row && m.from.col == piece.col)
          .toList();
    }
    return _getNormalMoves(board, piece);
  }

  // ════════════════════════════════════════
  // الحركات العادية (بدون أكل)
  // ════════════════════════════════════════

  List<MoveModel> _getNormalMoves(BoardState board, PieceModel piece) {
    final moves = <MoveModel>[];
    final dirs = _getMoveDirs(piece, board.variant);

    if (piece.isKing) {
      // الداما: تتحرك أي مسافة في الاتجاهات المسموح بها
      for (final dir in dirs) {
        var r = piece.row + dir[0];
        var c = piece.col + dir[1];
        while (board.inBounds(r, c) && board.isEmpty(r, c)) {
          moves.add(MoveModel(
            path: [Position(piece.row, piece.col), Position(r, c)],
          ));
          r += dir[0];
          c += dir[1];
        }
      }
    } else {
      // القطعة العادية: خطوة واحدة فقط
      for (final dir in dirs) {
        final r = piece.row + dir[0];
        final c = piece.col + dir[1];
        if (board.inBounds(r, c) && board.isEmpty(r, c)) {
          moves.add(MoveModel(
            path: [Position(piece.row, piece.col), Position(r, c)],
          ));
        }
      }
    }
    return moves;
  }

  // ════════════════════════════════════════
  // حركات الأكل (مع سلسلة الأكل)
  // ════════════════════════════════════════

  /// يولّد كل حركات الأكل (مع السلسلة) انطلاقاً من [piece].
  List<MoveModel> _getCaptures(
    BoardState board,
    PieceModel piece,
    List<Position> currentPath,
    List<Position> alreadyCaptured,
  ) {
    final startPos = Position(piece.row, piece.col);
    final pathSoFar = currentPath.isEmpty ? [startPos] : currentPath;
    final results = <MoveModel>[];

    final captureDirs = _getCaptureDirs(piece, board.variant);
    bool foundNextCapture = false;

    for (final dir in captureDirs) {
      final captures = _findCapturesInDirection(
        board, piece, dir, pathSoFar, alreadyCaptured,
      );
      for (final capture in captures) {
        foundNextCapture = true;
        // من الموقع الجديد، ابحث عن أكل تالٍ (تكرار)
        final newPiece = _promotedIfNeeded(capture.landPiece, board);
        final nextCaptures = _getCaptures(
          capture.newBoard,
          newPiece,
          [...pathSoFar, capture.landPos],
          [...alreadyCaptured, capture.capturedPos],
        );
        if (nextCaptures.isEmpty) {
          // لا يوجد أكل تالٍ → هذه نهاية السلسلة
          results.add(MoveModel(
            path: [...pathSoFar, capture.landPos],
            captured: [...alreadyCaptured, capture.capturedPos],
          ));
        } else {
          results.addAll(nextCaptures);
        }
      }
    }

    // إذا لم يجد أي أكل بعد حركة سابقة، يُضيف الوضع الحالي
    if (!foundNextCapture && currentPath.isNotEmpty) {
      results.add(MoveModel(
        path: List.from(currentPath),
        captured: List.from(alreadyCaptured),
      ));
    }

    return results;
  }

  /// يجد حركات الأكل في اتجاه واحد [dir].
  List<_CaptureResult> _findCapturesInDirection(
    BoardState board,
    PieceModel piece,
    List<int> dir,
    List<Position> path,
    List<Position> alreadyCaptured,
  ) {
    final results = <_CaptureResult>[];

    if (piece.isKing) {
      // الداما: العدو قد يكون على مسافة أي عدد خطوات
      var r = piece.row + dir[0];
      var c = piece.col + dir[1];
      PieceModel? foundEnemy;
      Position? enemyPos;

      while (board.inBounds(r, c)) {
        final cell = board.get(r, c);
        if (cell != null) {
          if (cell.isEnemyOf(piece.color) &&
              !alreadyCaptured.contains(Position(r, c))) {
            foundEnemy = cell;
            enemyPos = Position(r, c);
          }
          break; // وجدنا قطعة — توقف البحث في هذا الاتجاه
        }
        r += dir[0];
        c += dir[1];
      }

      if (foundEnemy != null && enemyPos != null) {
        // تحقق من المربعات الفارغة بعد العدو
        var lr = enemyPos.row + dir[0];
        var lc = enemyPos.col + dir[1];
        while (board.inBounds(lr, lc) && board.isEmpty(lr, lc)) {
          final landPos = Position(lr, lc);
          if (!path.contains(landPos)) {
            final newBoard = _applyCapture(board, piece, landPos, enemyPos);
            final landPiece = PieceModel(
              row: lr, col: lc, color: piece.color, isKing: piece.isKing,
            );
            results.add(_CaptureResult(
              newBoard: newBoard,
              landPos: landPos,
              capturedPos: enemyPos,
              landPiece: landPiece,
            ));
          }
          lr += dir[0];
          lc += dir[1];
        }
      }
    } else {
      // القطعة العادية: العدو على مسافة خطوة واحدة، الهبوط على مسافة خطوتين
      final er = piece.row + dir[0];
      final ec = piece.col + dir[1];
      final lr = piece.row + dir[0] * 2;
      final lc = piece.col + dir[1] * 2;

      if (!board.inBounds(er, ec) || !board.inBounds(lr, lc)) return results;

      final enemy = board.get(er, ec);
      final enemyPos = Position(er, ec);
      final landPos = Position(lr, lc);

      if (enemy != null &&
          enemy.isEnemyOf(piece.color) &&
          !alreadyCaptured.contains(enemyPos) &&
          board.isEmpty(lr, lc) &&
          !path.contains(landPos)) {
        final newBoard = _applyCapture(board, piece, landPos, enemyPos);
        final landPiece = PieceModel(
          row: lr, col: lc, color: piece.color, isKing: piece.isKing,
        );
        results.add(_CaptureResult(
          newBoard: newBoard,
          landPos: landPos,
          capturedPos: enemyPos,
          landPiece: landPiece,
        ));
      }
    }

    return results;
  }

  /// ينفذ حركة الأكل على نسخة من اللوحة ويُرجع اللوحة الجديدة
  BoardState _applyCapture(
    BoardState board,
    PieceModel piece,
    Position landPos,
    Position capturedPos,
  ) {
    final newGrid = cloneBoard(board.grid);
    newGrid[piece.row][piece.col] = null;
    newGrid[capturedPos.row][capturedPos.col] = null;
    newGrid[landPos.row][landPos.col] = PieceModel(
      row: landPos.row,
      col: landPos.col,
      color: piece.color,
      isKing: piece.isKing,
    );
    return BoardState(grid: newGrid, variant: board.variant, size: board.size);
  }

  /// هل يجب ترقية القطعة إلى ملك في الموقع الجديد؟
  PieceModel _promotedIfNeeded(PieceModel piece, BoardState board) {
    if (piece.isKing) return piece;
    final isWhitePromotion = piece.color == PieceColor.white && piece.row == board.size - 1;
    final isBlackPromotion = piece.color == PieceColor.black && piece.row == 0;
    if (isWhitePromotion || isBlackPromotion) {
      return piece.copyWith(isKing: true);
    }
    return piece;
  }

  // ════════════════════════════════════════
  // الاتجاهات حسب المتغير
  // ════════════════════════════════════════

  /// اتجاهات الحركة العادية (بدون أكل)
  List<List<int>> _getMoveDirs(PieceModel piece, GameVariant variant) {
    if (piece.isKing) {
      return variant == GameVariant.german
          ? [[1, 1], [1, -1], [-1, 1], [-1, -1]]   // كل القطريات
          : [[1, 0], [-1, 0], [0, 1], [0, -1]];    // كل الاتجاهات المستقيمة
    }
    // قطعة عادية لا تتحرك للخلف
    if (variant == GameVariant.german) {
      return piece.color == PieceColor.white
          ? [[1, 1], [1, -1]]    // أبيض: للأمام قطرياً
          : [[-1, 1], [-1, -1]]; // أسود: للأمام قطرياً
    } else {
      // تركي: للأمام + الجانبين
      return piece.color == PieceColor.white
          ? [[1, 0], [0, 1], [0, -1]]    // أبيض
          : [[-1, 0], [0, 1], [0, -1]]; // أسود
    }
  }

  /// اتجاهات الأكل (للقطعة العادية: نفس اتجاهات الحركة)
  /// للداما: جميع الاتجاهات دائماً
  List<List<int>> _getCaptureDirs(PieceModel piece, GameVariant variant) {
    if (piece.isKing) {
      return variant == GameVariant.german
          ? [[1, 1], [1, -1], [-1, 1], [-1, -1]]
          : [[1, 0], [-1, 0], [0, 1], [0, -1]];
    }
    // القطعة العادية: اتجاهات حركتها فقط
    return _getMoveDirs(piece, variant);
  }
}

/// نتيجة داخلية لحركة أكل في اتجاه واحد
class _CaptureResult {
  final BoardState newBoard;
  final Position landPos;
  final Position capturedPos;
  final PieceModel landPiece;

  _CaptureResult({
    required this.newBoard,
    required this.landPos,
    required this.capturedPos,
    required this.landPiece,
  });
}