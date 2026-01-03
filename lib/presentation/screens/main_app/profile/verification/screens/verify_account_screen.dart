import 'dart:async';
import 'package:app_1/presentation/screens/main_app/main_screen.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/cubits/verification_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/cubits/verification_state.dart';
import 'package:app_1/core/theme/app_theme.dart';

class VerifyAccountScreen extends StatefulWidget {
  const VerifyAccountScreen({Key? key}) : super(key: key);

  @override
  _VerifyAccountScreenState createState() => _VerifyAccountScreenState();
}

class _VerifyAccountScreenState extends State<VerifyAccountScreen> {
  final TextEditingController _otpController = TextEditingController();
  final StreamController<ErrorAnimationType> _errorController = StreamController<ErrorAnimationType>();
  bool _isResending = false;
  bool _isVerifying = false;
  int _resendTimer = 60;
  Timer? _timer;
  
  // ✅ متغير للتحكم في حالة رؤية النص
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    _errorController.close();
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _resendCode() {
    if (_isResending || _resendTimer > 0) return;

    setState(() {
      _isResending = true;
    });

    context.read<VerificationCubit>().requestVerification().then((_) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
        _startResendTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إعادة إرسال رمز التحقق'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    });
  }

  void _verifyCode() {
    if (_otpController.text.length != 6) {
      _errorController.add(ErrorAnimationType.shake);
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
    
    context.read<VerificationCubit>().verifyAccount(_otpController.text).then((_) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }).catchError((error) {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // ✅ LTR لإدخال الكود من اليسار لليمين
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
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_outlined,
                          size: 40,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'تفعيل حسابك',
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
                            TextSpan(text: 'أدخل الرمز المرسل إلى بريدك\n'),
                            TextSpan(
                              text: 'الإلكتروني لتأكيد تفعيل حسابك',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
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
                        controller: _otpController,
                        obscureText: _obscureText,
                        animationType: AnimationType.scale,
                        animationDuration: Duration(milliseconds: 200),
                        enableActiveFill: true,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.number,
                        autoFocus: true,
                        cursorColor: AppTheme.primaryColor,
                        pinTheme: PinTheme(
                          shape: PinCodeFieldShape.box,
                          borderRadius: BorderRadius.circular(10),
                          fieldHeight: 60,
                          fieldWidth: 50,
                          activeFillColor: Colors.white,
                          activeColor: AppTheme.primaryColor,
                          selectedFillColor: AppTheme.primaryColor.withOpacity(0.1),
                          selectedColor: AppTheme.primaryColor,
                          inactiveFillColor: Colors.grey[50]!,
                          inactiveColor: Colors.grey[300]!,
                          errorBorderColor: Colors.red,
                          borderWidth: 2,
                        ),
                        textStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        autoDisposeControllers: false,
                        autoDismissKeyboard: true,
                        mainAxisAlignment: MainAxisAlignment.center, // ✅ من اليسار لليمين
                        animationCurve: Curves.easeInOut,
                        enablePinAutofill: true,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        autoUnfocus: true,
                        hintCharacter: '•',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          color: Colors.grey[400],
                        ),
                        pastedTextStyle: TextStyle(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                        dialogConfig: DialogConfig(
                          dialogTitle: "لصق الكود",
                          dialogContent: "هل تريد لصق الكود؟",
                          affirmativeText: "نعم",
                          negativeText: "لا",
                        ),
                        onCompleted: (value) {
                          print("Completed: $value");
                          _verifyCode();
                        },
                        onChanged: (value) {
                          print("Changed: $value");
                        },
                        onTap: () {
                          print("Text field tapped");
                        },
                        onSubmitted: (value) {
                          print("Submitted: $value");
                          _verifyCode();
                        },
                        beforeTextPaste: (text) {
                          print("Text to paste: $text");
                          return text != null &&
                              text.length == 6 &&
                              RegExp(r'^[0-9]+$').hasMatch(text);
                        },
                        validator: (value) {
                          if (value != null && value.length == 6) {
                            return null;
                          }
                          return "يجب أن يكون الرمز 6 أرقام";
                        },
                        errorAnimationController: _errorController,
                      ),
                    ),

                    // زر إظهار/إخفاء الرمز (اختياري)
                    SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscureText ? Icons.visibility : Icons.visibility_off,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                        ),
                        SizedBox(width: 8),
                        Text(
                          _obscureText ? 'إظهار الرمز' : 'إخفاء الرمز',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 30),

                    // زر التحقق
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: BlocConsumer<VerificationCubit, VerificationState>(
                        listener: (context, state) {
                          if (state is VerificationSuccess) {
                            _clearProfileCache(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.message),
                                backgroundColor: Colors.green,
                              ),
                            );
                            
                             Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => MainScreen(),
      ),
      (route) => false, // إزالة كل الشاشات السابقة
    );
                          } else if (state is VerificationError) {
                            _errorController.add(ErrorAnimationType.shake);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(state.error),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                        builder: (context, state) {
                          return ElevatedButton(
                            onPressed: (state is VerificationLoading || _isVerifying)
                                ? null
                                : () {
                                    if (_otpController.text.length == 6) {
                                      _verifyCode();
                                    } else {
                                      _errorController.add(ErrorAnimationType.shake);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('يرجى إدخال رمز التحقق كاملاً'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: (state is VerificationLoading || _isVerifying)
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
                          );
                        },
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
                          if (_resendTimer > 0)
                            Text(
                              'يمكنك إعادة الإرسال بعد $_resendTimer ثانية',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          SizedBox(height: 10),
                          TextButton(
                            onPressed: (_isResending || _resendTimer > 0) ? null : _resendCode,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: _isResending
                                    ? Colors.grey[200]!
                                    : AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: _isResending
                                      ? Colors.grey[300]!
                                      : AppTheme.primaryColor,
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
                                        : AppTheme.primaryColor,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    _isResending
                                        ? 'جاري الإرسال...'
                                        : 'إعادة إرسال الرمز',
                                    style: TextStyle(
                                      color: _isResending
                                          ? Colors.grey
                                          : AppTheme.primaryColor,
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

  // ✅ دالة لمسح كاش البروفايل بعد التفعيل
  Future<void> _clearProfileCache(BuildContext context) async {
    try {
      final profileCubit = context.read<ProfileCubit>();
      profileCubit.clearAllData(); // مسح الكاش المخزن
      
      print('✅ Profile cache cleared after verification');
    } catch (e) {
      print('❌ Error clearing profile cache: $e');
    }
  }
}