// lib/features/games/checkers/domain/entities/board_state.dart

import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

class BoardState {
  final List<List<PieceModel?>> grid;
  final GameVariant variant;
  final int size;

  BoardState({
    required this.grid,
    required this.variant,
    this.size = GameConstants.boardSize,
  });

  PieceModel? get(int row, int col) {
    if (!_inBounds(row, col)) return null;
    return grid[row][col];
  }

  bool isEmpty(int row, int col) => _inBounds(row, col) && grid[row][col] == null;
  bool inBounds(int row, int col) => _inBounds(row, col);

  bool _inBounds(int row, int col) =>
      row >= 0 && row < size && col >= 0 && col < size;

  BoardState withPiece(int row, int col, PieceModel? piece) {
    final newGrid = _copyGrid();
    newGrid[row][col] = piece;
    return BoardState(grid: newGrid, variant: variant, size: size);
  }

  List<List<PieceModel?>> _copyGrid() =>
      grid.map((row) => List<PieceModel?>.from(row)).toList();

  List<PieceModel> piecesOf(PieceColor color) {
    final result = <PieceModel>[];
    for (var r = 0; r < size; r++) {
      for (var c = 0; c < size; c++) {
        final p = grid[r][c];
        if (p != null && p.color == color) result.add(p);
      }
    }
    return result;
  }

  // ═══════════════════════════════════════════════════════
  // التعديل: تمرير لون اللاعب (playerColor) لتحديد أماكن الرص
  // ═══════════════════════════════════════════════════════
  factory BoardState.initial(GameVariant variant, PieceColor playerColor) {
    final grid = List.generate(
      GameConstants.boardSize,
      (_) => List<PieceModel?>.filled(GameConstants.boardSize, null),
    );
    _placePieces(grid, variant, playerColor);
    return BoardState(grid: grid, variant: variant);
  }

  static void _placePieces(List<List<PieceModel?>> grid, GameVariant variant, PieceColor playerColor) {
    if (variant == GameVariant.german) {
      _placeGerman(grid, playerColor);
    } else {
      _placeTurkish(grid, playerColor);
    }
  }

  // ═══════════════════════════════════════════════════════
  // التعديل: اللاعب في الأسفل (الصفوف 0,1,2) والخصم في الأعلى (الصفوف 5,6,7)
  // ═══════════════════════════════════════════════════════
  static void _placeGerman(List<List<PieceModel?>> grid, PieceColor playerColor) {
    final aiColor = (playerColor == PieceColor.white) ? PieceColor.black : PieceColor.white;
    
    for (var c = 0; c < 8; c++) {
      // رص قطع اللاعب في الأسفل
      for (var r = 0; r <= 2; r++) {
        if ((r + c) % 2 == 1) {
          grid[r][c] = PieceModel(row: r, col: c, color: playerColor);
        }
      }
      // رص قطع الكمبيوتر في الأعلى
      for (var r = 5; r <= 7; r++) {
        if ((r + c) % 2 == 1) {
          grid[r][c] = PieceModel(row: r, col: c, color: aiColor);
        }
      }
    }
  }

  // ═══════════════════════════════════════════════════════
  // التعديل: اللاعب في الأسفل (الصفوف 1,2) والخصم في الأعلى (الصفوف 5,6)
  // ═══════════════════════════════════════════════════════
  static void _placeTurkish(List<List<PieceModel?>> grid, PieceColor playerColor) {
    final aiColor = (playerColor == PieceColor.white) ? PieceColor.black : PieceColor.white;
    
    for (var c = 0; c < 8; c++) {
      // رص قطع اللاعب في الأسفل
      for (var r = 1; r <= 2; r++) {
        grid[r][c] = PieceModel(row: r, col: c, color: playerColor);
      }
      // رص قطع الكمبيوتر في الأعلى
      for (var r = 5; r <= 6; r++) {
        grid[r][c] = PieceModel(row: r, col: c, color: aiColor);
      }
    }
  }
}