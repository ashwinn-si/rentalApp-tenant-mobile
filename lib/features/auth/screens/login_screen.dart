import 'dart:math' as Math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_tokens.dart';
import '../../../core/services/toast_service.dart';
import '../../../core/utils/animations.dart';
import '../../../widgets/ui/app_button.dart';
import '../../../widgets/ui/app_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _clientCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AnimationController? _accentController;

  AnimationController _ensureAccentController() {
    _accentController ??= AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    return _accentController!;
  }

  @override
  void initState() {
    super.initState();
    _ensureAccentController();
  }

  @override
  void dispose() {
    _accentController?.dispose();
    _clientCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    debugPrint('=== Login Submit Called ===');
    final clientCode = _clientCodeController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    debugPrint(
      'Login Input - Code: $clientCode, Email: $email, Password: ${password.isNotEmpty ? '***' : 'empty'}',
    );

    if (clientCode.isEmpty || email.isEmpty || password.isEmpty) {
      debugPrint('Validation failed - missing fields');
      ToastService.showError('All fields are required');
      return;
    }

    debugPrint('Calling auth provider login...');
    final error = await ref.read(authProvider.notifier).login(
          clientCode: clientCode,
          email: email,
          password: password,
        );
    debugPrint('Login response error: $error');
    if (error != null) {
      ToastService.showError(error);
    } else {
      debugPrint('Login successful!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authProvider.select((state) => state.isLoading));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          // Gradient background
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.bgGradient1, AppColors.bgGradient2],
              ),
            ),
          ),

          // Animated accent blob (top right)
          Positioned(
            top: -60,
            right: -80,
            child: AnimatedBuilder(
              animation: _ensureAccentController(),
              builder: (context, child) {
                final accentController = _ensureAccentController();
                return Transform.translate(
                  offset: Offset(
                    20 * Math.sin(accentController.value * 2 * 3.14),
                    20 * Math.cos(accentController.value * 2 * 3.14),
                  ),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.violet.withOpacity(0.08),
                    ),
                  ),
                );
              },
            ),
          ),

          // Accent line (bottom left)
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 120,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentWarm,
                    AppColors.violet.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Header section
                  FadeSlideTransition(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppColors.violet, AppColors.violetDark],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                          ),
                          child: const Icon(
                            Icons.apartment_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const Text(
                          'Welcome Back',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Sign in to check dues, payment status, and history',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xl + AppSpacing.lg),

                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.violet.withValues(alpha: 0.16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violet.withValues(alpha: 0.08),
                            blurRadius: 24,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          AppTextField(
                            label: 'Client Code',
                            placeholder: 'e.g. PM001',
                            controller: _clientCodeController,
                            prefixIcon: Icons.apartment_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Email Address',
                            placeholder: 'you@example.com',
                            keyboardType: TextInputType.emailAddress,
                            controller: _emailController,
                            prefixIcon: Icons.email_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          AppTextField(
                            label: 'Password',
                            obscureText: true,
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outlined,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppButton(
                            label: 'Sign In',
                            onPressed: _submit,
                            isLoading: isLoading,
                            fullWidth: true,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Secure login • Multi-tenant platform',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 700),
                    child: Center(
                      child: Text(
                        'Sign in to check rent dues, payment status, and history',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary.withOpacity(0.68),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
