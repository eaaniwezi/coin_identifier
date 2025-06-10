// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'dart:math' as math;

class ConfidenceIndicator extends StatefulWidget {
  final double confidence;
  final double size;
  final bool showPercentage;
  final bool animated;

  const ConfidenceIndicator({
    Key? key,
    required this.confidence,
    this.size = 60,
    this.showPercentage = true,
    this.animated = true,
  }) : super(key: key);

  @override
  State<ConfidenceIndicator> createState() => _ConfidenceIndicatorState();
}

class _ConfidenceIndicatorState extends State<ConfidenceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: widget.confidence / 100).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutCubic,
      ),
    );

    if (widget.animated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ConfidencePainter(
              progress: _animation.value,
              confidence: widget.confidence,
            ),
            child:
                widget.showPercentage
                    ? Center(
                      child: Text(
                        '${(widget.confidence * _animation.value).toInt()}%',
                        style: TextStyle(
                          fontSize: widget.size * 0.2,
                          fontWeight: FontWeight.bold,
                          color: _getConfidenceColor(widget.confidence),
                        ),
                      ),
                    )
                    : null,
          );
        },
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green[600]!;
    } else if (confidence >= 60) {
      return Colors.orange[600]!;
    } else if (confidence >= 40) {
      return Colors.amber[600]!;
    } else {
      return Colors.red[600]!;
    }
  }
}

class ConfidencePainter extends CustomPainter {
  final double progress;
  final double confidence;

  ConfidencePainter({required this.progress, required this.confidence});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final backgroundPaint =
        Paint()
          ..color = Colors.grey[200]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint =
        Paint()
          ..color = _getConfidenceColor(confidence)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    const startAngle = -math.pi / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    _drawConfidenceDots(canvas, center, radius);
  }

  void _drawConfidenceDots(Canvas canvas, Offset center, double radius) {
    final dotPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    final dotBorderPaint =
        Paint()
          ..color = Colors.grey[400]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1;

    final levels = [0.25, 0.5, 0.75, 1.0];

    for (final level in levels) {
      final angle = -math.pi / 2 + (2 * math.pi * level);
      final dotX = center.dx + (radius + 4) * math.cos(angle);
      final dotY = center.dy + (radius + 4) * math.sin(angle);
      final dotCenter = Offset(dotX, dotY);

      final shouldFill = progress >= level;

      if (shouldFill) {
        dotPaint.color = _getConfidenceColor(confidence);
        canvas.drawCircle(dotCenter, 3, dotPaint);
      } else {
        canvas.drawCircle(dotCenter, 3, dotBorderPaint);
      }
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green[600]!;
    } else if (confidence >= 60) {
      return Colors.orange[600]!;
    } else if (confidence >= 40) {
      return Colors.amber[600]!;
    } else {
      return Colors.red[600]!;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class SimpleConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final double width;
  final double height;

  const SimpleConfidenceIndicator({
    Key? key,
    required this.confidence,
    this.width = 100,
    this.height = 8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          Container(
            width: width * (confidence / 100),
            height: height,
            decoration: BoxDecoration(
              color: _getConfidenceColor(confidence),
              borderRadius: BorderRadius.circular(height / 2),
            ),
          ),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 80) {
      return Colors.green[600]!;
    } else if (confidence >= 60) {
      return Colors.orange[600]!;
    } else if (confidence >= 40) {
      return Colors.amber[600]!;
    } else {
      return Colors.red[600]!;
    }
  }
}
