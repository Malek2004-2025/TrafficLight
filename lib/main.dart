import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // ← Ajouté

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';

// Instance globale Supabase
final supabase = Supabase.instance.client;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // INITIALISER SUPABASE EN PREMIER
  await Supabase.initialize(
    url: 'https://gxcdjyagxcrzcaoiwlcd.supabase.co', // ← Remplacez par votre vraie URL
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd4Y2RqeWFneGNyemNhb2l3bGNkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjU2MDM3MDYsImV4cCI6MjA4MTE3OTcwNn0.DVEv-3ISdvENQUbdUNpEH8ScQWVn8vW7rX4zTyjeWuQ', // ← Remplacez par votre vraie clé anon
  );

  bool _hasShownError = false;

  // CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return MaterialApp(
        title: 'smarttraffic',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,
        // CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.0),
            ),
            child: child!,
          );
        },
        // END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.initial,
      );
    });
  }
}