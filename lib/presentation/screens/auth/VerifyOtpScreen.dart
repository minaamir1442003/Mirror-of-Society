import 'dart:async';
import 'package:app_1/presentation/screens/auth/NewPasswordScreen.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../core/theme/app_colors.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  
  const VerifyOtpScreen({super.key, required this.email});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  TextEditingController otpController = TextEditingController();
  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  late Timer _timer;
  bool _hasError = false;
  StreamController<ErrorAnimationType> errorController = StreamController<ErrorAnimationType>();

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    errorController.close();
    // لا تتخلص من otpController هنا، دع التخلص يتم تلقائياً
    super.dispose();
  }

  void _startResendTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _verifyOtp() async {
    if (!mounted) return;
    
    if (otpController.text.length != 6) {
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
      });
      errorController.add(ErrorAnimationType.shake);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى إدخال رمز التحقق كاملاً'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // محاكاة التحقق من OTP
      await Future.delayed(Duration(seconds: 2));

      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });

      // الانتقال لشاشة كلمة المرور الجديدة
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => NewPasswordScreen(email: widget.email),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resendOtp() async {
    if (!mounted || _resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    try {
      // محاكاة إعادة إرسال OTP
      await Future.delayed(Duration(seconds: 2));

      if (!mounted) return;
      
      setState(() {
        _isResending = false;
        _resendTimer = 60;
        otpController.clear();
        _hasError = false;
      });

      _startResendTimer();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إعادة إرسال رمز التحقق'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isResending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
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
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                        children: [
                          TextSpan(text: 'أدخل الرمز المرسل إلى '),
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

              // حقل OTP باستخدام pin_code_fields
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
                      onCompleted: (value) {
                        // يتم استدعاؤها تلقائياً عند اكتمال الرمز
                        _verifyOtp();
                      },
                      onChanged: (value) {
                        if (mounted) {
                          setState(() {
                            _hasError = false;
                          });
                        }
                      },
                      beforeTextPaste: (text) {
                        return text != null && text.length == 6 && RegExp(r'^[0-9]+$').hasMatch(text);
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
                      onPressed: _isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                        shadowColor: AppColors.primary.withOpacity(0.3),
                      ),
                      child: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
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
                          onPressed: _resendTimer > 0 || _isResending ? null : _resendOtp,
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                          ),
                          child: _isResending
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Container(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: _resendTimer > 0 ? Colors.grey[200] : AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _resendTimer > 0 ? Colors.grey[300]! : AppColors.primary,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.refresh,
                                        size: 18,
                                        color: _resendTimer > 0 ? Colors.grey : AppColors.primary,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        _resendTimer > 0
                                            ? 'إعادة الإرسال بعد $_resendTimer ثانية'
                                            : 'إعادة إرسال الرمز',
                                        style: TextStyle(
                                          color: _resendTimer > 0 ? Colors.grey : AppColors.primary,
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

                  SizedBox(height: 30),

                  // مؤشر التوقيت
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timer_outlined, size: 20, color: Colors.amber),
                        SizedBox(width: 10),
                        Text(
                          'الوقت المتبقي: ${_resendTimer ~/ 60}:${(_resendTimer % 60).toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.amber[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 20),

                  // نصائح
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, size: 18, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'معلومات مهمة',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        _buildTip('الرمز صالح لمدة 10 دقائق فقط'),
                        _buildTip('تأكد من إدخال الرمز المكون من 6 أرقام'),
                        _buildTip('تحقق من مجلد البريد المزعج (Spam)'),
                        _buildTip('يمكنك نسخ الرمز ولصقه في الحقول'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, size: 16, color: Colors.green),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}