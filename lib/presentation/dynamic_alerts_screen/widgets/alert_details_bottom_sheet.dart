import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Bottom sheet displaying detailed alert information with map integration
class AlertDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> alert;

  const AlertDetailsBottomSheet({
    Key? key,
    required this.alert,
  }) : super(key: key);

  Color _getSeverityColor() {
    switch (alert["severity"]) {
      case "critical":
        return AppTheme.errorColor;
      case "high":
        return AppTheme.accentColor;
      case "medium":
        return AppTheme.warningColor;
      case "low":
        return AppTheme.primaryLight;
      default:
        return Color(0xFFB0BEC5);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heures';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year} à ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  String _formatDistance(int distance) {
    if (distance < 1000) {
      return '$distance mètres';
    } else {
      return '${(distance / 1000).toStringAsFixed(2)} kilomètres';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2A2A2A),
                Color(0xFF1A1A1A),
              ],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 2.h),
                width: 10.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Color(0xFFB0BEC5).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(6.w),
                  children: [
                    // Header with icon and title
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(3.w),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                severityColor.withValues(alpha: 0.3),
                                severityColor.withValues(alpha: 0.1),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: severityColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: CustomIconWidget(
                            iconName: alert["icon"],
                            size: 32,
                            color: severityColor,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                alert["title"],
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 0.5.h),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: severityColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: severityColor.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  alert["severity"].toString().toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: severityColor,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    // Description
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A).withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFF2A2A2A),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        alert["description"],
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // Details grid
                    _buildDetailItem(
                      context: context,
                      icon: 'location_on',
                      label: 'Distance',
                      value: _formatDistance(alert["distance"]),
                    ),
                    SizedBox(height: 2.h),
                    _buildDetailItem(
                      context: context,
                      icon: 'access_time',
                      label: 'Horodatage',
                      value: _formatDateTime(alert["timestamp"]),
                    ),
                    if (alert["affectedLights"] != null) ...[
                      SizedBox(height: 2.h),
                      _buildDetailItem(
                        context: context,
                        icon: 'traffic',
                        label: 'Feux affectés',
                        value:
                            '${(alert["affectedLights"] as List).length} feux de circulation',
                      ),
                    ],
                    if (alert["estimatedClearTime"] != null) ...[
                      SizedBox(height: 2.h),
                      _buildDetailItem(
                        context: context,
                        icon: 'schedule',
                        label: 'Dégagement estimé',
                        value: _formatDateTime(alert["estimatedClearTime"]),
                      ),
                    ],
                    if (alert["estimatedArrival"] != null) ...[
                      SizedBox(height: 2.h),
                      _buildDetailItem(
                        context: context,
                        icon: 'timer',
                        label: 'Arrivée estimée',
                        value:
                            '${alert["estimatedArrival"].difference(DateTime.now()).inSeconds} secondes',
                      ),
                    ],
                    SizedBox(height: 3.h),
                    // Location map placeholder
                    Container(
                      height: 25.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF2A2A2A),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: severityColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Stack(
                        children: [
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'map',
                                  size: 48,
                                  color:
                                      Color(0xFFB0BEC5).withValues(alpha: 0.5),
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  'Carte de localisation',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Color(0xFFB0BEC5),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'Lat: ${alert["location"]["lat"]}, Lng: ${alert["location"]["lng"]}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: Color(0xFFB0BEC5)
                                        .withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 2.h,
                            right: 2.w,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.9),
                                shape: BoxShape.circle,
                              ),
                              child: CustomIconWidget(
                                iconName: 'location_on',
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              HapticFeedback.mediumImpact();
                              Navigator.pop(context);
                              Navigator.pushNamed(
                                  context, '/ai-dynamic-route-screen');
                            },
                            icon: CustomIconWidget(
                              iconName: 'navigation',
                              size: 20,
                              color: Colors.black,
                            ),
                            label: Text('Naviguer'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.black,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                            },
                            icon: CustomIconWidget(
                              iconName: 'share',
                              size: 20,
                              color: theme.colorScheme.primary,
                            ),
                            label: Text('Partager'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: theme.colorScheme.primary,
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              side: BorderSide(
                                color: theme.colorScheme.primary,
                                width: 2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color(0xFF2A2A2A).withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: icon,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Color(0xFFB0BEC5),
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
