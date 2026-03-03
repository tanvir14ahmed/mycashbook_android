import 'package:flutter/material.dart';

class LiquidTransition extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const LiquidTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<LiquidTransition> createState() => _LiquidTransitionState();
}

class _LiquidTransitionState extends State<LiquidTransition> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            widget.child,
            // Liquid Overlay
            IgnorePointer(
              child: ClipPath(
                clipper: LiquidClipper(_animation.value),
                child: Container(
                  color: Colors.orange,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LiquidClipper extends CustomClipper<Path> {
  final double progress;
  LiquidClipper(this.progress);

  @override
  Path getClip(Size size) {
    var path = Path();
    if (progress < 0.5) {
      // Swipe in
      double p = progress / 0.5;
      path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.height * (1 - p) * 1.5,
      ));
      // Inverse the path to fill outside
      var fullRect = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
      return Path.combine(PathOperation.difference, fullRect, path);
    } else {
      // Fade out
      return Path(); // No clip = show everything (but the overlay color should fade)
      // Actually, let's just use it to swipe out
    }
  }

  @override
  bool shouldReclip(covariant LiquidClipper oldClipper) => oldClipper.progress != progress;
}

// Simple Fade wrapper for easier use
class SoothingPageTransition extends PageRouteBuilder {
  final Widget page;
  SoothingPageTransition({required this.page}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}
