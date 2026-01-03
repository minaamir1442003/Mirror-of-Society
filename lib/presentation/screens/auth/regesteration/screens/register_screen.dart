import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/registration_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/RegisterStep1Screen.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/RegisterStep3Screen.dart';

class RegisterStep2Screen extends StatefulWidget {
  final String? errorMessage;

  const RegisterStep2Screen({
    Key? key,
    this.errorMessage,
  }) : super(key: key);

  @override
  _RegisterStep2ScreenState createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;
  
  // متغير جديد لتتبع إذا كان هناك خطأ في البريد
  bool _hasEmailError = false;
  String? _emailErrorText;

  @override
  void initState() {
    super.initState();

    // تعبئة البيانات من الـ Provider
    final registrationData = context.read<RegistrationProvider>().data;
    if (registrationData.email.isNotEmpty) {
      _emailController.text = registrationData.email;
    }
    if (registrationData.password.isNotEmpty) {
      _passwordController.text = registrationData.password;
      _confirmPasswordController.text = registrationData.password;
      _checkPasswordStrength();
    }

    _passwordController.addListener(_checkPasswordStrength);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showErrorMessageIfExists();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.removeListener(_checkPasswordStrength);
    super.dispose();
  }

  void _showErrorMessageIfExists() {
    if (widget.errorMessage != null && widget.errorMessage!.isNotEmpty) {
      // التحقق إذا كان الخطأ متعلق بالبريد الإلكتروني
      if (widget.errorMessage!.contains('البريد الإلكتروني') || 
          widget.errorMessage!.contains('The email') ||
          widget.errorMessage!.contains('email') ||
          widget.errorMessage!.contains('مستخدم بالفعل') ||
          widget.errorMessage!.contains('already been taken')) {
        setState(() {
          _hasEmailError = true;
          _emailErrorText = widget.errorMessage;
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.errorMessage!,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _checkPasswordStrength() {
    final password = _passwordController.text;

    setState(() {
      _hasMinLength = password.length >= 8;
      _hasUpperCase = password.contains(RegExp(r'[A-Z]'));
      _hasLowerCase = password.contains(RegExp(r'[a-z]'));
      _hasNumbers = password.contains(RegExp(r'[0-9]'));
      _hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    });
  }

  // عند تغيير نص البريد الإلكتروني، إزالة حالة الخطأ
  void _onEmailChanged(String value) {
    if (_hasEmailError) {
      setState(() {
        _hasEmailError = false;
        _emailErrorText = null;
      });
    }
    // تحديث الـ Provider مع كل تغيير
    context.read<RegistrationProvider>().updateField(
      email: value.trim(),
    );
  }

  double _calculatePasswordStrength() {
    int conditionsMet = 0;
    if (_hasMinLength) conditionsMet++;
    if (_hasUpperCase) conditionsMet++;
    if (_hasLowerCase) conditionsMet++;
    if (_hasNumbers) conditionsMet++;
    if (_hasSpecialChar) conditionsMet++;

    return conditionsMet / 5.0;
  }

  Color _getStrengthColor() {
    final strength = _calculatePasswordStrength();
    if (strength < 0.4) return Colors.red;
    if (strength < 0.8) return Colors.orange;
    return Colors.green;
  }

  String _getStrengthText(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final strength = _calculatePasswordStrength();

    if (langProvider.isArabic) {
      if (strength < 0.4) return 'ضعيفة';
      if (strength < 0.8) return 'متوسطة';
      return 'قوية';
    } else {
      if (strength < 0.4) return 'Weak';
      if (strength < 0.8) return 'Medium';
      return 'Strong';
    }
  }

  void _goToNextStep(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'كلمات المرور غير متطابقة'
              : 'Passwords do not match',
        );
        return;
      }

      if (_passwordController.text.length < 8) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
              : 'Password must be at least 8 characters',
        );
        return;
      }

      if (_calculatePasswordStrength() < 0.6) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'كلمة المرور يجب أن تكون أقوى'
              : 'Password must be stronger',
        );
        return;
      }

