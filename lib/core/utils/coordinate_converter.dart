// lib/core/utils/coordinate_converter.dart
//
// القانون: y_screen = screenHeight - ((row + 1) * tileSize) + boardTop
// بهذه الطريقة row=0 → أسفل اللوحة، row=7 → أعلى اللوحة

/// محوّل الإحداثيات: يحوّل (row, col) منطقية إلى إحداثيات بكسل على الشاشة
class CoordinateConverter {
  final double tileSize;
  final double boardLeft; // إزاحة اللوحة من يسار الشاشة
  final double boardTop;  // إزاحة اللوحة من أعلى الشاشة
  final int boardSize;    // عدد الصفوف/الأعمدة (8)

  const CoordinateConverter({
    required this.tileSize,
    required this.boardLeft,
    required this.boardTop,
    this.boardSize = 8,
  });

  /// تحويل عمود منطقي إلى إحداثي X (أقصى يسار المربع)
  double colToX(int col) => boardLeft + col * tileSize;

  /// تحويل صف منطقي إلى إحداثي Y (أقصى أعلى المربع)
  /// row=0 → أسفل اللوحة (Y كبير)، row=7 → أعلى اللوحة (Y صغير)
  double rowToY(int row) => boardTop + (boardSize - 1 - row) * tileSize;

  /// مركز المربع (X)
  double colToCenterX(int col) => colToX(col) + tileSize / 2;

  /// مركز المربع (Y)
  double rowToCenterY(int row) => rowToY(row) + tileSize / 2;

  /// تحويل إحداثي X (بكسل) إلى عمود منطقي
  int xToCol(double x) => ((x - boardLeft) / tileSize).floor().clamp(0, boardSize - 1);

  /// تحويل إحداثي Y (بكسل) إلى صف منطقي
  int yToRow(double y) =>
      (boardSize - 1 - ((y - boardTop) / tileSize).floor()).clamp(0, boardSize - 1);

  /// هل الإحداثيات داخل حدود اللوحة؟
  bool isInBounds(double x, double y) {
    return x >= boardLeft &&
        x < boardLeft + boardSize * tileSize &&
        y >= boardTop &&
        y < boardTop + boardSize * tileSize;
  }
}