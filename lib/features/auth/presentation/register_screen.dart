import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moven/features/auth/presentation/controllers/auth_controller.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';

/// Màn hình đăng ký tài khoản MOVEN
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitted = false; // Đã đăng ký thành công

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authControllerProvider.notifier).register(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          phone: _phoneController.text.trim().isEmpty
              ? null
              : _phoneController.text.trim(),
        );

    if (mounted && success) {
      final authState = ref.read(authControllerProvider);
      if (authState.hasSession) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đăng ký thành công! Chào mừng bạn đến với MOVEN.'),
            backgroundColor: Color(0xFF166534),
          ),
        );
        context.go(RouteNames.homePath);
      } else {
        setState(() => _submitted = true);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
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
              child: _submitted
                  ? _buildSuccessView()
                  : _buildForm(authState),
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
          'Kiểm tra hộp thư của bạn',
          style: AppTypography.headlineLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppDimensions.space8),
        Text(
          'Chúng tôi đã gửi email xác thực đến ${_emailController.text}. '
          'Vui lòng nhấn vào liên kết trong email để kích hoạt tài khoản.',
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
            'Tạo tài khoản MOVEN',
            style: AppTypography.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space8),
          const Text(
            'Mua sắm thời trang dễ dàng hơn với tài khoản MOVEN',
            style: AppTypography.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.space32),

          if (authState.errorMessage != null) ...[
            _buildErrorBanner(authState.errorMessage!),
            const SizedBox(height: AppDimensions.space16),
          ],

          // Full Name
          TextFormField(
            controller: _fullNameController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Họ và tên *',
              hintText: 'Nguyễn Văn A',
              prefixIcon: Icon(Icons.person_outline, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập họ và tên';
              }
              if (value.trim().length < 2) {
                return 'Họ tên tối thiểu 2 ký tự';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimensions.space16),

          // Email
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email *',
              hintText: 'name@example.com',
              prefixIcon: Icon(Icons.email_outlined, size: 20),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập địa chỉ email';
              }
              if (!RegExp(r'^[\w\.\-]+@[\w\-]+\.\w{2,}$')
                  .hasMatch(value.trim())) {
                return 'Email không đúng định dạng';
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimensions.space16),

          // Phone (optional)
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Số điện thoại',
              hintText: '09xxxxxxxx',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
            ),
            validator: (value) {
              if (value != null && value.trim().isNotEmpty) {
                if (!RegExp(r'^(0|\+84)\d{9,10}$').hasMatch(value.trim())) {
                  return 'Số điện thoại không đúng định dạng';
                }
              }
              return null;
            },
          ),

          const SizedBox(height: AppDimensions.space16),

          // Password
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mật khẩu *',
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

          // Confirm Password
          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirm,
            decoration: InputDecoration(
              labelText: 'Xác nhận mật khẩu *',
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
            label: 'Đăng ký',
            isLoading: authState.isLoading,
            isFullWidth: true,
            onPressed: _handleRegister,
          ),

          const SizedBox(height: AppDimensions.space24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Đã có tài khoản? ',
                style: AppTypography.bodySmall,
              ),
              InkWell(
                onTap: () => context.goNamed(RouteNames.login),
                child: Text(
                  'Đăng nhập',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.circular(AppDimensions.radius8),
      ),
      child: Text(
        message,
        style: const TextStyle(fontSize: 13, color: AppColors.error),
      ),
    );
  }
}
