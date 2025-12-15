import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;
class RouteService {
  // Get optimal route
  static Future<Map<String, dynamic>?> getOptimalRoute({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    final response = await supabase.rpc('get_optimal_route_score', params: {
      'origin_lat': originLat,
      'origin_lng': originLng,
      'dest_lat': destLat,
      'dest_lng': destLng,
    });

    if (response != null && response.isNotEmpty) {
      return response[0];
    }
    return null;
  }

  // Save route
  static Future<void> saveRoute({
    required String userId,
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    String? originAddress,
    String? destinationAddress,
    int? distanceMeters,
    int? estimatedDuration,
  }) async {
    await supabase.from('routes').insert({
      'user_id': userId,
      'origin': 'POINT($originLng $originLat)',
      'destination': 'POINT($destLng $destLat)',
      'origin_address': originAddress,
      'destination_address': destinationAddress,
      'distance_meters': distanceMeters,
      'estimated_duration': estimatedDuration,
      'expires_at': DateTime.now().add(Duration(hours: 2)).toIso8601String(),
    });
  }
}
