// lib/features/games/checkers/domain/entities/board_state.dart



import 'package:checkers/core/constants/game_constants.dart';
import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';

/// حالة اللوحة — تمثيل منطقي للرقعة
///
/// المصفوفة [grid[row][col]]:
///   - null = مربع فارغ
///   - PieceModel = يوجد قطعة
///
/// row=0 → أسفل اللوحة (مكان بداية الأبيض)
/// row=7 → أعلى اللوحة (مكان بداية الأسود)
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

  /// جميع القطع لـ [color]
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

  /// إنشاء لوحة ابتدائية حسب المتغير
  factory BoardState.initial(GameVariant variant) {
    final grid = List.generate(
      GameConstants.boardSize,
      (_) => List<PieceModel?>.filled(GameConstants.boardSize, null),
    );
    _placePieces(grid, variant);
    return BoardState(grid: grid, variant: variant);
  }

  static void _placePieces(List<List<PieceModel?>> grid, GameVariant variant) {
    if (variant == GameVariant.german) {
      _placeGerman(grid);
    } else {
      _placeTurkish(grid);
    }
  }

  /// الطريقة الألمانية (العالمية):
  /// القطع تتوزع على المربعات الداكنة (row+col)%2==1
  /// أبيض: صفوف 0,1,2 — أسود: صفوف 5,6,7
  static void _placeGerman(List<List<PieceModel?>> grid) {
    for (var c = 0; c < 8; c++) {
      for (var r = 0; r <= 2; r++) {
        if ((r + c) % 2 == 1) {
          grid[r][c] = PieceModel(row: r, col: c, color: PieceColor.white);
        }
      }
      for (var r = 5; r <= 7; r++) {
        if ((r + c) % 2 == 1) {
          grid[r][c] = PieceModel(row: r, col: c, color: PieceColor.black);
        }
      }
    }
  }

  /// الطريقة التركية:
  /// القطع متراصة جنباً لجنب مع ترك العمود الأول (col=0) فارغاً
  /// أبيض: صفوف 1,2 (col=1..7) — أسود: صفوف 5,6 (col=1..7)
  static void _placeTurkish(List<List<PieceModel?>> grid) {
    for (var c = 0; c < 8; c++) {
      for (var r = 1; r <= 2; r++) {
        grid[r][c] = PieceModel(row: r, col: c, color: PieceColor.white);
      }
      for (var r = 5; r <= 6; r++) {
        grid[r][c] = PieceModel(row: r, col: c, color: PieceColor.black);
      }
    }
  }
}