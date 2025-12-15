import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget displaying individual statistic with chart visualization
class StatisticCardWidget extends StatefulWidget {
  final String title;
  final String value;
  final String unit;
  final String change;
  final List<double> chartData;
  final Color chartColor;
  final VoidCallback? onTap;

  const StatisticCardWidget({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.change,
    required this.chartData,
    required this.chartColor,
    this.onTap,
  }) : super(key: key);

  @override
  State<StatisticCardWidget> createState() => _StatisticCardWidgetState();
}

class _StatisticCardWidgetState extends State<StatisticCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _animationController.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _animationController.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _animationController.reverse();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isPressed
                      ? widget.chartColor.withValues(alpha: 0.5)
                      : theme.colorScheme.surface,
                  width: 1,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: widget.chartColor.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurfaceVariant,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: _getChangeColor(widget.change)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          widget.change,
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w500,
                            color: _getChangeColor(widget.change),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.value,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                          height: 1.0,
                        ),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        widget.unit,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  SizedBox(
                    height: 12.h,
                    child: Semantics(
                      label: '${widget.title} chart showing trend data',
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: false),
                          titlesData: FlTitlesData(show: false),
                          borderData: FlBorderData(show: false),
                          minX: 0,
                          maxX: (widget.chartData.length - 1).toDouble(),
                          minY:
                              widget.chartData.reduce((a, b) => a < b ? a : b) *
                                  0.9,
                          maxY:
                              widget.chartData.reduce((a, b) => a > b ? a : b) *
                                  1.1,
                          lineBarsData: [
                            LineChartBarData(
                              spots: widget.chartData
                                  .asMap()
                                  .entries
                                  .map((e) => FlSpot(e.key.toDouble(), e.value))
                                  .toList(),
                              isCurved: true,
                              color: widget.chartColor,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: false),
                              belowBarData: BarAreaData(
                                show: true,
                                color: widget.chartColor.withValues(alpha: 0.2),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(enabled: false),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getChangeColor(String change) {
    if (change.startsWith('+')) {
      return Color(0xFF00C853);
    } else if (change.startsWith('-')) {
      return Color(0xFFFF1744);
    }
    return Color(0xFFFFD600);
  }
}
