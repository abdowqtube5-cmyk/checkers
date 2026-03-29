// lib/features/games/checkers/presentation/manager/turn_coordinator.dart

import 'dart:async';

class TurnCoordinator {
  // زمن تفكير الـ AI (ليشعر اللاعب أنه يفكر)
  static const Duration aiThinkingDelay = Duration(milliseconds: 800);
  // زمن انتظار بعد انتهاء الأنيميشن وقبل تبديل الدور
  static const Duration animationPadding = Duration(milliseconds: 200);

  Future<void> waitBeforeAiStarts() => Future.delayed(aiThinkingDelay);
  Future<void> waitAfterAnimation() => Future.delayed(animationPadding);
  
  // ═══════════════════════════════════════════════════════
  // جديد: تأخير أولي لحركة AI الأولى عندما يكون اللاعب أسود
  // ═══════════════════════════════════════════════════════
  static const Duration initialAiDelay = Duration(milliseconds: 600);
  
  Future<void> waitForInitialMove() => Future.delayed(initialAiDelay);
}