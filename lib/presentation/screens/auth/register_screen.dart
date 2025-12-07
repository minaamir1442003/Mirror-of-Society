import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({
    Key? key,
    this.onLoginPressed,
    this.onRegisterSuccess,
  }) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  DateTime? _selectedDate;
  List<String> _selectedInterests = [];

  final List<String> _interests = [
    'تكنولوجيا',
    'رياضة',
    'فن',
    'سياسة',
    'اقتصاد',
    'صحة',
    'سفر',
    'تعليم',
    'ألعاب',
    'موسيقى',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String? _calculateZodiacSign(DateTime? date) {
    if (date == null) return null;
    
    int month = date.month;
    int day = date.day;
    
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'الدلو ♒️';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'الحوت ♓️';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'الحمل ♈️';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'الثور ♉️';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'الجوزاء ♊️';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'السرطان ♋️';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'الأسد ♌️';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'العذراء ♍️';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'الميزان ♎️';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'العقرب ♏️';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'القوس ♐️';
    return 'الجدي ♑️';
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار تاريخ الميلاد'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    if (_selectedInterests.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى اختيار اهتمام واحد على الأقل'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // محاكاة عملية التسجيل
    await Future.delayed(Duration(seconds: 3));

    setState(() {
      _isLoading = false;
    });

    // عرض معلومات البرج
    _showZodiacInfo();

    if (widget.onRegisterSuccess != null) {
      widget.onRegisterSuccess!();
    } else {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _showZodiacInfo() {
    final zodiacSign = _calculateZodiacSign(_selectedDate);
    final traits = _getZodiacTraits(zodiacSign);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('🎉 تم التسجيل بنجاح!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً بك في البرقيات ${_nameController.text}!'),
            SizedBox(height: 16),
            if (zodiacSign != null) ...[
              Text(
                'برجك هو: $zodiacSign',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 8),
              Text('صفات برجك:'),
              ...traits.map((trait) => Text('• $trait')).toList(),
              SizedBox(height: 16),
              Text(
                'يمكنك تعديل صفات برجك لاحقاً من صفحة ملفك الشخصي',
                style: TextStyle(fontSize: 12, color: AppColors.darkGray),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text('متابعة'),
          ),
        ],
      ),
    );
  }

  List<String> _getZodiacTraits(String? zodiacSign) {
    switch (zodiacSign) {
      case 'الجوزاء ♊️':
        return ['اجتماعي', 'ذكي', 'مبدع', 'مرح'];
      case 'الحوت ♓️':
        return ['حساس', 'خلاق', 'متعاطف', 'حدسي'];
      case 'الحمل ♈️':
        return ['نشيط', 'قائد', 'مغامر', 'صريح'];
      case 'الثور ♉️':
        return ['صبور', 'عملي', 'مستقر', 'موثوق'];
      case 'السرطان ♋️':
        return ['عاطفي', 'وقائي', 'حدسي', 'لطيف'];
      case 'الأسد ♌️':
        return ['واثق', 'كريم', 'مبدع', 'قائد'];
      case 'العذراء ♍️':
        return ['منظم', 'دقيق', 'مخلص', 'عملي'];
      case 'الميزان ♎️':
        return ['دبلوماسي', 'اجتماعي', 'عادل', 'رومانسي'];
      case 'العقرب ♏️':
        return ['شغوف', 'مصمم', 'مخلص', 'حدسي'];
      case 'القوس ♐️':
        return ['متفائل', 'مغامر', 'صريح', 'فلسفي'];
      case 'الجدي ♑️':
        return ['مسؤول', 'منضبط', 'صبور', 'طموح'];
      case 'الدلو ♒️':
        return ['مستقل', 'مبتكر', 'إنساني', 'فريد'];
      default:
        return ['اجتماعي', 'مبدع', 'متعاون'];
    }
  }

  Widget _buildInterestChip(String interest) {
    bool isSelected = _selectedInterests.contains(interest);
    
    return FilterChip(
      label: Text(interest),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          if (selected) {
            _selectedInterests.add(interest);
          } else {
            _selectedInterests.remove(interest);
          }
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.darkGray,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.lightGray,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // زر العودة
              IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              
              SizedBox(height: 20),
              
              // عنوان الصفحة
              Text(
                'انضم إلينا',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
              Text(
                'أنشئ حسابك لتبدأ نشر البرقيات',
                style: TextStyle(
                  color: AppColors.darkGray,
                ),
              ),
              
              SizedBox(height: 32),
              
              // نموذج التسجيل
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // الاسم الكامل
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الكامل',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال الاسم الكامل';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // اسم المستخدم
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم',
                        prefixIcon: Icon(Icons.alternate_email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال اسم المستخدم';
                        }
                        if (value.length < 3) {
                          return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // البريد الإلكتروني
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'البريد الإلكتروني',
                        prefixIcon: Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!value.contains('@')) {
                          return 'البريد الإلكتروني غير صالح';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // كلمة المرور
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
                          borderRadius: BorderRadius.circular(12),
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
                    
                    SizedBox(height: 16),
                    
                    // تأكيد كلمة المرور
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'تأكيد كلمة المرور',
                        prefixIcon: Icon(Icons.lock_outline),
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
                          return 'يرجى تأكيد كلمة المرور';
                        }
                        if (value != _passwordController.text) {
                          return 'كلمات المرور غير متطابقة';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: 16),
                    
                    // تاريخ الميلاد
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.lightGray),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppColors.darkGray,
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _selectedDate != null
                                    ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                                    : 'اختر تاريخ الميلاد',
                                style: TextStyle(
                                  color: _selectedDate != null
                                      ? AppColors.secondary
                                      : AppColors.darkGray,
                                ),
                              ),
                            ),
                            if (_selectedDate != null)
                              Text(
                                _calculateZodiacSign(_selectedDate) ?? '',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    SizedBox(height: 16),
                    
                    // الاهتمامات
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الاهتمامات (اختر 3 على الأقل)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.secondary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'ستظهر لك البرقيات بناءً على اهتماماتك',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.darkGray,
                          ),
                        ),
                        SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _interests.map(_buildInterestChip).toList(),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'اخترت ${_selectedInterests.length} اهتمامات',
                          style: TextStyle(
                            fontSize: 12,
                            color: _selectedInterests.length >= 3
                                ? AppColors.success
                                : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 32),
                    
                    // شروط الخدمة
                    Row(
                      children: [
                        Checkbox(
                          value: true,
                          onChanged: null,
                          activeColor: AppColors.primary,
                        ),
                        Expanded(
                          child: Text(
                            'أوافق على شروط الخدمة وسياسة الخصوصية',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 24),
                    
                    // زر التسجيل
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _register,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                            : Text(
                                'إنشاء حساب',
                                style: TextStyle(fontSize: 16,color: Colors.white),
                              ),
                      ),
                    ),
                    
                    SizedBox(height: 32),
                    
                    // رابط تسجيل الدخول
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: widget.onLoginPressed ?? () {
                            Navigator.pushReplacementNamed(context, '/login');
                          },
                          child: Text(
                            'سجل دخول',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                            ),
                          ),
                        ),
                        Text(
                          'لديك حساب بالفعل؟',
                          style: TextStyle(color: AppColors.darkGray,fontSize: 15),
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
  }
}