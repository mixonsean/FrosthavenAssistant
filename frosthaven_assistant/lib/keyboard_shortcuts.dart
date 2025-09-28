import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum XhElement { fire, ice, air, earth, light, dark }

class XhKeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final void Function(XhElement e) onToggle;
  final VoidCallback? onToggleFullscreen; // NEW
  final VoidCallback? onNextInInitiative;   // NEW
  final VoidCallback? onPrevInInitiative;   // NEW
  

  const XhKeyboardShortcuts({
    super.key,
    required this.child,
    required this.onToggle,
    this.onToggleFullscreen, // NEW
    this.onNextInInitiative,                // NEW
    this.onPrevInInitiative,                // NEW
    
  });

  static final _digitToElem = <LogicalKeyboardKey, XhElement>{
    LogicalKeyboardKey.f1: XhElement.fire,
    LogicalKeyboardKey.f2: XhElement.ice,
    LogicalKeyboardKey.f3: XhElement.air,
    LogicalKeyboardKey.f4: XhElement.earth,
    LogicalKeyboardKey.f5: XhElement.light,
    LogicalKeyboardKey.f6: XhElement.dark,
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
        // TAB / Shift+TAB for initiative navigation
        if (event.logicalKey == LogicalKeyboardKey.tab) {
          final keys = HardwareKeyboard.instance.logicalKeysPressed;
          final isShift = keys.contains(LogicalKeyboardKey.shiftLeft) ||
                          keys.contains(LogicalKeyboardKey.shiftRight);
          if (isShift) {
            onPrevInInitiative?.call();
          } else {
            onNextInInitiative?.call();
          }
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
