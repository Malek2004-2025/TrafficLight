import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// App logo widget with glow effect for authentication screen
class AppLogoWidget extends StatelessWidget {
  const AppLogoWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.4),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primary.withValues(alpha: 0.7),
                  ],
                ),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: 'traffic',
                  color: Colors.black,
                  size: 12.w,
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'SmartTraffic',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Gestion Intelligente du Trafic',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
