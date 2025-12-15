import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class TrafficLightMarkerWidget extends StatelessWidget {
  final String name;
  final String status;
  final int countdown;
  final double distance;
  final bool isPriority;
  final VoidCallback onTap;

  const TrafficLightMarkerWidget({
    Key? key,
    required this.name,
    required this.status,
    required this.countdown,
    required this.distance,
    required this.isPriority,
    required this.onTap,
  }) : super(key: key);

  Color _getStatusColor() {
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

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        width: 160,
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPriority
                ? Color(0xFFFF6B35)
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isPriority ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isPriority
                  ? Color(0xFFFF6B35).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.2),
              blurRadius: isPriority ? 12 : 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: _getStatusColor(),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _getStatusColor().withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    name,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isPriority)
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6B35),
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'priority_high',
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${countdown}s',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: _getStatusColor(),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Changement',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${distance.toStringAsFixed(0)}m',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Distance',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
