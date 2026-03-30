// lib/features/games/checkers/domain/entities/piece_model.dart

/// لون القطعة
enum PieceColor { white, black, aiColor }

/// متغير اللعبة
enum GameVariant { german, turkish }

/// نموذج القطعة — غير قابل للتعديل (Immutable)
class PieceModel {
  final int row;
  final int col;
  final PieceColor color;
  final bool isKing; // true = قطعة داما (ملك)، false = قطعة عادية

  const PieceModel({
    required this.row,
    required this.col,
    required this.color,
    this.isKing = false,
  });

  PieceModel copyWith({
    int? row,
    int? col,
    PieceColor? color,
    bool? isKing,
  }) {
    return PieceModel(
      row: row ?? this.row,
      col: col ?? this.col,
      color: color ?? this.color,
      isKing: isKing ?? this.isKing,
    );
  }

  /// هل القطعة للاعب الخصم بالنسبة لـ [myColor]؟
  bool isEnemyOf(PieceColor myColor) => color != myColor;

  /// هل القطعة من نفس الفريق؟
  bool isFriendlyTo(PieceColor myColor) => color == myColor;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PieceModel &&
          row == other.row &&
          col == other.col &&
          color == other.color &&
          isKing == other.isKing;

  @override
  int get hashCode => Object.hash(row, col, color, isKing);

  @override
  String toString() => 'PieceModel(r=$row,c=$col,${color.name},${isKing ? "King" : "Regular"})';
}