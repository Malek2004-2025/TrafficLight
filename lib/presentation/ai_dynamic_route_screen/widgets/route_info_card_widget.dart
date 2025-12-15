import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/app_export.dart';

/// Route information card displaying ETA, fluidity score, and traffic metrics
class RouteInfoCardWidget extends StatelessWidget {
  final String eta;
  final int fluidityScore;
  final Color trafficDensityColor;
  final int trafficLightCount;
  final String estimatedWaitTime;

  const RouteInfoCardWidget({
    Key? key,
    required this.eta,
    required this.fluidityScore,
    required this.trafficDensityColor,
    required this.trafficLightCount,
    required this.estimatedWaitTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 90.w,
      constraints: BoxConstraints(maxWidth: 500),
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF2A2A2A).withValues(alpha: 0.95),
            Color(0xFF2A2A2A).withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Temps estimé',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Row(
                      children: [
                        Text(
                          eta,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: trafficDensityColor,
                            letterSpacing: 0,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          width: 1.5.w,
                          height: 1.5.w,
                          decoration: BoxDecoration(
                            color: trafficDensityColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color:
                      _getFluidityColor(fluidityScore).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getFluidityColor(fluidityScore),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Fluidité',
                      style: GoogleFonts.inter(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w400,
                        color: theme.colorScheme.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      '$fluidityScore',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: _getFluidityColor(fluidityScore),
                        letterSpacing: 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  context: context,
                  icon: 'traffic',
                  label: 'Feux',
                  value: '$trafficLightCount',
                  theme: theme,
                ),
              ),
              Container(
                width: 1,
                height: 4.h,
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              Expanded(
                child: _buildMetricItem(
                  context: context,
                  icon: 'schedule',
                  label: 'Attente',
                  value: estimatedWaitTime,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        CustomIconWidget(
          iconName: icon,
          color: theme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(height: 1.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10.sp,
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 0.4,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
            letterSpacing: 0,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Color _getFluidityColor(int score) {
    if (score >= 80) return Color(0xFF00C853);
    if (score >= 60) return Color(0xFFFFD600);
    if (score >= 40) return Color(0xFFFF6B35);
    return Color(0xFFFF1744);
  }
}
