import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;

class AuthService {
  // Sign up new user
  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );

    // Create user profile
    if (response.user != null) {
      await supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': fullName,
        'user_type': 'driver',
      });

      // Create default preferences
      await supabase.from('user_preferences').insert({
        'user_id': response.user!.id,
        'enable_emergency_alerts': true,
        'enable_traffic_alerts': true,
        'enable_route_suggestions': true,
      });
    }

    return response;
  }

  // Sign in user
  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  static Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // Get current user
  static User? getCurrentUser() {
    return supabase.auth.currentUser;
  }

  // Check if user is signed in
  static bool isSignedIn() {
    return supabase.auth.currentUser != null;
  }
}
