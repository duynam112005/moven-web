import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/network/supabase_client.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_button.dart';

/// Màn hình đăng nhập tài khoản MOVEN
class LoginScreen extends ConsumerStatefulWidget {
  final String? redirectPath;

  const LoginScreen({super.key, this.redirectPath});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Trong Giai đoạn 1 (Base), Supabase Auth sẽ được kết nối đầy đủ tại Giai đoạn 3.
      // Dưới đây là xử lý khung đăng nhập an toàn.
      await Future.delayed(const Duration(milliseconds: 600));

      if (mounted) {
        final target = widget.redirectPath ?? RouteNames.homePath;
        context.go(target);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Đăng nhập không thành công. Vui lòng kiểm tra lại thông tin.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Đăng nhập tài khoản',
                    style: AppTypography.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    'Chào mừng bạn trở lại với MOVEN',
                    style: AppTypography.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppDimensions.space32),

                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(AppDimensions.radius8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),
                  ],

                  // Email Input
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

                  const SizedBox(height: AppDimensions.space16),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Mật khẩu',
                      hintText: '••••••••',
                      prefixIcon: Icon(Icons.lock_outline, size: 20),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'Mật khẩu tối thiểu 6 ký tự';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: AppDimensions.space8),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.goNamed(RouteNames.forgotPassword),
                      child: const Text('Quên mật khẩu?'),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),

                  // Submit Button
                  AppButton(
                    label: 'Đăng nhập',
                    isLoading: _isLoading,
                    isFullWidth: true,
                    onPressed: _handleLogin,
                  ),

                  const SizedBox(height: AppDimensions.space24),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Chưa có tài khoản? ',
                        style: AppTypography.bodySmall,
                      ),
                      InkWell(
                        onTap: () => context.goNamed(RouteNames.register),
                        child: Text(
                          'Đăng ký ngay',
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
            ),
          ),
        ),
      ),
    );
  }
}
