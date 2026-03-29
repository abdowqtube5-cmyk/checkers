// lib/features/games/checkers/presentation/pages/game_page.dart
//
// (GamePage) — الصفحة التي تحوي GameWidget
// ترسمها Flutter وتضع Flame داخلها
// تستعرض أيضاً معلومات اللعبة فوق وتحت اللوحة

import 'package:checkers/features/games/checkers/domain/entities/piece_model.dart';
import 'package:checkers/features/games/checkers/presentation/manager/game_controller.dart';
import 'package:checkers/features/games/checkers/presentation/manager/game_state.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:checkers/core/constants/game_constants.dart';

import 'package:checkers/features/games/checkers/presentation/flame/checkers_game.dart';
import 'package:checkers/features/games/checkers/presentation/flame/overlays/game_over_overlay.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final CheckersGame _game;
  late final GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<GameController>();
    _game = CheckersGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: GameWidget(
                game: _game,
                overlayBuilderMap: {
                  GameConstants.gameOverOverlayKey: (context, game) =>
                      const GameOverOverlay(),
                },
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────
  // شريط علوي: اسم اللاعبين + الدور
  // ─────────────────────────────────────
// lib/features/games/checkers/presentation/pages/game_page.dart

// استبدل _buildTopBar كاملاً بهذا:

Widget _buildTopBar(BuildContext context) {
  return Obx(() {
    final state = _controller.state;
    
    // ═══════════════════════════════════════════════════════
    // تحديد ألوان اللاعبين بناءً على playerColor
    // ═══════════════════════════════════════════════════════
    final playerIsWhite = state.playerColor == PieceColor.white;
    
    // لون اللاعب: أبيض أو أسود
    final playerColor = playerIsWhite ? Colors.white : Colors.black87;
    // لون AI: عكس لون اللاعب
    final aiColor = playerIsWhite ? Colors.black87 : Colors.white;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4),
        ],
      ),
      child: Row(
        children: [
          // ── الذكاء الاصطناعي ──────────────
          _PlayerIndicator(
            label: 'الذكاء الاصطناعي',
            icon: Icons.smart_toy,
            isActive: state.isAiTurn,
            captured: playerIsWhite ? state.whiteCaptured : state.blackCaptured,
            colorDot: aiColor,  // ═══> لون AI الديناميكي
          ),
          const Spacer(),
          // ── الدور الحالي ─────────────────
          Column(
            children: [
              Text(
                _phaseLabel(state.phase),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 2),
              _TurnIndicator(
                phase: state.phase,
                isPlayerTurn: state.isPlayerTurn,
              ),
            ],
          ),
          const Spacer(),
          // ── اللاعب البشري ────────────────
          _PlayerIndicator(
            label: 'أنت',
            icon: Icons.person,
            isActive: state.isPlayerTurn,
            captured: playerIsWhite ? state.blackCaptured : state.whiteCaptured,
            colorDot: playerColor,  // ═══> لون اللاعب الديناميكي
          ),
        ],
      ),
    );
  });
}

  // ─────────────────────────────────────
  // شريط سفلي: زر الاستسلام
  // ─────────────────────────────────────
  Widget _buildBottomBar(BuildContext context) {
    return Obx(() {
      if (_controller.state.isGameOver) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showResignDialog(context),
            icon: const Icon(Icons.flag_outlined, size: 18),
            label: const Text('استسلام'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.redAccent,
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showResignDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('استسلام؟'),
        content: const Text('هل أنت متأكد أنك تريد الاستسلام؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لا'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _controller.resign();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('نعم، استسلم'),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(GamePhase phase) => switch (phase) {
    GamePhase.playing => 'دورك',
    GamePhase.aiThinking => 'الذكاء يفكر...',
    GamePhase.animating => 'تحريك...',
    GamePhase.gameOver => 'انتهت اللعبة',
  };
}

// ══════════════════════════════════════
// ويدجت مؤشر اللاعب
// ══════════════════════════════════════

class _PlayerIndicator extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final int captured;
  final Color colorDot;

  const _PlayerIndicator({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.captured,
    required this.colorDot,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: isActive
            ? Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              )
            : null,
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorDot,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 1),
                ),
              ),
              const SizedBox(width: 6),
              Icon(icon, size: 18),
              const SizedBox(width: 4),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
          if (captured > 0)
            Text(
              'أكل: $captured',
              style: const TextStyle(fontSize: 11, color: Colors.redAccent),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════
// مؤشر الدور (نقطة متحركة)
// ══════════════════════════════════════

class _TurnIndicator extends StatelessWidget {
  final GamePhase phase;
  final bool isPlayerTurn;

  const _TurnIndicator({required this.phase, required this.isPlayerTurn});

  @override
  Widget build(BuildContext context) {
    if (phase == GamePhase.aiThinking) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    return Icon(
      isPlayerTurn ? Icons.touch_app : Icons.smart_toy,
      size: 20,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
