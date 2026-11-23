
import 'package:flutter/material.dart';

class NavbarPageTransition extends StatelessWidget {
  final Widget child;
  final int currentIndex;
  final int previousIndex;

  const NavbarPageTransition({
    super.key,
    required this.child,
    required this.currentIndex,
    required this.previousIndex,
  });

  @override
  Widget build(BuildContext context) {
    final forward = currentIndex > previousIndex;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,

      transitionBuilder: (child, animation) {
        final isIncoming = child.key == ValueKey(currentIndex);

        final offset = isIncoming
            ? Offset(forward ? 1.0 : -1.0, 0)
            : Offset(forward ? -1.0 : 1.0, 0);

        return ClipRect(
          child: FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: offset,
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
        );
      },

      child: KeyedSubtree(
        key: ValueKey(currentIndex),
        child: child,
      ),
    );
  }
}
