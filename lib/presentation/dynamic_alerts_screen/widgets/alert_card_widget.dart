import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Alert card widget with glassmorphism styling and swipe actions
class AlertCardWidget extends StatefulWidget {
  final Map<String, dynamic> alert;
  final VoidCallback onTap;
  final VoidCallback onDismiss;
  final VoidCallback onMarkAsRead;
  final VoidCallback onLongPress;

  const AlertCardWidget({
    Key? key,
    required this.alert,
    required this.onTap,
    required this.onDismiss,
    required this.onMarkAsRead,
    required this.onLongPress,
  }) : super(key: key);

  @override
  State<AlertCardWidget> createState() => _AlertCardWidgetState();
}

class _AlertCardWidgetState extends State<AlertCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start pulse animation for critical and priority alerts
    if (widget.alert["severity"] == "critical" ||
        widget.alert["type"] == "priority_vehicle") {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Color _getSeverityColor() {
    switch (widget.alert["severity"]) {
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

  String _getTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'À l\'instant';
    } else if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return 'Il y a ${difference.inDays} j';
    }
  }

  String _formatDistance(int distance) {
    if (distance < 1000) {
      return '$distance m';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor();
    final isUnread = !widget.alert["isRead"];

    return Slidable(
      key: ValueKey(widget.alert["id"]),
      enabled: widget.alert["canDismiss"],
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              widget.onMarkAsRead();
            },
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.black,
            icon: Icons.done,
            label: 'Lu',
          ),
          if (widget.alert["canDismiss"])
            SlidableAction(
              onPressed: (context) {
                widget.onDismiss();
              },
              backgroundColor: AppTheme.errorColor,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Supprimer',
            ),
        ],
      ),
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onLongPress: widget.onLongPress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF2A2A2A).withValues(alpha: 0.9),
                  Color(0xFF2A2A2A).withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isUnread
                    ? severityColor.withValues(alpha: 0.5)
                    : Color(0xFF2A2A2A),
                width: isUnread ? 2 : 1,
              ),
              boxShadow: [
                if (isUnread)
                  BoxShadow(
                    color: severityColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
              ],
            ),
            child: Stack(
              children: [
                // Glow effect for critical alerts
                if (widget.alert["severity"] == "critical")
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: RadialGradient(
                          center: Alignment.topRight,
                          radius: 1.5,
                          colors: [
                            severityColor.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Alert icon with severity color
                          Container(
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: severityColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: CustomIconWidget(
                              iconName: widget.alert["icon"],
                              size: 24,
                              color: severityColor,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          // Title and metadata
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.alert["title"],
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                          fontWeight: isUnread
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: BoxDecoration(
                                          color: severityColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 0.5.h),
                                Row(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'location_on',
                                      size: 14,
                                      color: Color(0xFFB0BEC5),
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      _formatDistance(widget.alert["distance"]),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Color(0xFFB0BEC5),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    CustomIconWidget(
                                      iconName: 'access_time',
                                      size: 14,
                                      color: Color(0xFFB0BEC5),
                                    ),
                                    SizedBox(width: 1.w),
                                    Text(
                                      _getTimeAgo(widget.alert["timestamp"]),
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                        color: Color(0xFFB0BEC5),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      // Description
                      Text(
                        widget.alert["description"],
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Additional info based on alert type
                      if (widget.alert["type"] == "priority_vehicle") ...[
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color:
                                  AppTheme.accentColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'timer',
                                size: 16,
                                color: AppTheme.accentColor,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Arrivée estimée: ${widget.alert["estimatedArrival"].difference(DateTime.now()).inSeconds}s',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.accentColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (widget.alert["type"] == "emergency" &&
                          widget.alert["estimatedClearTime"] != null) ...[
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 1.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppTheme.errorColor.withValues(alpha: 0.5),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'schedule',
                                size: 16,
                                color: AppTheme.errorColor,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Dégagement estimé: ${widget.alert["estimatedClearTime"].difference(DateTime.now()).inMinutes} min',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppTheme.errorColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
