import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:flutter/material.dart';


class VariantSelector extends StatelessWidget {
  final GameVariant selected;
  final ValueChanged<GameVariant> onChanged;

  const VariantSelector({super.key, required this.selected, required this.onChanged});
  
 
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _VariantOption(
          label: 'ألمانية (عالمية)',
          description: 'القطع على الزوايا الداكنة',
          icon: '🌍',
          selected: selected == GameVariant.german,
          onTap: () => onChanged(GameVariant.german),
        ),
        const SizedBox(width: 12),
        _VariantOption(
          label: 'تركية',
          description: 'القطع متراصة جنباً لجنب',
          icon: '🕌',
          selected: selected == GameVariant.turkish,
          onTap: () => onChanged(GameVariant.turkish),
        ),
      ],
    );
  }
}




class _VariantOption extends StatelessWidget {
  final String label;
  final String description;
  final String icon;
  final bool selected;
  final VoidCallback onTap;
 
  const _VariantOption({
    required this.label,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
 
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primaryContainer
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(icon, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 6),
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(description,
                  style: const TextStyle(fontSize: 11),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}