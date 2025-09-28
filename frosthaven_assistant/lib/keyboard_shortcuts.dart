import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum XhElement { fire, ice, air, earth, light, dark }

class XhKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final void Function(XhElement e) onToggle;
  final VoidCallback? onToggleFullscreen; // NEW

  const XhKeyboardShortcuts({
    super.key,
    required this.child,
    required this.onToggle,
    this.onToggleFullscreen, // NEW
  });

  static final _digitToElem = <LogicalKeyboardKey, XhElement>{
    LogicalKeyboardKey.digit1: XhElement.fire,
    LogicalKeyboardKey.digit2: XhElement.ice,
    LogicalKeyboardKey.digit3: XhElement.air,
    LogicalKeyboardKey.digit4: XhElement.earth,
    LogicalKeyboardKey.digit5: XhElement.light,
    LogicalKeyboardKey.digit6: XhElement.dark,
    LogicalKeyboardKey.numpad1: XhElement.fire,
    LogicalKeyboardKey.numpad2: XhElement.ice,
    LogicalKeyboardKey.numpad3: XhElement.air,
    LogicalKeyboardKey.numpad4: XhElement.earth,
    LogicalKeyboardKey.numpad5: XhElement.light,
    LogicalKeyboardKey.numpad6: XhElement.dark,
  };

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent) return KeyEventResult.ignored;

        // F11 fullscreen toggle
        if (event.logicalKey == LogicalKeyboardKey.f11) {
          onToggleFullscreen?.call();
          return KeyEventResult.handled;
        }

        // Element toggle 1..6
        final elem = _digitToElem[event.logicalKey];
        if (elem == null) return KeyEventResult.ignored;

        onToggle(elem);
        return KeyEventResult.handled;
      },
      child: child,
    );
  }
}
