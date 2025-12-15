import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Social login options widget with Google and Apple sign-in
class SocialLoginWidget extends StatelessWidget {
  final VoidCallback onLoginSuccess;

  const SocialLoginWidget({
    Key? key,
    required this.onLoginSuccess,
  }) : super(key: key);

  void _handleGoogleLogin(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connexion Google - Fonctionnalité à venir',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00E5FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleAppleLogin(BuildContext context) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connexion Apple - Fonctionnalité à venir',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF00E5FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Divider with text
        Row(
          children: [
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline,
                thickness: 1,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                'OU',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: theme.colorScheme.outline,
                thickness: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.h),
        // Social login buttons
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                context: context,
                icon: 'g_translate',
                label: 'Google',
                onTap: () => _handleGoogleLogin(context),
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: _buildSocialButton(
                context: context,
                icon: 'apple',
                label: 'Apple',
                onTap: () => _handleAppleLogin(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required BuildContext context,
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 2.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outline,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.onSurface,
              size: 5.w,
            ),
            SizedBox(width: 2.w),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
