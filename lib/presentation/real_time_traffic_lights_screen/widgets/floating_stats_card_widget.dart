import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FloatingStatsCardWidget extends StatelessWidget {
  final int nearbyLights;
  final String lastUpdated;
  final bool isConnected;

  const FloatingStatsCardWidget({
    Key? key,
    required this.nearbyLights,
    required this.lastUpdated,
    required this.isConnected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isConnected ? Color(0xFF00C853) : Color(0xFFFF1744),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isConnected ? Color(0xFF00C853) : Color(0xFFFF1744))
                              .withValues(alpha: 0.5),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              Text(
                isConnected ? 'Connecté' : 'Déconnecté',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 20,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'traffic',
                color: theme.colorScheme.primary,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                '$nearbyLights feux',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 20,
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
          Row(
            children: [
              CustomIconWidget(
                iconName: 'access_time',
                color: theme.colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                lastUpdated,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
