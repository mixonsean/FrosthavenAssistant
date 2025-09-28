import 'dart:ui';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';

class FullscreenHelper {
  static Rect? _savedBounds;

  static Future<void> enterOnCurrentDisplay() async {
    // Remember current window geometry to restore later
    _savedBounds = await windowManager.getBounds();

    // Find the window center
    final pos = await windowManager.getPosition();
    final size = await windowManager.getSize();
    final center = Offset(pos.dx + size.width / 2, pos.dy + size.height / 2);

    // Pick the display that contains (or is nearest to) that center
    final displays = await screenRetriever.getAllDisplays();
    final target = _pickDisplayForPoint(displays, center);

    // Move the window fully onto that display (keep size, center it)
    final vp = target.visiblePosition ?? const Offset(0, 0);
    final vs = target.visibleSize ?? target.size;
    final newPos = Offset(
      vp.dx + (vs.width - size.width) / 2,
      vp.dy + (vs.height - size.height) / 2,
    );
    await windowManager.setPosition(newPos, animate: false);

    // Give WM a tick to settle, then enter fullscreen
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await windowManager.setFullScreen(true);
  }

  static Future<void> exitAndRestore() async {
    await windowManager.setFullScreen(false);
    if (_savedBounds != null) {
      await windowManager.setBounds(_savedBounds!, animate: false);
    }
  }

  static Display _pickDisplayForPoint(List<Display> displays, Offset pt) {
    // Prefer the display whose visible rect contains the point
    for (final d in displays) {
      final p = d.visiblePosition ?? const Offset(0, 0);
      final s = d.visibleSize ?? d.size;
      final r = Rect.fromLTWH(p.dx, p.dy, s.width, s.height);
      if (r.contains(pt)) return d;
    }
    // Otherwise, choose the nearest by center distance
    double best = double.infinity;
    Display bestD = displays.first;
    for (final d in displays) {
      final p = d.visiblePosition ?? const Offset(0, 0);
      final s = d.visibleSize ?? d.size;
      final c = Offset(p.dx + s.width / 2, p.dy + s.height / 2);
      final dx = c.dx - pt.dx, dy = c.dy - pt.dy;
      final d2 = dx * dx + dy * dy;
      if (d2 < best) { best = d2; bestD = d; }
    }
    return bestD;
  }
}
