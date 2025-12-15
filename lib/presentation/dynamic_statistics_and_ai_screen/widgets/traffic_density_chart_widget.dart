import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget displaying traffic density visualization with bar chart
class TrafficDensityChartWidget extends StatefulWidget {
  final List<Map<String, dynamic>> densityData;
  final String timeRange;

  const TrafficDensityChartWidget({
    super.key,
    required this.densityData,
    required this.timeRange,
  });

  @override
  State<TrafficDensityChartWidget> createState() =>
      _TrafficDensityChartWidgetState();
}

class _TrafficDensityChartWidgetState extends State<TrafficDensityChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int? _touchedIndex;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Densité du Trafic',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                  letterSpacing: 0.15,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: Color(0xFF00E5FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.timeRange,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF00E5FF),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          SizedBox(
            height: 25.h,
            child: Semantics(
              label: 'Traffic density bar chart for ${widget.timeRange}',
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 100,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          setState(() {
                            if (!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              _touchedIndex = null;
                              return;
                            }
                            _touchedIndex =
                                barTouchResponse.spot!.touchedBarGroupIndex;
                          });
                        },
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: theme.colorScheme.surface, // ✅ correct
                          tooltipPadding: EdgeInsets.all(8),
                          tooltipMargin: 8,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${widget.densityData[groupIndex]['label']}\n${rod.toY.toInt()}%',
                              GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: theme.colorScheme.onSurface,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < widget.densityData.length) {
                                return Padding(
                                  padding: EdgeInsets.only(top: 1.h),
                                  child: Text(
                                    widget.densityData[value.toInt()]['label'],
                                    style: GoogleFonts.inter(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.w400,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                );
                              }
                              return SizedBox.shrink();
                            },
                            reservedSize: 30,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${value.toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w400,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                            reservedSize: 40,
                            interval: 25,
                          ),
                        ),
                        topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 25,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.1),
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups:
                          widget.densityData.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final isTouched = index == _touchedIndex;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: (data['value'] as num).toDouble() *
                                  _animationController.value,
                              color: _getDensityColor(
                                  (data['value'] as num).toDouble()),
                              width: isTouched ? 20 : 16,
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 2.h),
          _buildLegend(theme),
        ],
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Faible', Color(0xFF00C853), theme),
        SizedBox(width: 4.w),
        _buildLegendItem('Moyen', Color(0xFFFFD600), theme),
        SizedBox(width: 4.w),
        _buildLegendItem('Élevé', Color(0xFFFF6B35), theme),
        SizedBox(width: 4.w),
        _buildLegendItem('Critique', Color(0xFFFF1744), theme),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Color _getDensityColor(double value) {
    if (value >= 80) return Color(0xFFFF1744);
    if (value >= 60) return Color(0xFFFF6B35);
    if (value >= 40) return Color(0xFFFFD600);
    return Color(0xFF00C853);
  }
}
