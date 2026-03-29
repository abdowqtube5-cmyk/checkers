// lib/core/utils/responsive_helper.dart
//
// يحسب حجم المربع المثالي بناءً على أبعاد الشاشة
// لضمان ظهور اللوحة بالكامل دون تجاوز الشاشة

/// يحسب حجم المربع الواحد بحيث تتسع اللوحة 8×8 داخل الشاشة
double calcTileSize({
  required double screenWidth,
  required double screenHeight,
  int boardSize = 8,
  double padding = 8.0,
}) {
  final availableWidth = screenWidth - padding * 2;
  final availableHeight = screenHeight - padding * 2;
  // نأخذ الحد الأصغر لضمان اللوحة مربعة ومتناسبة
  final maxTile = (availableWidth < availableHeight ? availableWidth : availableHeight) / boardSize;
  return maxTile;
}

/// حساب المسافة بين نقطتين (للتأكد من سرعة ثابتة للأنيميشن)
double calcDistance(double x1, double y1, double x2, double y2) {
  final dx = x2 - x1;
  final dy = y2 - y1;
  return (dx * dx + dy * dy) == 0 ? 0 : (dx * dx + dy * dy) * 0.5;
}