import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/features/auth/presentation/controllers/auth_controller.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/router/router_notifier.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';

/// Màn hình đặt lại mật khẩu — dùng sau khi nhấn liên kết trong email
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _resetSuccess = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .updatePassword(_passwordController.text);

    if (mounted && success) {
      ref.read(isPasswordRecoveryProvider.notifier).state = false;
      setState(() => _resetSuccess = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
    final isRecovery = ref.watch(isPasswordRecoveryProvider);
    final authStateAsync = ref.watch(authStateChangesProvider);

    Widget content;
    if (_resetSuccess) {
      content = _buildSuccessView();
    } else if (authStateAsync.isLoading) {
      content = const Padding(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.space32),
        child: AppLoading(message: 'Đang kiểm tra liên kết khôi phục...'),
      );
    } else if (currentUser == null && !isRecovery) {
      content = _buildInvalidLinkView();
    } else {
      content = _buildForm(authState);
    }

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
              child: content,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInvalidLinkView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.link_off_outlined,
          size: 56,
          color: AppColors.error,
        ),
        const SizedBox(height: AppDimensions.space16),
        const Text(
          'Liên kết không hợp lệ hoặc đã hết hạn',
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),
        const Text(
          'Liên kết đặt lại mật khẩu của bạn có thể đã hết hạn hoặc đã được sử dụng. '
          'Vui lòng gửi lại yêu cầu để nhận liên kết mới.',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),
        AppButton(
          label: 'Yêu cầu liên kết mới',
          isFullWidth: true,
          onPressed: () => context.goNamed(RouteNames.forgotPassword),
        ),
        const SizedBox(height: AppDimensions.space16),
        TextButton(
          onPressed: () => context.goNamed(RouteNames.login),
          child: const Text('Quay lại đăng nhập'),
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.check_circle_outline,
          size: 56,
          color: AppColors.primary,
        ),
        const SizedBox(height: AppDimensions.space16),
        const Text(
          'Mật khẩu đã được cập nhật',
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),
        const Text(
          'Mật khẩu của bạn đã được đặt lại thành công. '
          'Vui lòng đăng nhập bằng mật khẩu mới.',
          style: AppTypography.bodySmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space32),
        AppButton(
          label: 'Đăng nhập',
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
          const Text(
            'Đặt mật khẩu mới',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space8),
          const Text(
            'Nhập mật khẩu mới cho tài khoản của bạn',
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
                style: const TextStyle(fontSize: 13, color: AppColors.error),
              ),
            ),
            const SizedBox(height: AppDimensions.space16),
          ],

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu mới',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (value) {
              if (value == null || value.length < 6) {
                return 'Mật khẩu tối thiểu 6 ký tự';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimensions.space16),

          TextFormField(
            controller: _confirmController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Xác nhận mật khẩu mới',
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, size: 20),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirm
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
            ),
            validator: (value) {
              if (value != _passwordController.text) {
                return 'Mật khẩu xác nhận không khớp';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimensions.space24),

          AppButton(
            label: 'Cập nhật mật khẩu',
            isLoading: authState.isLoading,
            isFullWidth: true,
            onPressed: _handleReset,
          ),
        ],
      ),
    );
  }
}