      // حفظ البيانات في الـ Provider
      final provider = context.read<RegistrationProvider>();
      provider.updateField(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterStep3Screen(),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildRequirementItem(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isMet ? Colors.green : Colors.grey[300],
              border: Border.all(
                color: isMet ? Colors.green : Colors.grey,
                width: 1,
              ),
            ),
            child: Center(
              child: Icon(
                isMet ? Icons.check : Icons.close,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: isMet ? Colors.green : Colors.grey[600],
                fontWeight: isMet ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _saveData() {
    // حفظ البيانات قبل الرجوع
    final provider = context.read<RegistrationProvider>();
    provider.updateField(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final passwordStrength = _calculatePasswordStrength();
    final strengthColor = _getStrengthColor();
    final strengthText = _getStrengthText(context);

    return WillPopScope(
      onWillPop: () async {
        _saveData();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            langProvider.isArabic
                ? 'المرحلة 2: معلومات الحساب'
                : 'Step 2: Account Information',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _saveData();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => RegisterStep1Screen()),
              );
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      langProvider.isArabic ? '2 من 4' : '2 of 4',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.5,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      langProvider.isArabic
                          ? 'معلومات الحساب'
                          : 'Account Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: langProvider.isArabic
                            ? 'البريد الإلكتروني'
                            : 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // **التعديل: إضافة اللون الأحمر عند وجود خطأ**
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasEmailError ? Colors.red : Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _hasEmailError ? Colors.red : Theme.of(context).primaryColor,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.red,
                            width: 2.0,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // **التعديل: إضافة نص الخطأ**
                        errorText: _emailErrorText,
                        errorStyle: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (_emailErrorText != null) {
                          return null; // الخطأ يظهر من المتغير
                        }
                        if (value == null || value.isEmpty) {
                          return langProvider.isArabic
                              ? 'يرجى إدخال البريد الإلكتروني'
                              : 'Please enter email address';
                        }
                        if (!value.contains('@')) {
                          return langProvider.isArabic
                              ? 'البريد الإلكتروني غير صالح'
                              : 'Invalid email address';
                        }
                        return null;
                      },
                      onChanged: _onEmailChanged,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText:
                            langProvider.isArabic ? 'كلمة المرور' : 'Password',
                        prefixIcon: const Icon(Icons.lock_outline),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return langProvider.isArabic
                              ? 'يرجى إدخال كلمة المرور'
                              : 'Please enter password';
                        }
                        if (value.length < 8) {
                          return langProvider.isArabic
                              ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
                              : 'Password must be at least 8 characters';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // تحديث الـ Provider مع كل تغيير
                        context.read<RegistrationProvider>().updateField(
                          password: value,
                        );
                        _checkPasswordStrength();
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: langProvider.isArabic
                            ? 'تأكيد كلمة المرور'
                            : 'Confirm Password',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return langProvider.isArabic
                              ? 'يرجى تأكيد كلمة المرور'
                              : 'Please confirm password';
                        }
                        if (value != _passwordController.text) {
                          return langProvider.isArabic
                              ? 'كلمات المرور غير متطابقة'
                              : 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    if (_passwordController.text.isNotEmpty)
                      Column(
                        children: [
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: passwordStrength,
                            backgroundColor: Colors.grey[200],
                            color: strengthColor,
                            minHeight: 6,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                langProvider.isArabic
                                    ? 'قوة كلمة المرور:'
                                    : 'Password Strength:',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    strengthText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: strengthColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${(passwordStrength * 100).toInt()}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: strengthColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  langProvider.isArabic
                                      ? 'شروط كلمة المرور الآمنة:'
                                      : 'Secure Password Requirements:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildRequirementItem(
                                  langProvider.isArabic
                                      ? '8 أحرف على الأقل'
                                      : 'At least 8 characters',
                                  _hasMinLength,
                                ),
                                _buildRequirementItem(
                                  langProvider.isArabic
                                      ? 'حرف كبير (A-Z)'
                                      : 'Uppercase letter (A-Z)',
                                  _hasUpperCase,
                                ),
                                _buildRequirementItem(
                                  langProvider.isArabic
                                      ? 'حرف صغير (a-z)'
                                      : 'Lowercase letter (a-z)',
                                  _hasLowerCase,
                                ),
                                _buildRequirementItem(
                                  langProvider.isArabic
                                      ? 'رقم (0-9)'
                                      : 'Number (0-9)',
                                  _hasNumbers,
                                ),
                                _buildRequirementItem(
                                  langProvider.isArabic
                                      ? 'رمز خاص (!@#\$...)'
                                      : 'Special character (!@#\$...)',
                                  _hasSpecialChar,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _goToNextStep(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          langProvider.isArabic ? 'التالي' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}