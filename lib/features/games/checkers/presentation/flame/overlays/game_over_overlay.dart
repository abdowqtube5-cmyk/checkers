// lib/features/games/checkers/presentation/flame/overlays/game_over_overlay.dart
//
// نافذة انتهاء اللعبة — ترسمها Flutter فوق شاشة Flame

import 'package:checkers/features/games/checkers/presentation/manager/game_controller.dart';
import 'package:checkers/features/games/checkers/presentation/manager/game_state.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GameController>();

    return Obx(() {
      final state = controller.state;
      final result = state.result;

      final (title, emoji, color) = switch (result) {
        GameResult.playerWin => ('أنت الفائز!', '🏆', const Color(0xFF43A047)),
        GameResult.aiWin     => ('الذكاء الاصطناعي فاز', '🤖', const Color(0xFFE53935)),
        GameResult.draw      => ('تعادل!', '🤝', const Color(0xFFFF8F00)),
        null                 => ('انتهت اللعبة', '🎮', Colors.grey),
      };

      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xF01A1208),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'القطع المأكولة\n'
                'أنت أكلت: ${state.blackCaptured}   AI أكل: ${state.whiteCaptured}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFFBCAAA4),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
               Wrap(
                  
                  children: [
                    
                       _ActionButton(
                        label: 'العب مرة أخرى',
                        icon: Icons.refresh,
                        color: color,
                        onTap: () {
                          controller.startGame(state.variant, state.playerColor);
                          Get.offNamed('/game');
                        },
                      ),
                    
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ActionButton(
                        label: 'القائمة الرئيسية' ,
                        icon: Icons.home,
                        color: Colors.grey,
                        onTap: () => Get.offAllNamed('/menu'),
                      ),
                    ),
                  ],
                ),
              
            ],
          ),
        ),
      );
    });
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 4),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}