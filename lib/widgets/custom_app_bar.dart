import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar variants for different screen contexts
enum CustomAppBarVariant {
  standard,
  transparent,
  search,
  minimal,
}

/// Custom app bar optimized for real-time traffic management application
/// Implements clean information architecture with contextual actions
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final CustomAppBarVariant variant;
  final VoidCallback? onBackPressed;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.variant = CustomAppBarVariant.standard,
    this.onBackPressed,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    switch (variant) {
      case CustomAppBarVariant.transparent:
        return _buildTransparentAppBar(context, theme);
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, theme);
      case CustomAppBarVariant.minimal:
        return _buildMinimalAppBar(context, theme);
      case CustomAppBarVariant.standard:
      default:
        return _buildStandardAppBar(context, theme);
    }
  }

  Widget _buildStandardAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? theme.appBarTheme.foregroundColor,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      leading: leading ?? _buildLeading(context, theme),
      actions: actions,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildTransparentAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: foregroundColor ?? Colors.white,
          letterSpacing: 0.15,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: foregroundColor ?? Colors.white,
      leading: leading ?? _buildLeading(context, theme, isTransparent: true),
      actions: actions?.map((action) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            shape: BoxShape.circle,
          ),
          child: action,
        );
      }).toList(),
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildSearchAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Container(
        height: 44,
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF2A2A2A),
            width: 1,
          ),
        ),
        child: TextField(
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
          decoration: InputDecoration(
            hintText: title,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Color(0xFFB0BEC5).withValues(alpha: 0.6),
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Color(0xFFB0BEC5),
              size: 24,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          ),
          onTap: () {
            HapticFeedback.lightImpact();
          },
        ),
      ),
      centerTitle: false,
      elevation: elevation,
      backgroundColor: backgroundColor ?? theme.appBarTheme.backgroundColor,
      leading: leading ?? _buildLeading(context, theme),
      actions: actions,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Widget _buildMinimalAppBar(BuildContext context, ThemeData theme) {
    return AppBar(
      title: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: foregroundColor ?? theme.appBarTheme.foregroundColor,
          letterSpacing: 0.15,
        ),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? theme.appBarTheme.foregroundColor,
      leading: leading ?? _buildLeading(context, theme),
      actions: actions,
      bottom: bottom,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, ThemeData theme,
      {bool isTransparent = false}) {
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(Icons.arrow_back),
        iconSize: 24,
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
        style: isTransparent
            ? IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.3),
              )
            : null,
      );
    }
    return null;
  }
}

/// App bar with real-time traffic status indicator
class CustomAppBarWithStatus extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String statusText;
  final Color statusColor;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final VoidCallback? onBackPressed;

  const CustomAppBarWithStatus({
    Key? key,
    required this.title,
    required this.statusText,
    required this.statusColor,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: theme.appBarTheme.foregroundColor,
              letterSpacing: 0.15,
            ),
          ),
          SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 6),
              Text(
                statusText,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFFB0BEC5),
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: theme.appBarTheme.backgroundColor,
      foregroundColor: theme.appBarTheme.foregroundColor,
      leading: leading ?? _buildLeading(context, theme),
      actions: actions,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (Navigator.of(context).canPop()) {
      return IconButton(
        icon: Icon(Icons.arrow_back),
        iconSize: 24,
        padding: EdgeInsets.all(12),
        constraints: BoxConstraints(
          minWidth: 48,
          minHeight: 48,
        ),
        onPressed: () {
          HapticFeedback.lightImpact();
          if (onBackPressed != null) {
            onBackPressed!();
          } else {
            Navigator.of(context).pop();
          }
        },
      );
    }
    return null;
  }
}

/// App bar with gradient background for map overlays
class CustomAppBarGradient extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final VoidCallback? onBackPressed;
  final List<Color>? gradientColors;

  const CustomAppBarGradient({
    Key? key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.onBackPressed,
    this.gradientColors,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = gradientColors ??
        [
          Color(0xFF1A1A1A),
          Color(0xFF1A1A1A).withValues(alpha: 0.0),
        ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors,
        ),
      ),
      child: AppBar(
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.15,
          ),
        ),
        centerTitle: centerTitle,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        leading: leading ?? _buildLeading(context, theme),
        actions: actions,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context, ThemeData theme) {
    if (Navigator.of(context).canPop()) {
      return Container(
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back),
          iconSize: 24,
          padding: EdgeInsets.all(8),
          constraints: BoxConstraints(
            minWidth: 40,
            minHeight: 40,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            if (onBackPressed != null) {
              onBackPressed!();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      );
    }
    return null;
  }
}

