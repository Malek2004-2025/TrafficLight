import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import 'widgets/map_view_widget.dart';
import 'widgets/route_bottom_sheet_widget.dart';
import 'widgets/route_info_card_widget.dart';

class AiDynamicRouteScreen extends StatefulWidget {
  const AiDynamicRouteScreen({Key? key}) : super(key: key);

  @override
  State<AiDynamicRouteScreen> createState() => _AiDynamicRouteScreenState();
}

class _AiDynamicRouteScreenState extends State<AiDynamicRouteScreen>
    with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  int _selectedRouteIndex = 0;
  bool _isRecalculating = false;
  late AnimationController _pulseController;
  late AnimationController _recalculationController;

  // Mock data for routes
  final List<Map<String, dynamic>> _routeOptions = [
    {
      "routeName": "Itinéraire principal",
      "eta": "18 min",
      "timeDifference": "Optimal",
      "trafficLightCount": 8,
      "estimatedWaitTime": "4 min",
      "priorityVehicleProbability": 0.15,
      "fluidityScore": 85,
      "trafficDensityColor": Color(0xFF00C853),
    },
    {
      "routeName": "Via Avenue de la République",
      "eta": "22 min",
      "timeDifference": "+4 min",
      "trafficLightCount": 12,
      "estimatedWaitTime": "6 min",
      "priorityVehicleProbability": 0.45,
      "fluidityScore": 68,
      "trafficDensityColor": Color(0xFFFFD600),
    },
    {
      "routeName": "Boulevard périphérique",
      "eta": "16 min",
      "timeDifference": "-2 min",
      "trafficLightCount": 5,
      "estimatedWaitTime": "2 min",
      "priorityVehicleProbability": 0.08,
      "fluidityScore": 92,
      "trafficDensityColor": Color(0xFF00C853),
    },
  ];

  // Paris coordinates for demo
  final LatLng _initialPosition = LatLng(48.8566, 2.3522);
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeMapData();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _recalculationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  void _initializeMapData() {
    // Create primary route polyline
    _polylines.add(
      Polyline(
        polylineId: PolylineId('primary_route'),
        points: [
          _initialPosition,
          LatLng(48.8606, 2.3376),
          LatLng(48.8656, 2.3412),
        ],
        color: Color(0xFF00E5FF),
        width: 5,
        patterns: [PatternItem.dot, PatternItem.gap(10)],
      ),
    );

    // Create alternative route polylines
    _polylines.add(
      Polyline(
        polylineId: PolylineId('alternative_route_1'),
        points: [
          _initialPosition,
          LatLng(48.8526, 2.3456),
          LatLng(48.8656, 2.3412),
        ],
        color: Color(0xFFFF6B35).withValues(alpha: 0.6),
        width: 4,
      ),
    );

    // Add driver position marker
    _markers.add(
      Marker(
        markerId: MarkerId('driver_position'),
        position: _initialPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
      ),
    );

    // Add traffic light markers
    _markers.add(
      Marker(
        markerId: MarkerId('traffic_light_1'),
        position: LatLng(48.8606, 2.3376),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _recalculationController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
  }

  Future<void> _handleRouteSelection(int index) async {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedRouteIndex = index;
    });
    Navigator.pop(context);
  }

  Future<void> _handleManualRecalculation() async {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRecalculating = true;
    });

    _recalculationController.forward();

    await Future.delayed(Duration(seconds: 2));

    _recalculationController.reverse();
    setState(() {
      _isRecalculating = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Itinéraire recalculé avec succès',
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFF2A2A2A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showRouteOptions() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => RouteBottomSheetWidget(
        routeOptions: _routeOptions,
        selectedRouteIndex: _selectedRouteIndex,
        onRouteSelected: _handleRouteSelection,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentRoute = _routeOptions[_selectedRouteIndex];

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Itinéraire IA',
        variant: CustomAppBarVariant.transparent,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'settings',
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/authentication-screen');
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Map view
          MapViewWidget(
            mapController: _mapController,
            polylines: _polylines,
            markers: _markers,
            initialPosition: _initialPosition,
            onMapCreated: _onMapCreated,
          ),

          // Route info card
          Positioned(
            top: kToolbarHeight + 6.h,
            left: 0,
            right: 0,
            child: RouteInfoCardWidget(
              eta: currentRoute['eta'] as String,
              fluidityScore: currentRoute['fluidityScore'] as int,
              trafficDensityColor: currentRoute['trafficDensityColor'] as Color,
              trafficLightCount: currentRoute['trafficLightCount'] as int,
              estimatedWaitTime: currentRoute['estimatedWaitTime'] as String,
            ),
          ),

          // Bottom action buttons
          Positioned(
            bottom: 4.h,
            left: 5.w,
            right: 5.w,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _showRouteOptions,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF2A2A2A).withValues(alpha: 0.95),
                      foregroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'alt_route',
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Text(
                          'Options',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 3.w),
                Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isRecalculating
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF000000),
                              ),
                            ),
                          )
                        : CustomIconWidget(
                            iconName: 'refresh',
                            color: Color(0xFF000000),
                            size: 24,
                          ),
                    onPressed:
                        _isRecalculating ? null : _handleManualRecalculation,
                    padding: EdgeInsets.all(3.w),
                    constraints: BoxConstraints(
                      minWidth: 14.w,
                      minHeight: 14.w,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
