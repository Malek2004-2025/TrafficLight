import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/app_export.dart';

/// Individual route option item in the bottom sheet
class RouteOptionItemWidget extends StatelessWidget {
  final String routeName;
  final String eta;
  final String timeDifference;
  final int trafficLightCount;
  final String estimatedWaitTime;
  final double priorityVehicleProbability;
  final bool isSelected;
  final VoidCallback onTap;

  const RouteOptionItemWidget({
    Key? key,
    required this.routeName,
    required this.eta,
    required this.timeDifference,
    required this.trafficLightCount,
    required this.estimatedWaitTime,
    required this.priorityVehicleProbability,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(bottom: 2.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeName,
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                          letterSpacing: 0.1,
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
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                              letterSpacing: 0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: _getTimeDifferenceColor(timeDifference)
                                  .withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              timeDifference,
                              style: GoogleFonts.inter(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w500,
                                color: _getTimeDifferenceColor(timeDifference),
                                letterSpacing: 0.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'check',
                      color: Color(0xFF000000),
                      size: 16,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: _buildMetricChip(
                    context: context,
                    icon: 'traffic',
                    value: '$trafficLightCount feux',
                    theme: theme,
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: _buildMetricChip(
                    context: context,
                    icon: 'schedule',
                    value: estimatedWaitTime,
                    theme: theme,
                  ),
                ),
              ],
            ),
            if (priorityVehicleProbability > 0.3) ...[
              SizedBox(height: 1.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: Color(0xFFFF6B35).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Color(0xFFFF6B35),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'warning',
                      color: Color(0xFFFF6B35),
                      size: 14,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Text(
                        'Véhicule prioritaire probable (${(priorityVehicleProbability * 100).toInt()}%)',
                        style: GoogleFonts.inter(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFFFF6B35),
                          letterSpacing: 0.4,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip({
    required BuildContext context,
    required String icon,
    required String value,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.onSurfaceVariant,
            size: 14,
          ),
          SizedBox(width: 2.w),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.inter(
                fontSize: 11.sp,
                fontWeight: FontWeight.w400,
                color: theme.colorScheme.onSurfaceVariant,
                letterSpacing: 0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTimeDifferenceColor(String timeDiff) {
    if (timeDiff.startsWith('-')) return Color(0xFF00C853);
    if (timeDiff.startsWith('+')) return Color(0xFFFF6B35);
    return Color(0xFFFFD600);
  }
}
