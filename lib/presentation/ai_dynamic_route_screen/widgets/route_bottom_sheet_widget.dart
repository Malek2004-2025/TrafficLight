import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import './route_option_item_widget.dart';

/// Bottom sheet containing route options list
class RouteBottomSheetWidget extends StatelessWidget {
  final List<Map<String, dynamic>> routeOptions;
  final int selectedRouteIndex;
  final Function(int) onRouteSelected;

  const RouteBottomSheetWidget({
    Key? key,
    required this.routeOptions,
    required this.selectedRouteIndex,
    required this.onRouteSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: 50.h,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2A2A2A).withValues(alpha: 0.98),
            Color(0xFF2A2A2A),
          ],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 1.h),
          Container(
            width: 12.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(height: 2.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Options d\'itinéraire',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: 0.15,
                  ),
                ),
                Text(
                  '${routeOptions.length} routes',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: theme.colorScheme.onSurfaceVariant,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 2.h),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              itemCount: routeOptions.length,
              itemBuilder: (context, index) {
                final route = routeOptions[index];
                return RouteOptionItemWidget(
                  routeName: route['routeName'] as String,
                  eta: route['eta'] as String,
                  timeDifference: route['timeDifference'] as String,
                  trafficLightCount: route['trafficLightCount'] as int,
                  estimatedWaitTime: route['estimatedWaitTime'] as String,
                  priorityVehicleProbability:
                      route['priorityVehicleProbability'] as double,
                  isSelected: index == selectedRouteIndex,
                  onTap: () => onRouteSelected(index),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
