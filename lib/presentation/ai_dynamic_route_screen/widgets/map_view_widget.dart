import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Google Maps view widget with route display
class MapViewWidget extends StatelessWidget {
  final GoogleMapController? mapController;
  final Set<Polyline> polylines;
  final Set<Marker> markers;
  final LatLng initialPosition;
  final Function(GoogleMapController) onMapCreated;

  const MapViewWidget({
    Key? key,
    required this.mapController,
    required this.polylines,
    required this.markers,
    required this.initialPosition,
    required this.onMapCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: GoogleMap(
        onMapCreated: onMapCreated,
        initialCameraPosition: CameraPosition(
          target: initialPosition,
          zoom: 14.0,
        ),
        polylines: polylines,
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        compassEnabled: true,
        trafficEnabled: true,
        mapType: MapType.normal,
        style: _darkMapStyle,
      ),
    );
  }

  static const String _darkMapStyle = '''
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
      "featureType": "road",
      "elementType": "geometry.stroke",
      "stylers": [{"color": "#1a1a1a"}]
    },
    {
      "featureType": "water",
      "elementType": "geometry",
      "stylers": [{"color": "#263238"}]
    }
  ]
  ''';
}
