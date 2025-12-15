import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;
class AlertService {
  // Get active alerts for user
  static Future<List<Map<String, dynamic>>> getUserActiveAlerts({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    final response = await supabase.rpc('get_user_active_alerts', params: {
      'user_id_param': userId,
      'user_lat': latitude,
      'user_lon': longitude,
    });

    return List<Map<String, dynamic>>.from(response);
  }

  // Mark alert as read
  static Future<void> markAlertAsRead(String alertId, String userId) async {
    await supabase
        .from('user_alerts')
        .update({'is_read': true, 'read_at': DateTime.now().toIso8601String()})
        .eq('alert_id', alertId)
        .eq('user_id', userId);
  }

  // Dismiss alert
  static Future<void> dismissAlert(String alertId, String userId) async {
    await supabase
        .from('user_alerts')
        .update({
          'is_dismissed': true,
          'dismissed_at': DateTime.now().toIso8601String()
        })
        .eq('alert_id', alertId)
        .eq('user_id', userId);
  }

  // Subscribe to all alerts (realtime)
  static RealtimeChannel subscribeToAlerts({
    required Function(Map<String, dynamic>) onNewAlert,
  }) {
    return supabase
        .channel('alerts_channel')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'alerts',
          callback: (payload) {
            if (payload.newRecord['is_active'] == true) {
              onNewAlert(payload.newRecord);
            }
          },
        )
        .subscribe();
  }
}
