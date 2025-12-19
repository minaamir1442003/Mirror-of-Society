import 'package:app_1/core/constants/dio_client.dart';
import 'package:app_1/core/theme/app_colors.dart';

import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/category_model.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/register_request.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/zodiac_model.dart';
import 'package:app_1/presentation/screens/auth/regesteration/repositories/general_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../cubit/register_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKeys = List.generate(4, (_) => GlobalKey<FormState>());
  int _currentStep = 0;
  final _picker = ImagePicker();

  // Controllers للمرحلة الأولى
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  // Controllers للمرحلة الثانية
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Controllers للمرحلة الثالثة
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  DateTime? _selectedDate;

  // Controller لمواصفات البرج
  final _zodiacDescriptionController = TextEditingController();

  // قوائم البيانات الحقيقية
  List<CategoryModel> _availableCategories = [];
  List<ZodiacModel> _availableZodiacs = [];
  List<int> _selectedInterests = [];

  // حالات التحميل
  bool _isLoadingCategories = false;
  bool _isLoadingZodiacs = false;

  // المرحلة الرابعة
  String? _imagePath;
  String? _coverPath;

  // متغيرات لإظهار/إخفاء كلمة المرور
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // شروط قوة كلمة المرور
  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumbers = false;
  bool _hasSpecialChar = false;

  // متغيرات البرج
  String? _calculatedZodiacSign; // الاسم العربي
  String? _autoZodiacDescription;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordStrength);
    _zodiacDescriptionController.addListener(_onZodiacDescriptionChanged);

    // جلب البيانات عند تهيئة الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _zodiacDescriptionController.dispose();
    _passwordController.removeListener(_checkPasswordStrength);
    _zodiacDescriptionController.removeListener(_onZodiacDescriptionChanged);
    super.dispose();
  }

  // دالة لجلب البيانات من API
  Future<void> _fetchData() async {
    final langProvider = context.read<LanguageProvider>();
    final generalRepo = GeneralRepository(dioClient: DioClient());

    setState(() {
      _isLoadingCategories = true;
      _isLoadingZodiacs = true;
    });

    try {
      // الحل: جلب البيانات بشكل منفصل مع التعامل مع الأخطاء
      final categories = await generalRepo.getCategories(
        langProvider.getCurrentLanguageName(),
      );
      final zodiacs = await generalRepo.getZodiacs(
        langProvider.getCurrentLanguageName(),
      );

      setState(() {
        _availableCategories = categories;
        _availableZodiacs = zodiacs;
      });

      print('✅ Categories loaded: ${categories.length} items');
      print('✅ Zodiacs loaded: ${zodiacs.length} items');
    } catch (e) {
      print('❌ Error fetching data: $e');
      if (mounted) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'فشل في تحميل البيانات: ${e.toString()}'
              : 'Failed to load data: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingCategories = false;
          _isLoadingZodiacs = false;
        });
      }
    }
  }

  void _onZodiacDescriptionChanged() {
    setState(() {});
  }

  // التحقق من قوة كلمة المرور
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

  // حساب نقاط قوة كلمة المرور
  double _calculatePasswordStrength() {
    int conditionsMet = 0;
    if (_hasMinLength) conditionsMet++;
    if (_hasUpperCase) conditionsMet++;
    if (_hasLowerCase) conditionsMet++;
    if (_hasNumbers) conditionsMet++;
    if (_hasSpecialChar) conditionsMet++;

    return conditionsMet / 5.0;
  }

  // الحصول على لون شريط القوة
  Color _getStrengthColor() {
    final strength = _calculatePasswordStrength();
    if (strength < 0.4) return Colors.red;
    if (strength < 0.8) return Colors.orange;
    return Colors.green;
  }

  // الحصول على نص قوة كلمة المرور
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

  Future<void> _selectDate(BuildContext context) async {
    final langProvider = context.read<LanguageProvider>();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: langProvider.isArabic ? const Locale('ar') : const Locale('en'),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _calculateZodiac();
      });
    }
  }

  void _calculateZodiac() {
    if (_selectedDate == null) return;

    // حساب البرج بالعربية
    final zodiacSign = _calculateZodiacSign(_selectedDate);
    if (zodiacSign != null) {
      // البحث عن الوصف في القائمة
      final foundZodiac = _availableZodiacs.firstWhere(
        (zodiac) => zodiac.name == zodiacSign,
        orElse:
            () => ZodiacModel(
              id: 0,
              name: zodiacSign,
              description: 'لم يتم العثور على وصف لهذا البرج',
              icon: null,
            ),
      );

      setState(() {
        _calculatedZodiacSign = zodiacSign;
        _autoZodiacDescription = foundZodiac.description;
      });

      // تعيين الوصف التلقائي إذا لم يكن المستخدم قد عدل عليه
      if (_zodiacDescriptionController.text.isEmpty &&
          foundZodiac.description.isNotEmpty) {
        _zodiacDescriptionController.text = foundZodiac.description;
      }
    }
  }

  // حساب البرج باللغة العربية
  String? _calculateZodiacSign(DateTime? date) {
    if (date == null) return null;

    int month = date.month;
    int day = date.day;

    // الجدي: ديسمبر 22 - يناير 19
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'الجدي';
    // الدلو: يناير 20 - فبراير 18
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'الدلو';
    // الحوت: فبراير 19 - مارس 20
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'الحوت';
    // الحمل: مارس 21 - أبريل 19
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'الحمل';
    // الثور: أبريل 20 - مايو 20
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'الثور';
    // الجوزاء: مايو 21 - يونيو 20
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20))
      return 'الجوزاء';
    // السرطان: يونيو 21 - يوليو 22
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22))
      return 'السرطان';
    // الأسد: يوليو 23 - أغسطس 22
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'الأسد';
    // العذراء: أغسطس 23 - سبتمبر 22
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22))
      return 'العذراء';
    // الميزان: سبتمبر 23 - أكتوبر 22
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22))
      return 'الميزان';
    // العقرب: أكتوبر 23 - نوفمبر 21
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21))
      return 'العقرب';
    // القوس: نوفمبر 22 - ديسمبر 21
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21))
      return 'القوس';

    return null;
  }

  // ترجمة اسم البرج للغة المستخدم
  String _getZodiacDisplayName(BuildContext context, String? arabicZodiacSign) {
    final langProvider = context.read<LanguageProvider>();
    if (arabicZodiacSign == null) return '';

    // إذا كانت اللغة عربية، أظهر الاسم العربي
    if (langProvider.isArabic) {
      return arabicZodiacSign;
    }

    // إذا كانت اللغة إنجليزية، ترجم للانجليزي
    return GeneralRepository.translateZodiacName(arabicZodiacSign);
  }

  bool _validateCurrentStep(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    if (!_formKeys[_currentStep].currentState!.validate()) {
      return false;
    }

    switch (_currentStep) {
      case 0:
        if (_firstNameController.text.isEmpty ||
            _lastNameController.text.isEmpty) {
          _showError(
            langProvider.isArabic
                ? 'الاسم الأول والأخير مطلوبان'
                : 'First and last name are required',
          );
          return false;
        }
        break;
      case 1:
        if (_passwordController.text != _confirmPasswordController.text) {
          _showError(
            langProvider.isArabic
                ? 'كلمات المرور غير متطابقة'
                : 'Passwords do not match',
          );
          return false;
        }
        if (_passwordController.text.length < 8) {
          _showError(
            langProvider.isArabic
                ? 'كلمة المرور يجب أن تكون 8 أحرف على الأقل'
                : 'Password must be at least 8 characters',
          );
          return false;
        }
        // التحقق من قوة كلمة المرور
        if (_calculatePasswordStrength() < 0.6) {
          _showError(
            langProvider.isArabic
                ? 'كلمة المرور يجب أن تكون أقوى'
                : 'Password must be stronger',
          );
          return false;
        }
        break;
      case 2:
        if (_selectedDate == null) {
          _showError(
            langProvider.isArabic
                ? 'يرجى اختيار تاريخ الميلاد'
                : 'Please select birth date',
          );
          return false;
        }
        if (_selectedInterests.length < 3) {
          _showError(
            langProvider.isArabic
                ? 'يرجى اختيار 3 اهتمامات على الأقل'
                : 'Please select at least 3 interests',
          );
          return false;
        }
        if (_zodiacDescriptionController.text.isEmpty) {
          _showError(
            langProvider.isArabic
                ? 'يرجى إدخال مواصفات البرج'
                : 'Please enter zodiac description',
          );
          return false;
        }
        break;
    }

    return true;
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

  void _goToNextStep() {
    if (_validateCurrentStep(context)) {
      if (_currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      } else {
        _registerUser();
      }
    }
  }

  void _goToPreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _registerUser() async {
    final langProvider = context.read<LanguageProvider>();

    try {
      // التحقق من تاريخ الميلاد
      if (_selectedDate == null) {
        _showError(
          langProvider.isArabic
              ? 'يرجى اختيار تاريخ الميلاد'
              : 'Please select birth date',
        );
        return;
      }

      // التحقق من البرج
      if (_calculatedZodiacSign == null) {
        _showError(
          langProvider.isArabic
              ? 'تعذر حساب البرج الفلكي'
              : 'Failed to calculate zodiac sign',
        );
        return;
      }

      print('🌟 Zodiac Information:');
      print('   Sign (Arabic): $_calculatedZodiacSign');
      print('   Description: ${_zodiacDescriptionController.text}');
      print('   Birthdate: ${_selectedDate!.toIso8601String().split('T')[0]}');
      print('   Selected Interests: $_selectedInterests');

      // إنشاء Request - إرسال الاسم العربي للبرج
      final request = RegisterRequest(
        firstname: _firstNameController.text.trim(),
        lastname: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        passwordConfirmation: _confirmPasswordController.text,
        phone: _phoneController.text.trim(),
        bio:
            _bioController.text.trim().isNotEmpty
                ? _bioController.text.trim()
                : null,
        zodiac: _calculatedZodiacSign!, // ✅ إرسال الاسم العربي
        zodiacDescription: _zodiacDescriptionController.text,
        shareLocation: true,
        shareZodiac: true,
        birthdate: _selectedDate!.toIso8601String().split('T')[0],
        country: 'Egypt',
        interests: _selectedInterests,
        imagePath: _imagePath,
        coverPath: _coverPath,
      );

      // إرسال Request
      context.read<RegisterCubit>().register(request);
    } catch (e) {
      _showError(
        langProvider.isArabic
            ? 'حدث خطأ أثناء إنشاء الحساب: ${e.toString()}'
            : 'Error creating account: ${e.toString()}',
      );
    }
  }

  Widget _buildStepIndicator(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          width: 30,
          height: 30,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index <= _currentStep ? AppColors.primary : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: index <= _currentStep ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStepContent(BuildContext context) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(context);
      case 1:
        return _buildStep2(context);
      case 2:
        return _buildStep3(context);
      case 3:
        return _buildStep4(context);
      default:
        return Container();
    }
  }

  Future<void> _pickImage(BuildContext context, bool isCover) async {
    final langProvider = context.read<LanguageProvider>();

    try {
      // اختيار مصدر الصورة
      final ImageSource? source = await _showImageSourceDialog(context);

      if (source == null) return; // المستخدم ألغى

      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (isCover) {
            _coverPath = image.path;
          } else {
            _imagePath = image.path;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              langProvider.isArabic
                  ? 'تم إضافة الصورة بنجاح'
                  : 'Image added successfully',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            langProvider.isArabic
                ? 'حدث خطأ في اختيار الصورة'
                : 'Error selecting image',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  Future<ImageSource?> _showImageSourceDialog(BuildContext context) async {
    final langProvider = context.read<LanguageProvider>();

    return await showDialog<ImageSource>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            langProvider.isArabic ? 'اختر مصدر الصورة' : 'Select Image Source',
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt, color: AppColors.primary),
                title: Text(
                  langProvider.isArabic
                      ? 'التقاط صورة جديدة'
                      : 'Take New Photo',
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: Icon(Icons.photo_library, color: AppColors.primary),
                title: Text(
                  langProvider.isArabic
                      ? 'اختيار من المعرض'
                      : 'Choose from Gallery',
                ),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(langProvider.isArabic ? 'إلغاء' : 'Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStep1(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    return Form(
      key: _formKeys[0],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              langProvider.isArabic
                  ? 'المعلومات الشخصية'
                  : 'Personal Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _firstNameController,
              decoration: InputDecoration(
                labelText: langProvider.isArabic ? 'الاسم الأول' : 'First Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return langProvider.isArabic
                      ? 'يرجى إدخال الاسم الأول'
                      : 'Please enter first name';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _lastNameController,
              decoration: InputDecoration(
                labelText: langProvider.isArabic ? 'الاسم الأخير' : 'Last Name',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return langProvider.isArabic
                      ? 'يرجى إدخال الاسم الأخير'
                      : 'Please enter last name';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final passwordStrength = _calculatePasswordStrength();
    final strengthColor = _getStrengthColor();
    final strengthText = _getStrengthText(context);

    return Form(
      key: _formKeys[1],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              langProvider.isArabic ? 'معلومات الحساب' : 'Account Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText:
                    langProvider.isArabic
                        ? 'البريد الإلكتروني'
                        : 'Email Address',
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

            // حقل كلمة المرور مع زر الإظهار/الإخفاء
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

            // حقل تأكيد كلمة المرور مع زر الإظهار/الإخفاء
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: InputDecoration(
                labelText:
                    langProvider.isArabic
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

            // شروط قوة كلمة المرور تظهر فقط عندما يكتب المستخدم
            if (_passwordController.text.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 16),

                  // شريط قوة كلمة المرور
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
                          color: AppColors.secondary,
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

                  // قائمة شروط كلمة المرور
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
                            color: AppColors.secondary,
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

                        const SizedBox(height: 8),

                        // نص توجيهي
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: strengthColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: strengthColor,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  langProvider.isArabic
                                      ? 'كلمة المرور $strengthText، حاول تحقيق المزيد من الشروط'
                                      : 'Password is $strengthText, try to meet more requirements',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: strengthColor,
                                  ),
                                ),
                              ),
                            ],
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
    );
  }

  // بناء عنصر شرط من شروط كلمة المرور
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

  Widget _buildStep3(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final zodiacDisplayName = _getZodiacDisplayName(
      context,
      _calculatedZodiacSign,
    );

    return Form(
      key: _formKeys[2],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              langProvider.isArabic
                  ? 'المعلومات الإضافية'
                  : 'Additional Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText:
                    langProvider.isArabic ? 'رقم الهاتف' : 'Phone Number',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return langProvider.isArabic
                      ? 'يرجى إدخال رقم الهاتف'
                      : 'Please enter phone number';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _bioController,
              decoration: InputDecoration(
                labelText: langProvider.isArabic ? 'نبذة عنك' : 'About You',
                prefixIcon: const Icon(Icons.info_outline),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // اختيار تاريخ الميلاد وعرض البرج
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.lightGray),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          color: AppColors.darkGray,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedDate != null
                                ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                                : langProvider.isArabic
                                ? 'اختر تاريخ الميلاد'
                                : 'Select Birth Date',
                            style: TextStyle(
                              color:
                                  _selectedDate != null
                                      ? AppColors.secondary
                                      : AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // عرض معلومات البرج إذا تم اختيار تاريخ
                    if (_selectedDate != null && _calculatedZodiacSign != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),

                          // عرض اسم البرج
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        langProvider.isArabic
                                            ? 'برجك الفلكي:'
                                            : 'Your Zodiac Sign:',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.darkGray,
                                        ),
                                      ),
                                      Text(
                                        zodiacDisplayName,
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // عرض الوصف التلقائي للبرج
                          if (_autoZodiacDescription != null &&
                              _autoZodiacDescription!.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  langProvider.isArabic
                                      ? 'مواصفات البرج:'
                                      : 'Zodiac Description:',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.secondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                    ),
                                  ),
                                  child: Text(
                                    _autoZodiacDescription!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // حقل تعديل مواصفات البرج
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langProvider.isArabic
                      ? 'يمكنك إضافة وصف إضافي للبرج:'
                      : 'You can add additional zodiac description:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _zodiacDescriptionController,
                  decoration: InputDecoration(
                    hintText:
                        langProvider.isArabic
                            ? 'أضف وصفاً إضافياً إذا أردت...'
                            : 'Add additional description if you want...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return langProvider.isArabic
                          ? 'يرجى إدخال مواصفات البرج'
                          : 'Please enter zodiac description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                if (_zodiacDescriptionController.text.isNotEmpty)
                  Text(
                    langProvider.isArabic
                        ? '${_zodiacDescriptionController.text.length} حرف إضافي'
                        : '${_zodiacDescriptionController.text.length} additional characters',
                    style: TextStyle(fontSize: 12, color: AppColors.success),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // اختيار الاهتمامات (Categories الحقيقية)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      langProvider.isArabic
                          ? 'الاهتمامات (اختر 3 على الأقل)'
                          : 'Interests (Select at least 3)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                    if (_isLoadingCategories)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (_isLoadingCategories)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (_availableCategories.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: AppColors.danger),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            langProvider.isArabic
                                ? 'لم يتم تحميل التصنيفات'
                                : 'Categories not loaded',
                            style: TextStyle(color: AppColors.danger),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: AppColors.primary),
                          onPressed: _fetchData,
                        ),
                      ],
                    ),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        _availableCategories.map((category) {
                          bool isSelected = _selectedInterests.contains(
                            category.id,
                          );
                          return FilterChip(
                            label: Text(
                              category.name,
                              style: TextStyle(
                                color: isSelected ? Colors.white : null,
                              ),
                            ),
                            selected: isSelected,
                            backgroundColor: Colors.grey[200],
                            selectedColor: Color(
                              int.parse(category.color.replaceAll('#', '0xFF')),
                            ),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedInterests.add(category.id);
                                } else {
                                  _selectedInterests.remove(category.id);
                                }
                              });
                            },
                            showCheckmark: true,
                            checkmarkColor: Colors.white,
                          );
                        }).toList(),
                  ),

                const SizedBox(height: 8),

                if (_availableCategories.isNotEmpty)
                  Text(
                    langProvider.isArabic
                        ? 'اخترت ${_selectedInterests.length} اهتمامات'
                        : 'Selected ${_selectedInterests.length} interests',
                    style: TextStyle(
                      color:
                          _selectedInterests.length >= 3
                              ? AppColors.success
                              : AppColors.danger,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    return Form(
      key: _formKeys[3],
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              langProvider.isArabic ? 'الصور الشخصية' : 'Profile Pictures',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              langProvider.isArabic
                  ? 'الصور اختيارية - يمكنك تخطي هذه الخطوة'
                  : 'Photos are optional - You can skip this step',
              style: TextStyle(color: AppColors.darkGray),
            ),

            const SizedBox(height: 32),

            // صورة الملف الشخصي
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      langProvider.isArabic
                          ? 'صورة الملف الشخصي'
                          : 'Profile Picture',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_imagePath != null)
                      Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: FileImage(File(_imagePath!)),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    ElevatedButton.icon(
                      onPressed: () => _pickImage(context, false),
                      icon: Icon(
                        _imagePath != null
                            ? Icons.change_circle
                            : Icons.add_a_photo,
                      ),
                      label: Text(
                        langProvider.isArabic
                            ? (_imagePath != null
                                ? 'تغيير الصورة الشخصية'
                                : 'إضافة صورة شخصية')
                            : (_imagePath != null
                                ? 'Change Profile Picture'
                                : 'Add Profile Picture'),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    if (_imagePath != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _imagePath = null;
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          langProvider.isArabic
                              ? 'إزالة الصورة'
                              : 'Remove Photo',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // صورة الغلاف
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      langProvider.isArabic ? 'صورة الغلاف' : 'Cover Photo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_coverPath != null)
                      Column(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(File(_coverPath!)),
                                fit: BoxFit.cover,
                              ),
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),

                    ElevatedButton.icon(
                      onPressed: () => _pickImage(context, true),
                      icon: Icon(
                        _coverPath != null
                            ? Icons.change_circle
                            : Icons.add_photo_alternate,
                      ),
                      label: Text(
                        langProvider.isArabic
                            ? (_coverPath != null
                                ? 'تغيير صورة الغلاف'
                                : 'إضافة صورة غلاف')
                            : (_coverPath != null
                                ? 'Change Cover Photo'
                                : 'Add Cover Photo'),
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),

                    if (_coverPath != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _coverPath = null;
                          });
                        },
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: Text(
                          langProvider.isArabic
                              ? 'إزالة الغلاف'
                              : 'Remove Cover',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            if (_imagePath != null || _coverPath != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.success),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        langProvider.isArabic
                            ? 'تم إضافة ${_imagePath != null ? "صورة شخصية" : ""}${_imagePath != null && _coverPath != null ? " و " : ""}${_coverPath != null ? "صورة غلاف" : ""}'
                            : 'Added ${_imagePath != null ? "profile picture" : ""}${_imagePath != null && _coverPath != null ? " and " : ""}${_coverPath != null ? "cover photo" : ""}',
                        style: TextStyle(
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.darkGray),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      langProvider.isArabic
                          ? 'يمكنك تخطي إضافة الصور والاستمرار'
                          : 'You can skip adding photos and continue',
                      style: TextStyle(color: AppColors.darkGray, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/home', (route) => false);
        }
        if (state is RegisterFailure) {
          _showError(state.error);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            langProvider.isArabic ? 'إنشاء حساب جديد' : 'Create New Account',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (_currentStep > 0) {
                _goToPreviousStep();
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildStepIndicator(context),
                const SizedBox(height: 32),
                Expanded(child: _buildStepContent(context)),
                const SizedBox(height: 32),
                BlocBuilder<RegisterCubit, RegisterState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            state is RegisterLoading ? null : _goToNextStep,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppColors.primary,
                        ),
                        child:
                            state is RegisterLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : Text(
                                  _currentStep == 3
                                      ? (langProvider.isArabic
                                          ? 'إنشاء الحساب'
                                          : 'Create Account')
                                      : (langProvider.isArabic
                                          ? 'التالي'
                                          : 'Next'),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
