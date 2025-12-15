import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './widgets/app_logo_widget.dart';
import './widgets/login_form_widget.dart';
import './widgets/social_login_widget.dart';


/// Authentication Screen for SmartTraffic application
/// Implements Firebase Authentication with glassmorphism effects and blue/cyan gradient
class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({Key? key}) : super(key: key);

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleLoginSuccess() {
    HapticFeedback.mediumImpact();
    Navigator.pushReplacementNamed(context, '/real-time-traffic-lights-screen');
  }

  void _handleSignUpTap() {
    HapticFeedback.lightImpact();
    // Navigate to sign up screen (would be implemented separately)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Inscription - Fonctionnalité à venir',
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

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1A1A),
              Color(0xFF00E5FF).withValues(alpha: 0.1),
              Color(0xFF1A1A1A),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height -
                      MediaQuery.of(context).padding.top -
                      MediaQuery.of(context).padding.bottom,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 4.h),
                            // App Logo
                            AppLogoWidget(),
                            SizedBox(height: 6.h),
                            // Login Form
                            LoginFormWidget(
                              onLoginSuccess: _handleLoginSuccess,
                            ),
                            SizedBox(height: 4.h),
                            // Social Login Options
                            SocialLoginWidget(
                              onLoginSuccess: _handleLoginSuccess,
                            ),
                            SizedBox(height: 4.h),
                            // Sign Up Link
                            _buildSignUpLink(theme),
                            SizedBox(height: 4.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink(ThemeData theme) {
    return Center(
      child: GestureDetector(
        onTap: _handleSignUpTap,
        child: RichText(
          text: TextSpan(
            text: 'Nouveau conducteur? ',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            children: [
              TextSpan(
                text: 'Inscrivez-vous',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
