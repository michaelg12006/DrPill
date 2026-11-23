import 'package:flutter/material.dart';
import 'dart:math';

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset origin;

  CircularRevealRoute({
    required this.page,
    required this.origin,
  }) : super(
          transitionDuration: const Duration(milliseconds: 900),
          reverseTransitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (context, animation, secondaryAnimation) {
            return page;
          },
          transitionsBuilder:
              (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            );

            return AnimatedBuilder(
              animation: curvedAnimation,
              builder: (context, child) {
                return ClipPath(
                  clipper: CircleRevealClipper(
                    fraction: curvedAnimation.value,
                    origin: origin,
                  ),
                  child: child,
                );
              },
              child: child,
            );
          },
        );
}

class CircleRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset origin;

  CircleRevealClipper({
    required this.fraction,
    required this.origin,
  });

  @override
  Path getClip(Size size) {
    final topLeft = origin;
    final topRight = Offset(size.width, 0);
    final bottomLeft = Offset(0, size.height);
    final bottomRight = Offset(size.width, size.height);

    // Find the farthest corner from the button.
    final maxRadius = [
      (topLeft - origin).distance,
      (topRight - origin).distance,
      (bottomLeft - origin).distance,
      (bottomRight - origin).distance,
    ].reduce(max);

    final radius = maxRadius * fraction;

    return Path()
      ..addOval(
        Rect.fromCircle(
          center: origin,
          radius: radius,
        ),
      );
  }

  @override
  bool shouldReclip(CircleRevealClipper oldClipper) {
    return oldClipper.fraction != fraction ||
        oldClipper.origin != origin;
  }
}