import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;
class EmergencyAlertService {
  // Get nearby emergency alerts
  static Future<List<Map<String, dynamic>>> getNearbyEmergencyAlerts({
    required double latitude,
    required double longitude,
    int radiusMeters = 2000,
  }) async {
    final response = await supabase.rpc('get_nearby_emergency_alerts', params: {
      'user_lat': latitude,
      'user_lon': longitude,
      'radius_meters': radiusMeters,
    });

    return List<Map<String, dynamic>>.from(response);
  }

  // Subscribe to emergency alerts (realtime)
  static RealtimeChannel subscribeToEmergencyAlerts({
    required Function(Map<String, dynamic>) onNewAlert,
  }) {
    return supabase
        .channel('emergency_alerts_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'emergency_alerts',
          callback: (payload) {
            if (payload.newRecord['is_active'] == true) {
              onNewAlert(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  // Get all active emergency alerts
  static Future<List<Map<String, dynamic>>> getActiveEmergencyAlerts() async {
    final response = await supabase
        .from('emergency_alerts')
        .select('*')
        .eq('is_active', true)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}