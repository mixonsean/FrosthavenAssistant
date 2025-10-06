import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

enum XhElement { fire, ice, air, earth, light, dark }

class XhKeyboardShortcuts extends StatefulWidget {
  final Widget child;
  final void Function(XhElement e) onToggle;
  final VoidCallback? onToggleFullscreen;
  final VoidCallback? onNextInInitiative;
  final VoidCallback? onPrevInInitiative;

  const XhKeyboardShortcuts({
    super.key,
    required this.child,
    required this.onToggle,
    this.onToggleFullscreen,
    this.onNextInInitiative,
    this.onPrevInInitiative,
  });

  @override
  State<XhKeyboardShortcuts> createState() => _XhKeyboardShortcutsState();
}

class _XhKeyboardShortcutsState extends State<XhKeyboardShortcuts> {
  late final FocusNode _focusNode;

  static final _digitToElem = <LogicalKeyboardKey, XhElement>{
    LogicalKeyboardKey.f1: XhElement.fire,
    LogicalKeyboardKey.f2: XhElement.ice,
    LogicalKeyboardKey.f3: XhElement.air,
    LogicalKeyboardKey.f4: XhElement.earth,
    LogicalKeyboardKey.f5: XhElement.light,
    LogicalKeyboardKey.f6: XhElement.dark,
  };

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    // Request focus immediately
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _ensureFocus() {
    if (!_focusNode.hasFocus) {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _ensureFocus,
      behavior: HitTestBehavior.translucent,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: (node, event) {
          if (event is! KeyDownEvent) return KeyEventResult.ignored;

          // F11 fullscreen toggle
          if (event.logicalKey == LogicalKeyboardKey.f11) {
            widget.onToggleFullscreen?.call();
            // Re-request focus after fullscreen toggle
            Future.delayed(const Duration(milliseconds: 100), _ensureFocus);
            return KeyEventResult.handled;
          }

          // TAB / Shift+TAB for initiative navigation
          if (event.logicalKey == LogicalKeyboardKey.tab) {
            final keys = HardwareKeyboard.instance.logicalKeysPressed;
            final isShift = keys.contains(LogicalKeyboardKey.shiftLeft) ||
                keys.contains(LogicalKeyboardKey.shiftRight);
            if (isShift) {
              widget.onPrevInInitiative?.call();
            } else {
              widget.onNextInInitiative?.call();
            }
            return KeyEventResult.handled;
          }

          // Element toggle F1..F6
          final elem = _digitToElem[event.logicalKey];
          if (elem == null) return KeyEventResult.ignored;

          widget.onToggle(elem);
          return KeyEventResult.handled;
        },
        child: widget.child,
      ),
    );
  }
}