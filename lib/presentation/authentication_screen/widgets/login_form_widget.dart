import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../services/auth_service.dart'; // ← AJOUT

/// Login form widget with email and password fields
class LoginFormWidget extends StatefulWidget {
  final VoidCallback onLoginSuccess;

  const LoginFormWidget({super.key, required this.onLoginSuccess});

  @override
  State<LoginFormWidget> createState() => _LoginFormWidgetState();
}

class _LoginFormWidgetState extends State<LoginFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  // ============================================================================
  // NOUVELLE MÉTHODE : Connexion avec Supabase
  // ============================================================================
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      // Connexion avec Supabase
      final response = await AuthService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (response.user != null) {
        // Connexion réussie
        HapticFeedback.mediumImpact();
        
        if (!mounted) return;
        
        // Message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bienvenue ${response.user!.email}!',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigation vers l'écran principal
        widget.onLoginSuccess();
      }
    } catch (e) {
      // Erreur de connexion
      HapticFeedback.heavyImpact();
      
      if (!mounted) return;
      
      setState(() => _isLoading = false);

      // Messages d'erreur personnalisés
      String errorMessage = 'Erreur de connexion';
      
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('invalid login credentials') || 
          errorString.contains('invalid_grant')) {
        errorMessage = 'Email ou mot de passe incorrect';
      } else if (errorString.contains('email not confirmed')) {
        errorMessage = 'Veuillez confirmer votre email';
      } else if (errorString.contains('network') || 
                 errorString.contains('connection')) {
        errorMessage = 'Problème de connexion réseau';
      } else if (errorString.contains('user not found')) {
        errorMessage = 'Aucun compte trouvé avec cet email';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Réessayer',
            textColor: Colors.white,
            onPressed: () {
              // Permet de réessayer rapidement
            },
          ),
        ),
      );

      // Log pour debug (à retirer en production)
      print('🔐 Erreur de connexion: $e');
    }
  }

  void _handleForgotPassword() {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Réinitialisation du mot de passe - Fonctionnalité à venir',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00E5FF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withAlpha(128),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withAlpha(51),
          width: 1,
        ),
      ),
      padding: EdgeInsets.all(6.w),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Connexion',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            // Email Field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              validator: _validateEmail,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'votre.email@exemple.fr',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'email',
                    color: theme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.errorColor,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.errorColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Password Field
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              textInputAction: TextInputAction.done,
              validator: _validatePassword,
              onFieldSubmitted: (_) => _handleLogin(),
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: '••••••••',
                prefixIcon: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: CustomIconWidget(
                    iconName: 'lock',
                    color: theme.colorScheme.primary,
                    size: 5.w,
                  ),
                ),
                suffixIcon: IconButton(
                  icon: CustomIconWidget(
                    iconName:
                        _obscurePassword ? 'visibility' : 'visibility_off',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 5.w,
                  ),
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.outline,
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.errorColor,
                    width: 1,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppTheme.errorColor,
                    width: 2,
                  ),
                ),
              ),
            ),
            SizedBox(height: 1.h),
            // Forgot Password Link
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleForgotPassword,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                ),
                child: Text(
                  'Mot de passe oublié?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 2.h),
            // Login Button
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                shadowColor: theme.colorScheme.primary.withAlpha(128),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 5.w,
                      width: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.black),
                      ),
                    )
                  : Text(
                      'Se connecter',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}