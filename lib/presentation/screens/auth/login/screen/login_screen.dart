// lib/presentation/screens/auth/login/screen/login_screen.dart
import 'package:app_1/presentation/screens/auth/login/cubit/login_cubit.dart';
import 'package:app_1/presentation/screens/auth/login/widget/custom_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:app_1/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onRegisterPressed;
  final VoidCallback? onLoginSuccess;

  const LoginScreen({Key? key, this.onRegisterPressed, this.onLoginSuccess})
    : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    context.read<LoginCubit>().login(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  void _showErrorSnackbar(String message) {
    CustomSnackbar.showError(
      context,
      title: 'خطأ في تسجيل الدخول',
      message: message,
    );
  }

  void _showSuccessSnackbar(String message) {
    CustomSnackbar.showSuccess(context, title: 'تم بنجاح', message: message);
  }

  void _navigateToForgotPassword() {
    Navigator.pushNamed(context, '/forgot-password', arguments: {
      'email': _emailController.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginError) {
          _showErrorSnackbar(state.message);
        } else if (state is LoginSuccess) {
          _showSuccessSnackbar('مرحباً بعودتك ${state.user.name}!');
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);

          if (widget.onLoginSuccess != null) {
            widget.onLoginSuccess!();
          } else {}
        }
      },
      builder: (context, state) {
        final isLoading = state is LoginLoading;

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // شعار التطبيق
                  Center(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/image/photo_2025-12-06_01-52-45-removebg-preview.png",
                          width: 70,
                          height: 70,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'مرآة المجتمع',
                          style: TextStyle(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'منصة التواصل العربي النصي',
                          style: TextStyle(
                            color: AppColors.darkGray,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.h),

                  // عنوان الصفحة
                  Text(
                    'مرحباً بعودتك!',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'سجل دخولك لمتابعة برقياتك',
                    style: TextStyle(
                      color: AppColors.darkGray,
                      fontSize: 16.sp,
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // نموذج تسجيل الدخول
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'البريد الإلكتروني',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال البريد الإلكتروني';
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'البريد الإلكتروني غير صالح';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16.h),

                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'كلمة المرور',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'يرجى إدخال كلمة المرور';
                            }
                            if (value.length < 6) {
                              return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                            }
                            return null;
                          },
                        ),

                        // رابط نسيان كلمة المرور
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _navigateToForgotPassword,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24.h),

                        // زر تسجيل الدخول
                        SizedBox(
                          width: double.infinity,
                          height: 50.h,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _handleLogin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child:
                                isLoading
                                    ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      'تسجيل الدخول',
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),

                        SizedBox(height: 32.h),

                        // رابط التسجيل
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'ليس لديك حساب؟',
                              style: TextStyle(
                                color: AppColors.darkGray,
                                fontSize: 14.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            TextButton(
                              onPressed:
                                  widget.onRegisterPressed ??
                                  () {
                                    Navigator.pushNamed(context, '/register');
                                  },
                              child: Text(
                                'سجل الآن',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}