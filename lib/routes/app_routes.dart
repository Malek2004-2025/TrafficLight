import 'package:flutter/material.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/dynamic_statistics_and_ai_screen/dynamic_statistics_and_ai_screen.dart';
import '../presentation/dynamic_alerts_screen/dynamic_alerts_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/ai_dynamic_route_screen/ai_dynamic_route_screen.dart';
import '../presentation/real_time_traffic_lights_screen/real_time_traffic_lights_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String splash = '/splash-screen';
  static const String dynamicStatisticsAndAi =
      '/dynamic-statistics-and-ai-screen';
  static const String dynamicAlerts = '/dynamic-alerts-screen';
  static const String authentication = '/authentication-screen';
  static const String aiDynamicRoute = '/ai-dynamic-route-screen';
  static const String realTimeTrafficLights =
      '/real-time-traffic-lights-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    splash: (context) => const SplashScreen(),
    dynamicStatisticsAndAi: (context) => const DynamicStatisticsAndAiScreen(),
    dynamicAlerts: (context) => const DynamicAlertsScreen(),
    authentication: (context) => const AuthenticationScreen(),
    aiDynamicRoute: (context) => const AiDynamicRouteScreen(),
    realTimeTrafficLights: (context) => const RealTimeTrafficLightsScreen(),
    // TODO: Add your other routes here
  };
}
