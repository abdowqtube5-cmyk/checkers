// lib/features/games/checkers/domain/entities/move_model.dart

/// إحداثيات بسيطة
class Position {
  final int row;
  final int col;

  const Position(this.row, this.col);

  @override
  bool operator ==(Object other) =>
      other is Position && row == other.row && col == other.col;

  @override
  int get hashCode => Object.hash(row, col);

  @override
  String toString() => '($row,$col)';
}

/// نموذج الحركة — يمثل حركة واحدة (قد تتضمن سلسلة أكل متعددة)
///
/// [path] = مسار الحركة: أول عنصر = نقطة البداية، آخر عنصر = نقطة الوصول
/// [captured] = مواقع القطع المأكولة خلال الحركة
class MoveModel {
  final List<Position> path;
  final List<Position> captured;

  const MoveModel({
    required this.path,
    this.captured = const [], required List<Position> capturedPieces, required Position to, required Position from,
  });

  Position get from => path.first;
  Position get to => path.last;

  bool get isCapture => captured.isNotEmpty;
  int get captureCount => captured.length;

  @override
  String toString() => 'Move(${path.join("→")}, captured=${captured.length})';
}