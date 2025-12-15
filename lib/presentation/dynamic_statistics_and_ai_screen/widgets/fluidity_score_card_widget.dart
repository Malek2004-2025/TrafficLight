import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'dart:math' as math;

/// Widget displaying the current fluidity score with animated progress ring
class FluidityScoreCardWidget extends StatefulWidget {
  final double score;
  final String trend;

  const FluidityScoreCardWidget({
    Key? key,
    required this.score,
    required this.trend,
  }) : super(key: key);

  @override
  State<FluidityScoreCardWidget> createState() =>
      _FluidityScoreCardWidgetState();
}

class _FluidityScoreCardWidgetState extends State<FluidityScoreCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.score,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void didUpdateWidget(FluidityScoreCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _scoreAnimation = Tween<double>(
        begin: oldWidget.score,
        end: widget.score,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ));
      _animationController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Color(0xFF00C853);
    if (score >= 60) return Color(0xFFFFD600);
    if (score >= 40) return Color(0xFFFF6B35);
    return Color(0xFFFF1744);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Score de Fluidité',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.15,
            ),
          ),
          SizedBox(height: 3.h),
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 40.w,
                    height: 40.w,
                    child: CustomPaint(
                      painter: _ProgressRingPainter(
                        progress: _scoreAnimation.value / 100,
                        color: _getScoreColor(_scoreAnimation.value),
                        backgroundColor:
                            theme.colorScheme.surface.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${_scoreAnimation.value.toInt()}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: _getScoreColor(_scoreAnimation.value),
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '/100',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: _getTrendColor(widget.trend).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getTrendIcon(widget.trend),
                  size: 16,
                  color: _getTrendColor(widget.trend),
                ),
                SizedBox(width: 1.w),
                Text(
                  widget.trend,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: _getTrendColor(widget.trend),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getTrendColor(String trend) {
    if (trend.contains('↑') || trend.toLowerCase().contains('amélioration')) {
      return Color(0xFF00C853);
    } else if (trend.contains('↓') || trend.toLowerCase().contains('baisse')) {
      return Color(0xFFFF1744);
    }
    return Color(0xFFFFD600);
  }

  IconData _getTrendIcon(String trend) {
    if (trend.contains('↑') || trend.toLowerCase().contains('amélioration')) {
      return Icons.trending_up;
    } else if (trend.contains('↓') || trend.toLowerCase().contains('baisse')) {
      return Icons.trending_down;
    }
    return Icons.trending_flat;
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final strokeWidth = 12.0;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
