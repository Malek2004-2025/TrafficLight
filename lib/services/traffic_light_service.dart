import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;

class TrafficLightService {
  // Get nearby traffic lights
  static Future<List<Map<String, dynamic>>> getNearbyTrafficLights({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
  }) async {
    final response = await supabase.rpc('get_nearby_traffic_lights', params: {
      'user_lat': latitude,
      'user_lon': longitude,
      'radius_meters': radiusMeters,
    });

    return List<Map<String, dynamic>>.from(response);
  }

  // Subscribe to traffic light status updates (realtime)
  static RealtimeChannel subscribeToTrafficLightUpdates({
    required Function(Map<String, dynamic>) onUpdate,
  }) {
    return supabase
        .channel('traffic_light_status_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'traffic_light_status',
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  // Get traffic light details
  static Future<Map<String, dynamic>?> getTrafficLightInfo({
    required double userLat,
    required double userLon,
    required String lightCode,
  }) async {
    final response = await supabase.rpc('get_traffic_light_info', params: {
      'user_lat': userLat,
      'user_lon': userLon,
      'light_code': lightCode,
    });

    if (response != null && response.isNotEmpty) {
      return response[0];
    }
    return null;
  }
}
