// lib/presentation/screens/auth/otp/screen/verify_otp_screen.dart
import 'dart:async';
import 'package:app_1/presentation/screens/auth/forgetpassword/screen/NewPasswordScreen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:provider/provider.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../providers/language_provider.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController otpController = TextEditingController();
  bool _isResending = false;
  bool _isVerifying = false;
  late StreamController<ErrorAnimationType> errorController;

  @override
  void initState() {
    super.initState();
    errorController = StreamController<ErrorAnimationType>.broadcast();
  }

  @override
  void didUpdateWidget(VerifyOtpScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!errorController.isClosed) {
      errorController.close();
    }
    errorController = StreamController<ErrorAnimationType>.broadcast();
  }

  @override
  void dispose() {
    Future.microtask(() {
      if (!errorController.isClosed) {
        errorController.close();
      }
    });
    super.dispose();
  }

  void _verifyOtp() {
    if (otpController.text.length != 6) {
      errorController.add(ErrorAnimationType.shake);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال رمز التحقق كاملاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isVerifying = true;
    });
    
    // ✅ الانتقال مباشرة إلى صفحة كلمة المرور الجديدة بدون التحقق المسبق
    Future.delayed(Duration(milliseconds: 300), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(
            email: widget.email,
            otp: otpController.text,
          ),
        ),
      );
    });
  }

  void _resendOtp() {
    setState(() {
      _isResending = true;
    });

    // ✅ محاكاة إعادة إرسال OTP (يمكنك ربطها بـ API لاحقاً)
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إعادة إرسال رمز التحقق'),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isArabic = languageProvider.getCurrentLanguageName() == 'العربية';

    return Directionality(
      textDirection: isArabic ? TextDirection.ltr : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الرأس
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          size: 40,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'تحقق من بريدك',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                          children: [
                            TextSpan(text: 'أدخل الرمز المرسل إلى\n'),
                            TextSpan(
                              text: widget.email,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'لقد أرسلنا رمز التحقق المكون من 6 أرقام',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 40),

                // حقل OTP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: PinCodeTextField(
                        appContext: context,
                        length: 6,
                        controller: otpController,
                        obscureText: false,
                        animationType: AnimationType.fade,
                        animationDuration: Duration(milliseconds: 300),
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 60,
                          fieldWidth: 50,
                          activeFillColor: Colors.white,
                          activeColor: AppColors.primary,
                          selectedColor: AppColors.primary,
                          selectedFillColor: Colors.white,
                          inactiveFillColor: Colors.grey[50]!,
                          inactiveColor: Colors.grey[300]!,
                          errorBorderColor: Colors.red,
                          borderWidth: 2,
                        ),
                        textStyle: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        onCompleted: (value) => _verifyOtp(),
                        beforeTextPaste: (text) {
                          return text != null &&
                              text.length == 6 &&
                              RegExp(r'^[0-9]+$').hasMatch(text);
                        },
                        errorAnimationController: errorController,
                      ),
                    ),

                    SizedBox(height: 30),

                    // زر التحقق
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isVerifying ? null : _verifyOtp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isVerifying
                            ? CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'تحقق من الرمز',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward, size: 20),
                                ],
                              ),
                      ),
                    ),

                    SizedBox(height: 30),

                    // زر إعادة الإرسال
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'لم يصلك الرمز؟',
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: _isResending ? null : _resendOtp,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _isResending
                                    ? Colors.grey[200]!
                                    : AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isResending
                                      ? Colors.grey[300]!
                                      : AppColors.primary,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    size: 18,
                                    color: _isResending
                                        ? Colors.grey
                                        : AppColors.primary,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _isResending
                                        ? 'جاري الإرسال...'
                                        : 'إعادة إرسال الرمز',
                                    style: TextStyle(
                                      color: _isResending
                                          ? Colors.grey
                                          : AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}