import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/features/auth/presentation/controllers/auth_controller.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';

/// Màn hình quên mật khẩu — gửi email khôi phục
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final redirectTo = _resolveRedirectUrl();
    final success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordResetEmail(
          _emailController.text.trim(),
          redirectTo: redirectTo,
        );

    if (mounted && success) {
      setState(() => _emailSent = true);
    }
  }

  /// Tính toán URL điều hướng sau khi người dùng bấm xác nhận trong email
  String? _resolveRedirectUrl() {
    if (!kIsWeb) return null;
    try {
      final base = Uri.base;
      final origin = base.origin;
      if (origin.isEmpty) return null;

      if (base.toString().contains('#')) {
        return '$origin/#${RouteNames.resetPasswordPath}';
      }
      return '$origin${RouteNames.resetPasswordPath}';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space24,
              vertical: AppDimensions.space48,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppDimensions.space32),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppDimensions.radius12),
                border: Border.all(color: AppColors.border),
              ),
              child: _emailSent ? _buildSuccessView() : _buildForm(authState),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mark_email_read_outlined,
          size: 56,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimensions.space16),
        const Text(
          'Email đã được gửi',
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          'Chúng tôi đã gửi liên kết đặt lại mật khẩu đến ${_emailController.text}. '
          'Vui lòng kiểm tra hộp thư và nhấn vào liên kết để tiếp tục.',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),
        AppButton(
          label: 'Quay lại đăng nhập',
          isFullWidth: true,
          onPressed: () => context.goNamed(RouteNames.login),
        ),
      ],
    );
  }

  Widget _buildForm(AuthFormState authState) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(
            Icons.lock_reset_outlined,
            size: 48,
            color: AppColors.primary,
          ),
          const SizedBox(height: AppDimensions.space16),
          const Text(
            'Khôi phục mật khẩu',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space8),
          const Text(
            'Nhập email của bạn để nhận liên kết đặt lại mật khẩu',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space32),

          if (authState.errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(AppDimensions.radius8),
              ),
              child: Text(
                authState.errorMessage!,
                style:
                    const TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
          ],

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập địa chỉ email';
              }
              if (!value.contains('@')) {
                return 'Email không đúng định dạng';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimensions.space24),

          AppButton(
            label: 'Gửi email khôi phục',
            isLoading: authState.isLoading,
            isFullWidth: true,
            onPressed: _handleSubmit,
          ),

          const SizedBox(height: AppDimensions.space16),

          TextButton(
            onPressed: () => context.goNamed(RouteNames.login),
            child: const Text('Quay lại đăng nhập'),
          ),
        ],
      ),
    );
  }
}
