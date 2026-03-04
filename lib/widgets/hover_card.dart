import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A card widget that responds to touch with a subtle 3D tilt effect.
/// Uses GestureDetector (works on Android) instead of MouseRegion (desktop-only).
class HoverCard extends StatefulWidget {
  final Widget child;
  final double tiltAmount;
  final Duration duration;

  const HoverCard({
    super.key,
    required this.child,
    this.tiltAmount = 0.04,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  State<HoverCard> createState() => _HoverCardState();
}

class _HoverCardState extends State<HoverCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _resetController;
  late Animation<double> _resetX;
  late Animation<double> _resetY;

  double _rotateX = 0;
  double _rotateY = 0;
  double _scale = 1.0;
  double _curX = 0;
  double _curY = 0;

  @override
  void initState() {
    super.initState();
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _resetX = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );
    _resetY = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );
    _resetController.addListener(() {
      setState(() {
        _rotateX = _resetX.value;
        _rotateY = _resetY.value;
      });
    });
  }

  @override
  void dispose() {
    _resetController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details, BoxConstraints constraints) {
    _resetController.stop();
    _curX = details.localPosition.dx;
    _curY = details.localPosition.dy;
    _updateTilt(constraints);
    setState(() => _scale = 1.03);
  }

  void _onPanUpdate(DragUpdateDetails details, BoxConstraints constraints) {
    _curX = details.localPosition.dx;
    _curY = details.localPosition.dy;
    _updateTilt(constraints);
  }

  void _updateTilt(BoxConstraints constraints) {
    final w = constraints.maxWidth;
    final h = constraints.maxHeight;
    // Normalize -1 to 1
    final nx = (_curX / w) * 2 - 1;
    final ny = (_curY / h) * 2 - 1;
    final maxTilt = widget.tiltAmount;
    setState(() {
      _rotateX = ny * maxTilt;
      _rotateY = -nx * maxTilt;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    _resetX = Tween<double>(begin: _rotateX, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );
    _resetY = Tween<double>(begin: _rotateY, end: 0).animate(
      CurvedAnimation(parent: _resetController, curve: Curves.elasticOut),
    );
    _resetController.forward(from: 0);
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onPanStart: (d) => _onPanStart(d, constraints),
          onPanUpdate: (d) => _onPanUpdate(d, constraints),
          onPanEnd: _onPanEnd,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: RepaintBoundary(
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateX(_rotateX)
                  ..rotateY(_rotateY),
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }
}
