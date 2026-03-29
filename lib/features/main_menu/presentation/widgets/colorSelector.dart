import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:flutter/material.dart';

class ColorSelector extends StatelessWidget {
  final PieceColor selected;
  final ValueChanged<PieceColor> onChanged;

  const ColorSelector({super.key, required this.selected, required this.onChanged});

 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ColorOption(
          label: 'أبيض (يبدأ أولاً)',
          color: Colors.white,
          strokeColor: Colors.grey.shade400,
          selected: selected == PieceColor.white,
          onTap: () => onChanged(PieceColor.white),
        ),
        const SizedBox(width: 20),
        _ColorOption(
          label: 'أسود (يبدأ ثانياً)',
          color: Colors.grey.shade900,
          strokeColor: Colors.grey.shade600,
          selected: selected == PieceColor.black,
          onTap: () => onChanged(PieceColor.black),
        ),
      ],
    );
  }
}


class _ColorOption extends StatelessWidget {
  final String label;
  final Color color;
  final Color strokeColor;
  final bool selected;
  final VoidCallback onTap;
 
  const _ColorOption({
    required this.label,
    required this.color,
    required this.strokeColor,
    required this.selected,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(
                color: selected
                    ? Theme.of(context).colorScheme.primary
                    : strokeColor,
                width: selected ? 3.5 : 2,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : null,
            ),
            child: selected
                ? Icon(Icons.check,
                    color: color == Colors.white ? Colors.black : Colors.white,
                    size: 28)
                : null,
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
 