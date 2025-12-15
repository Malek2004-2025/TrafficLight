import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;

class UserLocationService {
  // Update user location in database
  static Future<void> updateUserLocation({
    required String userId,
    required double latitude,
    required double longitude,
  }) async {
    await supabase.from('users').update({
      'location': 'POINT($longitude $latitude)',
    }).eq('id', userId);
  }

  // Update user preferences
  static Future<void> updateUserPreferences({
    required String userId,
    bool? enableEmergencyAlerts,
    bool? enableTrafficAlerts,
    bool? enableRouteSuggestions,
    int? emergencyVehicleDistance,
  }) async {
    final updates = <String, dynamic>{};
    
    if (enableEmergencyAlerts != null) {
      updates['enable_emergency_alerts'] = enableEmergencyAlerts;
    }
    if (enableTrafficAlerts != null) {
      updates['enable_traffic_alerts'] = enableTrafficAlerts;
    }
    if (enableRouteSuggestions != null) {
      updates['enable_route_suggestions'] = enableRouteSuggestions;
    }
    if (emergencyVehicleDistance != null) {
      updates['emergency_vehicle_distance'] = emergencyVehicleDistance;
    }

    await supabase
        .from('user_preferences')
        .update(updates)
        .eq('user_id', userId);
  }
}