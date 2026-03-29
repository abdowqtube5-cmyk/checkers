// lib/features/games/checkers/presentation/flame/styles/asset_loader.dart
//
// ══════════════════════════════════════════════════════════
// محمل الموارد (Asset Loader)
// ══════════════════════════════════════════════════════════
//
// الوظيفة (كما في مخطط هيكل الملفات):
//   بدلاً من كتابة كود تحميل الصور والأصوات داخل CheckersGame
//   وتزحمه، نضع منطق التحميل هنا.
//
//   يقوم بتحميل:
//     - صور قطع الداما (أبيض / أسود / داما)
//     - صوت حركة الحجر
//     - صوت الأكل (capture)
//     - صوت الترقية إلى داما (king)
//     - صوت انتهاء اللعبة
//   قبل أن تبدأ اللعبة لضمان عدم وجود "تنتشة" (Lag).
//
// الاستخدام في CheckersGame.onLoad():
//   final loader = AssetLoader(game: this);
//   await loader.preloadAll();
//   // ثم استخدم: loader.playMove(), loader.playCapture() ...

import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

/// مسارات الأصوات — موجودة في assets/audio/
class _AudioPaths {
  static const move    = 'audio/move.mp3';
  static const capture = 'audio/capture.mp3';
  static const king    = 'audio/king.mp3';
  static const gameOver= 'audio/game_over.mp3';
  static const select  = 'audio/select.mp3';
}

/// مسارات الصور — موجودة في assets/images/
/// (اختياري: يمكن الاستغناء عنها والرسم برمجياً كما في PieceComponent)
class _ImagePaths {
  /// لا نستخدم صور خارجية في هذا المشروع —
  /// القطع تُرسم برمجياً بـ Canvas داخل PieceComponent.
  /// هذا الكلاس جاهز لإضافة صور مستقبلاً.
  static const List<String> all = [];
}

// ══════════════════════════════════════════════════════════

class AssetLoader {
  final FlameGame game;

  /// هل تم التحميل بنجاح؟
  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// هل الصوت مفعّل؟ (قد يُعطّله المستخدم)
  bool soundEnabled;

  AssetLoader({
    required this.game,
    this.soundEnabled = true,
  });

  // ══════════════════════════════════════
  // التحميل المسبق الكامل
  // ══════════════════════════════════════

  /// يُستدعى مرة واحدة في CheckersGame.onLoad()
  /// يُحمّل كل الموارد قبل بدء اللعبة لضمان تجربة سلسة.
  Future<void> preloadAll() async {
    await _preloadImages();
    await _preloadAudio();
    _loaded = true;
    debugPrint('[AssetLoader] ✅ All assets loaded.');
  }

  // ── تحميل الصور ────────────────────────────────────────

  Future<void> _preloadImages() async {
    if (_ImagePaths.all.isEmpty) {
      debugPrint('[AssetLoader] No external images to load — pieces drawn programmatically.');
      return;
    }
    try {
      await game.images.loadAll(_ImagePaths.all);
      debugPrint('[AssetLoader] Images loaded: ${_ImagePaths.all}');
    } catch (e) {
      // لا نوقف اللعبة إذا فشل تحميل صورة — نكتفي بالرسم البرمجي
      debugPrint('[AssetLoader] ⚠️ Image load failed (will use programmatic drawing): $e');
    }
  }

  // ── تحميل الأصوات ──────────────────────────────────────

  Future<void> _preloadAudio() async {
    if (!soundEnabled) return;

    final audioPaths = [
      _AudioPaths.move,
      _AudioPaths.capture,
      _AudioPaths.king,
      _AudioPaths.gameOver,
      _AudioPaths.select,
    ];

    for (final path in audioPaths) {
      try {
        await FlameAudio.audioCache.load(path);
        debugPrint('[AssetLoader] 🔊 Audio loaded: $path');
      } catch (e) {
        // الصوت ليس إلزامياً — اللعبة تعمل بدونه
        debugPrint('[AssetLoader] ⚠️ Audio not found (muted): $path');
      }
    }
  }

  // ══════════════════════════════════════
  // واجهة تشغيل الأصوات
  // (تُستدعى من CheckersGame عند الأحداث)
  // ══════════════════════════════════════

  /// صوت تحريك الحجر العادي
  void playMove() => _play(_AudioPaths.move);

  /// صوت أكل قطعة
  void playCapture() => _play(_AudioPaths.capture);

  /// صوت الترقية إلى داما (ملك)
  void playKingPromotion() => _play(_AudioPaths.king);

  /// صوت انتهاء اللعبة
  void playGameOver() => _play(_AudioPaths.gameOver);

  /// صوت اختيار قطعة
  void playSelect() => _play(_AudioPaths.select);

  void _play(String path) {
    if (!soundEnabled || !_loaded) return;
    try {
      FlameAudio.play(path, volume: 0.7);
    } catch (_) {
      // الصوت غير موجود → تجاهل صامت
    }
  }

  // ══════════════════════════════════════
  // تبديل الصوت
  // ══════════════════════════════════════

  void toggleSound() {
    soundEnabled = !soundEnabled;
    debugPrint('[AssetLoader] Sound ${soundEnabled ? "ON" : "OFF"}');
  }

  // ══════════════════════════════════════
  // تنظيف الذاكرة عند إغلاق اللعبة
  // ══════════════════════════════════════

  void dispose() {
    try {
      FlameAudio.audioCache.clearAll();
    } catch (_) {}
    _loaded = false;
  }
}

// ══════════════════════════════════════════════════════════
// ⚠️  تعليمات flame_audio
// ══════════════════════════════════════════════════════════
//
// الخيار 1 — مع صوت حقيقي (موصى به):
//   1. أضف في pubspec.yaml:
//        flame_audio: ^2.10.0
//   2. نفّذ: flutter pub get
//   3. احذف الكلاسين أدناه (FlameAudio و _AudioCache)
//   4. أضف هذا الاستيراد في أعلى هذا الملف:
//        import 'package:flame_audio/flame_audio.dart';
//
// الخيار 2 — بدون صوت (تشغيل فوري):
//   ابقِ الكلاسين أدناه كما هما — اللعبة ستعمل بصمت تام.
//
// ══════════════════════════════════════════════════════════

/// Placeholder صامت — استبدله بـ flame_audio عند الحاجة للصوت الحقيقي
class FlameAudio {
  static final audioCache = _AudioCache();
  static Future<void> play(String path, {double volume = 1.0}) async {}
}

class _AudioCache {
  Future<void> load(String path) async {}
  void clearAll() {}
}