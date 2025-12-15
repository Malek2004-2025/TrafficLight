import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/floating_stats_card_widget.dart';
import './widgets/priority_alert_overlay_widget.dart';
import './widgets/traffic_light_detail_sheet_widget.dart';
import './widgets/traffic_light_marker_widget.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/emergency_alert_service.dart';

class RealTimeTrafficLightsScreen extends StatefulWidget {
  const RealTimeTrafficLightsScreen({Key? key}) : super(key: key);

  @override
  State<RealTimeTrafficLightsScreen> createState() =>
      _RealTimeTrafficLightsScreenState();
}

class _RealTimeTrafficLightsScreenState
    extends State<RealTimeTrafficLightsScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  Set<Marker> _markers = {};
  StreamSubscription<Position>? _positionStreamSubscription;
  bool _isLoading = true;
  bool _isReconnecting = false;
  String _lastUpdated = '';
  int _selectedTrafficLightIndex = -1;
  bool _showDetailSheet = false;
  bool _showPriorityAlert = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  RealtimeChannel? _emergencyAlertChannel;

  // Mock traffic lights data with real-time status
  final List<Map<String, dynamic>> _trafficLights = [
    {
      "id": 1,
      "name": "Carrefour République",
      "position": {"lat": 48.8566, "lng": 2.3522},
      "status": "green",
      "countdown": 45,
      "distance": 250.0,
      "isPriority": false,
      "nextChange": "Rouge dans 45s",
    },
    {
      "id": 2,
      "name": "Avenue des Champs-Élysées",
      "position": {"lat": 48.8698, "lng": 2.3078},
      "status": "red",
      "countdown": 30,
      "distance": 450.0,
      "isPriority": true,
      "nextChange": "Vert dans 30s",
    },
    {
      "id": 3,
      "name": "Place de la Concorde",
      "position": {"lat": 48.8656, "lng": 2.3212},
      "status": "yellow",
      "countdown": 5,
      "distance": 180.0,
      "isPriority": false,
      "nextChange": "Rouge dans 5s",
    },
    {
      "id": 4,
      "name": "Rue de Rivoli",
      "position": {"lat": 48.8606, "lng": 2.3376},
      "status": "green",
      "countdown": 60,
      "distance": 320.0,
      "isPriority": false,
      "nextChange": "Jaune dans 60s",
    },
    {
      "id": 5,
      "name": "Boulevard Saint-Germain",
      "position": {"lat": 48.8534, "lng": 2.3364},
      "status": "red",
      "countdown": 25,
      "distance": 520.0,
      "isPriority": true,
      "nextChange": "Vert dans 25s",
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _requestLocationPermission();
    _startTrafficLightSimulation();
    _updateLastUpdatedTime();
    _subscribeToEmergencyAlerts();
  }

  void _initializeAnimation() {
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoading = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoading = false);
      return;
    }

    _getCurrentLocation();
    _startLocationTracking();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
      _updateTrafficLightMarkers();
      _animateToCurrentPosition();
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _startLocationTracking() {
    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      setState(() {
        _currentPosition = position;
      });
      _updateTrafficLightDistances();
    });
  }

  void _updateTrafficLightDistances() {
    if (_currentPosition == null) return;

    for (var light in _trafficLights) {
      double distance = Geolocator.distanceBetween(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
        (light["position"] as Map<String, dynamic>)["lat"],
        (light["position"] as Map<String, dynamic>)["lng"],
      );
      light["distance"] = distance;
    }

    _trafficLights.sort(
        (a, b) => (a["distance"] as double).compareTo(b["distance"] as double));
  }

  void _startTrafficLightSimulation() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        for (var light in _trafficLights) {
          int countdown = light["countdown"] as int;
          if (countdown > 0) {
            light["countdown"] = countdown - 1;
          } else {
            _cycleTrafficLightStatus(light);
          }
        }
        _updateLastUpdatedTime();
      });

      _checkPriorityAlerts();
    });
  }

  void _cycleTrafficLightStatus(Map<String, dynamic> light) {
    String currentStatus = light["status"] as String;
    switch (currentStatus) {
      case "green":
        light["status"] = "yellow";
        light["countdown"] = 5;
        light["nextChange"] = "Rouge dans 5s";
        break;
      case "yellow":
        light["status"] = "red";
        light["countdown"] = 30;
        light["nextChange"] = "Vert dans 30s";
        break;
      case "red":
        light["status"] = "green";
        light["countdown"] = 45;
        light["nextChange"] = "Jaune dans 45s";
        break;
    }
  }

  void _checkPriorityAlerts() {
    bool hasPriorityNearby = _trafficLights.any((light) =>
        (light["isPriority"] as bool) && (light["distance"] as double) < 300);

    if (hasPriorityNearby && !_showPriorityAlert) {
      setState(() => _showPriorityAlert = true);
      HapticFeedback.heavyImpact();
    } else if (!hasPriorityNearby && _showPriorityAlert) {
      setState(() => _showPriorityAlert = false);
    }
  }

  void _updateLastUpdatedTime() {
    DateTime now = DateTime.now();
    _lastUpdated =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  void _updateTrafficLightMarkers() {
    if (_currentPosition == null) return;

    Set<Marker> markers = {};

    // Add driver position marker with pulse effect
    markers.add(
      Marker(
        markerId: MarkerId('driver_position'),
        position: LatLng(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan),
        infoWindow: InfoWindow(title: 'Votre position'),
      ),
    );

    // Add traffic light markers
    for (int i = 0; i < _trafficLights.length; i++) {
      var light = _trafficLights[i];
      var position = light["position"] as Map<String, dynamic>;
      String status = light["status"] as String;

      BitmapDescriptor icon;
      switch (status) {
        case "green":
          icon =
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
          break;
        case "yellow":
          icon =
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
          break;
        case "red":
          icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          break;
        default:
          icon = BitmapDescriptor.defaultMarker;
      }

      markers.add(
        Marker(
          markerId: MarkerId('traffic_light_$i'),
          position: LatLng(position["lat"], position["lng"]),
          icon: icon,
          infoWindow: InfoWindow(
            title: light["name"] as String,
            snippet:
                '${(light["distance"] as double).toStringAsFixed(0)}m - ${light["nextChange"]}',
          ),
          onTap: () => _onTrafficLightTap(i),
        ),
      );
    }

    setState(() => _markers = markers);
  }

  void _onTrafficLightTap(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedTrafficLightIndex = index;
      _showDetailSheet = true;
    });
  }

  void _animateToCurrentPosition() {
    if (_mapController != null && _currentPosition != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(
              _currentPosition!.latitude,
              _currentPosition!.longitude,
            ),
            zoom: 15.0,
          ),
        ),
      );
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.mediumImpact();
    setState(() => _isReconnecting = true);

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isReconnecting = false;
      _updateLastUpdatedTime();
    });

    _updateTrafficLightMarkers();
  }

  Future<void> _handleManualReconnect() async {
    HapticFeedback.lightImpact();
    setState(() => _isReconnecting = true);

    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isReconnecting = false;
      _updateLastUpdatedTime();
    });

    _updateTrafficLightMarkers();
  }

  @override
  void dispose() {
    _emergencyAlertChannel?.unsubscribe(); 
    _pulseController.dispose();
    _positionStreamSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ============================================================================
// SUBSCRIPTION AUX ALERTES D'URGENCE
// ============================================================================
void _subscribeToEmergencyAlerts() {
  print('🔔 Abonnement aux alertes d\'urgence...');
  
  _emergencyAlertChannel = EmergencyAlertService.subscribeToEmergencyAlerts(
    onNewAlert: (alert) {
      print('🚨 ALERTE D\'URGENCE REÇUE!');
      print('   Type: ${alert['alert_type']}');
      print('   Plaque: ${alert['license_plate']}');
      
      // Vibration et son
      HapticFeedback.heavyImpact();
      
      // Afficher la notification
      _showEmergencyNotification(alert);
    },
  );
  
  print('✅ Abonné aux alertes d\'urgence');
}

// ============================================================================
// AFFICHAGE DE LA NOTIFICATION D'URGENCE
// ============================================================================
void _showEmergencyNotification(Map<String, dynamic> alert) {
  // Déterminer l'icône et le titre selon le type
  IconData icon;
  String title;
  Color bgColor;
  
  switch (alert['alert_type']) {
    case 'ambulance':
      icon = Icons.local_hospital;
      title = '🚑 AMBULANCE DÉTECTÉE';
      bgColor = Colors.red[900]!;
      break;
    case 'police':
      icon = Icons.local_police;
      title = '🚓 POLICE DÉTECTÉE';
      bgColor = Colors.blue[900]!;
      break;
    case 'fire_truck':
      icon = Icons.local_fire_department;
      title = '🚒 POMPIERS DÉTECTÉS';
      bgColor = Colors.orange[900]!;
      break;
    default:
      icon = Icons.warning;
      title = '🚨 VÉHICULE D\'URGENCE';
      bgColor = Colors.red[900]!;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black87,
    builder: (context) => AlertDialog(
      backgroundColor: bgColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: bgColor,
              size: 32,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      content: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Plaque d'immatriculation
            Row(
              children: [
                Icon(Icons.car_rental, color: bgColor),
                SizedBox(width: 8),
                Text(
                  'Plaque:',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  alert['license_plate'] ?? 'Inconnu',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Direction si disponible
            if (alert['direction'] != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.navigation, color: bgColor),
                  SizedBox(width: 8),
                  Text(
                    'Direction:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    alert['direction'],
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            
            // Temps d'arrivée si disponible
            if (alert['estimated_arrival'] != null) ...[
              SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, color: bgColor),
                  SizedBox(width: 8),
                  Text(
                    'Arrivée dans:',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '${alert['estimated_arrival']}s',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
            
            SizedBox(height: 16),
            
            // Message d'avertissement
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.yellow[700]!,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.yellow[900],
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Préparez-vous à céder le passage!',
                      style: TextStyle(
                        color: Colors.yellow[900],
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: bgColor,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              Navigator.pop(context);
            },
            child: Text(
              'COMPRIS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
      actionsPadding: EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Feux en Temps Réel',
        variant: CustomAppBarVariant.minimal,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            onPressed: _handleRefresh,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Chargement de la carte...',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // Google Map
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition != null
                        ? LatLng(
                            _currentPosition!.latitude,
                            _currentPosition!.longitude,
                          )
                        : LatLng(48.8566, 2.3522),
                    zoom: 15.0,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _mapController = controller;
                    _updateTrafficLightMarkers();
                  },
                  style: '''
                    [
                      {
                        "elementType": "geometry",
                        "stylers": [{"color": "#1a1a1a"}]
                      },
                      {
                        "elementType": "labels.text.fill",
                        "stylers": [{"color": "#b0bec5"}]
                      },
                      {
                        "elementType": "labels.text.stroke",
                        "stylers": [{"color": "#1a1a1a"}]
                      },
                      {
                        "featureType": "road",
                        "elementType": "geometry",
                        "stylers": [{"color": "#2a2a2a"}]
                      },
                      {
                        "featureType": "water",
                        "elementType": "geometry",
                        "stylers": [{"color": "#00e5ff"}, {"lightness": -80}]
                      }
                    ]
                  ''',
                ),

                // Floating stats card
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: FloatingStatsCardWidget(
                    nearbyLights: _trafficLights.length,
                    lastUpdated: _lastUpdated,
                    isConnected: !_isReconnecting,
                  ),
                ),

                // Priority alert overlay
                if (_showPriorityAlert)
                  Positioned(
                    top: 100,
                    left: 16,
                    right: 16,
                    child: PriorityAlertOverlayWidget(
                      onDismiss: () {
                        setState(() => _showPriorityAlert = false);
                      },
                    ),
                  ),

                // Traffic light markers overlay
                if (_trafficLights.isNotEmpty)
                  Positioned(
                    bottom: _showDetailSheet ? 320 : 100,
                    left: 16,
                    right: 16,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          _trafficLights.length > 3 ? 3 : _trafficLights.length,
                          (index) {
                            var light = _trafficLights[index];
                            return Padding(
                              padding: EdgeInsets.only(right: 12),
                              child: TrafficLightMarkerWidget(
                                name: light["name"] as String,
                                status: light["status"] as String,
                                countdown: light["countdown"] as int,
                                distance: light["distance"] as double,
                                isPriority: light["isPriority"] as bool,
                                onTap: () => _onTrafficLightTap(index),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // Detail bottom sheet
                if (_showDetailSheet && _selectedTrafficLightIndex >= 0)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: TrafficLightDetailSheetWidget(
                      trafficLight: _trafficLights[_selectedTrafficLightIndex],
                      onClose: () {
                        setState(() => _showDetailSheet = false);
                      },
                      onNavigate: () {
                        HapticFeedback.lightImpact();
                        Navigator.pushNamed(
                            context, '/ai-dynamic-route-screen');
                      },
                    ),
                  ),

                // Reconnecting overlay
                if (_isReconnecting)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.5),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color: theme.colorScheme.primary,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Reconnexion IoT...',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _handleManualReconnect,
        backgroundColor: theme.colorScheme.primary,
        child: CustomIconWidget(
          iconName: 'sync',
          color: Colors.black,
          size: 24,
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          final routes = [
            '/real-time-traffic-lights-screen',
            '/ai-dynamic-route-screen',
            '/dynamic-alerts-screen',
            '/dynamic-statistics-and-ai-screen',
            '/authentication-screen',
          ];
          Navigator.pushNamed(context, routes[index]);
        },
      ),
    );
  }
}
