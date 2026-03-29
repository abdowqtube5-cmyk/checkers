import 'package:flutter/material.dart';

class CheckersBoardIcon extends StatelessWidget {
  const CheckersBoardIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: GridView.count(
        crossAxisCount: 4,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(16, (i) {
          final row = i ~/ 4;
          final col = i % 4;
          final isDark = (row + col) % 2 == 1;
          return Container(
            color: isDark ? const Color(0xFF8D6E63) : const Color(0xFFF5DEB3),
          );
        }),
      ),
    );
  }
}