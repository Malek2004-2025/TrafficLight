import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

/// Navigation item configuration for bottom bar
class CustomBottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;
  final int? badgeCount;

  const CustomBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
    this.badgeCount,
  });
}

/// Custom bottom navigation bar optimized for real-time traffic management
/// Implements thumb-optimized placement with contextual haptic feedback
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CustomBottomBarItem>? items;

  const CustomBottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  }) : super(key: key);

  /// Default navigation items based on Mobile Navigation Hierarchy
  static List<CustomBottomBarItem> get defaultItems => [
        CustomBottomBarItem(
          icon: Icons.traffic_outlined,
          activeIcon: Icons.traffic,
          label: 'Traffic',
          route: '/real-time-traffic-lights-screen',
        ),
        CustomBottomBarItem(
          icon: Icons.route_outlined,
          activeIcon: Icons.route,
          label: 'Route',
          route: '/ai-dynamic-route-screen',
        ),
        CustomBottomBarItem(
          icon: Icons.notifications_outlined,
          activeIcon: Icons.notifications,
          label: 'Alerts',
          route: '/dynamic-alerts-screen',
        ),
        CustomBottomBarItem(
          icon: Icons.bar_chart_outlined,
          activeIcon: Icons.bar_chart,
          label: 'Stats',
          route: '/dynamic-statistics-and-ai-screen',
        ),
        CustomBottomBarItem(
          icon: Icons.settings_outlined,
          activeIcon: Icons.settings,
          label: 'Settings',
          route: '/authentication-screen',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationItems = items ?? defaultItems;

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomNavigationBarTheme.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navigationItems.length,
              (index) => _buildNavigationItem(
                context: context,
                item: navigationItems[index],
                index: index,
                isSelected: currentIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationItem({
    required BuildContext context,
    required CustomBottomBarItem item,
    required int index,
    required bool isSelected,
  }) {
    final theme = Theme.of(context);
    final color = isSelected
        ? theme.bottomNavigationBarTheme.selectedItemColor!
        : theme.bottomNavigationBarTheme.unselectedItemColor!;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          // Provide haptic feedback for navigation
          HapticFeedback.lightImpact();
          
          // Navigate to the selected route
          if (!isSelected) {
            Navigator.pushNamed(context, item.route);
          }
          
          // Call the onTap callback
          onTap(index);
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with badge support
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.15)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isSelected && item.activeIcon != null
                          ? item.activeIcon
                          : item.icon,
                      size: 24,
                      color: color,
                    ),
                  ),
                  // Badge indicator for alerts
                  if (item.badgeCount != null && item.badgeCount! > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF6B35), // Emergency orange
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: theme.bottomNavigationBarTheme.backgroundColor!,
                            width: 2,
                          ),
                        ),
                        constraints: BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Center(
                          child: Text(
                            item.badgeCount! > 99 ? '99+' : '${item.badgeCount}',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 4),
              // Label
              AnimatedDefaultTextStyle(
                duration: Duration(milliseconds: 200),
                curve: Curves.easeOut,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                  color: color,
                  letterSpacing: 0.4,
                  height: 1.33,
                ),
                child: Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Variant of CustomBottomBar with glassmorphism effect
class CustomBottomBarGlass extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CustomBottomBarItem>? items;

  const CustomBottomBarGlass({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationItems = items ?? CustomBottomBar.defaultItems;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A2A2A).withValues(alpha: 0.8),
            Color(0xFF2A2A2A).withValues(alpha: 0.95),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: CustomBottomBar(
            currentIndex: currentIndex,
            onTap: onTap,
            items: navigationItems,
          ),
        ),
      ),
    );
  }
}

/// Variant with floating style for modern automotive UI
class CustomBottomBarFloating extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<CustomBottomBarItem>? items;

  const CustomBottomBarFloating({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final navigationItems = items ?? CustomBottomBar.defaultItems;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: CustomBottomBar(
          currentIndex: currentIndex,
          onTap: onTap,
          items: navigationItems,
        ),
      ),
    );
  }
}