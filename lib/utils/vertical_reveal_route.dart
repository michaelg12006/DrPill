import 'package:flutter/material.dart';

class VerticalRevealRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  VerticalRevealRoute({
    required this.page,
  }) : super(
          opaque: false,
          transitionDuration: const Duration(milliseconds: 1200),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) {
            return page;
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
              reverseCurve: Curves.easeInOutCubic,
            );

            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            );
          },
        );
}