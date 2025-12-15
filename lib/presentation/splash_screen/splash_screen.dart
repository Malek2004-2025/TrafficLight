import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen - Branded app launch with IoT initialization
/// Displays app logo with pulse animation while establishing Firebase connections
/// Handles authentication status check and navigation routing
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isInitializing = true;
  bool _showRetry = false;
  String _statusMessage = 'Initialisation des connexions IoT...';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  /// Setup pulse animation for logo
  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  /// Initialize app with IoT connections and authentication check
  Future<void> _initializeApp() async {
    try {
      setState(() {
        _isInitializing = true;
        _showRetry = false;
        _statusMessage = 'Initialisation des connexions IoT...';
      });

      // Simulate Firebase Realtime Database initialization
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _statusMessage = 'Connexion à Firebase...');

      // Simulate authentication status check
      await Future.delayed(const Duration(milliseconds: 600));
      setState(() => _statusMessage = 'Vérification de l\'authentification...');

      // Simulate traffic light data cache loading
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _statusMessage = 'Chargement des données de trafic...');

      // Simulate location services preparation
      await Future.delayed(const Duration(milliseconds: 400));
      setState(
          () => _statusMessage = 'Préparation des services de localisation...');

      // Wait minimum splash duration
      await Future.delayed(const Duration(milliseconds: 700));

      // Simulate authentication check result
      final bool isAuthenticated = _checkAuthenticationStatus();

      if (!mounted) return;

      // Provide haptic feedback before navigation
      HapticFeedback.lightImpact();

      // Navigate based on authentication status
      if (isAuthenticated) {
        Navigator.pushReplacementNamed(
            context, '/real-time-traffic-lights-screen');
      } else {
        Navigator.pushReplacementNamed(context, '/authentication-screen');
      }
    } catch (e) {
      // Handle initialization errors
      if (!mounted) return;
      setState(() {
        _isInitializing = false;
        _showRetry = true;
        _statusMessage = 'Erreur de connexion IoT';
      });

      // Auto-retry after 5 seconds
      Timer(const Duration(seconds: 5), () {
        if (mounted && _showRetry) {
          _initializeApp();
        }
      });
    }
  }

  /// Check authentication status (simulated)
  bool _checkAuthenticationStatus() {
    // In production, this would check Firebase Auth state
    // For now, simulate returning user scenario
    return false; // Return false to show authentication screen
  }

  /// Retry initialization on connection timeout
  void _retryInitialization() {
    HapticFeedback.lightImpact();
    _initializeApp();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Hide status bar on Android, use dark overlay on iOS
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF1A1A1A),
              const Color(0xFF0D1B2A),
              const Color(0xFF1A1A1A),
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              _buildLogo(theme),
              SizedBox(height: 8.h),
              _buildAppName(theme),
              const Spacer(flex: 1),
              _buildLoadingIndicator(theme),
              SizedBox(height: 3.h),
              _buildStatusMessage(theme),
              if (_showRetry) ...[
                SizedBox(height: 4.h),
                _buildRetryButton(theme),
              ],
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  /// Build animated logo with pulse effect
  Widget _buildLogo(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.3),
                  theme.colorScheme.primary.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.7, 1.0],
              ),
            ),
            child: Center(
              child: Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Center(
                  child: CustomIconWidget(
                    iconName: 'traffic',
                    color: const Color(0xFF000000),
                    size: 10.w,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build app name with neon styling
  Widget _buildAppName(ThemeData theme) {
    return Text(
      'SmartTraffic',
      style: theme.textTheme.headlineLarge?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        shadows: [
          Shadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
            blurRadius: 16,
          ),
        ],
      ),
    );
  }

  /// Build loading indicator with IoT connectivity progress
  Widget _buildLoadingIndicator(ThemeData theme) {
    if (!_isInitializing && _showRetry) {
      return Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: theme.colorScheme.error,
            width: 2,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'error_outline',
            color: theme.colorScheme.error,
            size: 6.w,
          ),
        ),
      );
    }

    return SizedBox(
      width: 12.w,
      height: 12.w,
      child: CircularProgressIndicator(
        strokeWidth: 3,
        valueColor: AlwaysStoppedAnimation<Color>(
          theme.colorScheme.primary,
        ),
      ),
    );
  }

  /// Build status message
  Widget _buildStatusMessage(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w),
      child: Text(
        _statusMessage,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: _showRetry
              ? theme.colorScheme.error
              : theme.colorScheme.onSurfaceVariant,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Build retry button for connection timeout
  Widget _buildRetryButton(ThemeData theme) {
    return ElevatedButton.icon(
      onPressed: _retryInitialization,
      icon: CustomIconWidget(
        iconName: 'refresh',
        color: const Color(0xFF000000),
        size: 5.w,
      ),
      label: Text(
        'Réessayer',
        style: theme.textTheme.labelLarge?.copyWith(
          color: const Color(0xFF000000),
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: const Color(0xFF000000),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    );
  }
}
