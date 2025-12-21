import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/RegisterData.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/RegisterStep3Screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class RegisterStep2Screen extends StatefulWidget {
  final RegisterData registerData;
  
  const RegisterStep2Screen({
    Key? key,
    required this.registerData,
  }) : super(key: key);

  @override
  _RegisterStep2ScreenState createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // متغيرات لإظهار/إخفاء كلمة المرور
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // شروط قوة كلمة المرور
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _passwordController.removeListener(_checkPasswordStrength);
    super.dispose();
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

      // تحديث بيانات التسجيل
      final updatedData = widget.registerData.copyWith(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterStep3Screen(registerData: updatedData),
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
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

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final passwordStrength = _calculatePasswordStrength();
    final strengthColor = _getStrengthColor();
    final strengthText = _getStrengthText(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          langProvider.isArabic ? 'المرحلة 2: معلومات الحساب' : 'Step 2: Account Information',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
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
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: 0.5,
                    backgroundColor: Colors.grey[200],
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    langProvider.isArabic ? 'معلومات الحساب' : 'Account Information',
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
                      labelText: langProvider.isArabic ? 'البريد الإلكتروني' : 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: langProvider.isArabic ? 'كلمة المرور' : 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: langProvider.isArabic ? 'تأكيد كلمة المرور' : 'Confirm Password',
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
                              langProvider.isArabic ? 'قوة كلمة المرور:' : 'Password Strength:',
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
                                langProvider.isArabic ? 'رقم (0-9)' : 'Number (0-9)',
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
                      ),
                      child: Text(
                        langProvider.isArabic ? 'التالي' : 'Next',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
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