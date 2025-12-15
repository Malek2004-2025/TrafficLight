import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

/// Widget displaying AI-powered driving recommendations
class AiRecommendationCardWidget extends StatelessWidget {
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onActionTap;
  final IconData icon;

  const AiRecommendationCardWidget({
    Key? key,
    required this.title,
    required this.description,
    required this.actionLabel,
    this.onActionTap,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF00E5FF).withValues(alpha: 0.15),
            Color(0xFF00E5FF).withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF00E5FF).withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Color(0xFF00E5FF).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: _getIconName(icon),
                  color: Color(0xFF00E5FF),
                  size: 24,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.15,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.25,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 2.h),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onActionTap?.call();
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: Color(0xFF00E5FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    actionLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF000000),
                      letterSpacing: 1.25,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  CustomIconWidget(
                    iconName: 'arrow_forward',
                    color: Color(0xFF000000),
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getIconName(IconData icon) {
    if (icon == Icons.schedule) return 'schedule';
    if (icon == Icons.route) return 'route';
    if (icon == Icons.lightbulb_outline) return 'lightbulb_outline';
    if (icon == Icons.trending_up) return 'trending_up';
    return 'info';
  }
}
