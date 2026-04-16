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

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _clientCodeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _clientCodeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final clientCode = _clientCodeController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (clientCode.isEmpty || email.isEmpty || password.isEmpty) {
      ToastService.showError('All fields are required');
      return;
    }

    final error = await ref.read(authProvider.notifier).login(
          clientCode: clientCode,
          email: email,
          password: password,
        );
    if (error != null) {
      ToastService.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(authProvider.select((state) => state.isLoading));

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.violet, Color(0xFF6D28D9)],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: AppSpacing.xl),
                  FadeSlideTransition(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violet.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'Tenant Portal',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: AppColors.violet,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Access your rental account',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 300),
                    child: AppTextField(
                      label: 'Client Code',
                      placeholder: 'e.g. PM001',
                      controller: _clientCodeController,
                      prefixIcon: Icons.apartment_outlined,
                    ),
                  ),
                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 400),
                    child: AppTextField(
                      label: 'Email',
                      placeholder: 'you@example.com',
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      prefixIcon: Icons.email_outlined,
                    ),
                  ),
                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 500),
                    child: AppTextField(
                      label: 'Password',
                      obscureText: true,
                      controller: _passwordController,
                      prefixIcon: Icons.lock_outlined,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  FadeSlideTransition(
                    duration: const Duration(milliseconds: 600),
                    child: AppButton(
                      label: 'Sign In',
                      onPressed: _submit,
                      isLoading: isLoading,
                      fullWidth: true,
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
