import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TrafficLightDetailSheetWidget extends StatelessWidget {
  final Map<String, dynamic> trafficLight;
  final VoidCallback onClose;
  final VoidCallback onNavigate;

  const TrafficLightDetailSheetWidget({
    Key? key,
    required this.trafficLight,
    required this.onClose,
    required this.onNavigate,
  }) : super(key: key);

  Color _getStatusColor(String status) {
    switch (status) {
      case 'green':
        return Color(0xFF00C853);
      case 'yellow':
        return Color(0xFFFFD600);
      case 'red':
        return Color(0xFFFF1744);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final String name = trafficLight["name"] as String;
    final String status = trafficLight["status"] as String;
    final int countdown = trafficLight["countdown"] as int;
    final double distance = trafficLight["distance"] as double;
    final bool isPriority = trafficLight["isPriority"] as bool;
    final String nextChange = trafficLight["nextChange"] as String;

    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getStatusColor(status).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: _getStatusColor(status),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color:
                                _getStatusColor(status).withValues(alpha: 0.5),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        nextChange,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onClose();
                  },
                ),
              ],
            ),
          ),

          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
            height: 1,
          ),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: 'timer',
                          label: 'Compte à rebours',
                          value: '${countdown}s',
                          color: _getStatusColor(status),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          context: context,
                          icon: 'near_me',
                          label: 'Distance',
                          value: '${distance.toStringAsFixed(0)}m',
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Priority badge
                  if (isPriority)
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFFFF6B35).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color(0xFFFF6B35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'priority_high',
                            color: Color(0xFFFF6B35),
                            size: 20,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Véhicule prioritaire détecté à proximité',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Color(0xFFFF6B35),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  Spacer(),

                  // Navigate button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onNavigate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'navigation',
                            color: Colors.black,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Naviguer vers ce feu',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required BuildContext context,
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: color,
            size: 24,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
