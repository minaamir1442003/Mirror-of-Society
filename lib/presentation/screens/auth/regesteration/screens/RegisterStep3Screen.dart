import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/registration_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/RegisterStep4Screen.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/category_model.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/zodiac_model.dart';
import 'package:app_1/presentation/screens/auth/regesteration/repositories/general_repository.dart';
import 'package:app_1/core/constants/dio_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RegisterStep3Screen extends StatefulWidget {
  const RegisterStep3Screen({Key? key}) : super(key: key);

  @override
  _RegisterStep3ScreenState createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _zodiacDescriptionController = TextEditingController();

  DateTime? _selectedDate;
  String? _calculatedZodiacSign;

  List<CategoryModel> _availableCategories = [];
  List<ZodiacModel> _availableZodiacs = [];
  List<int> _selectedInterests = [];

  bool _isLoadingCategories = false;
  bool _isAutoDescription = false;
  bool _isLoadingZodiacs = false;
  String? _autoZodiacDescription;

  final Map<String, String> _zodiacTranslationMap = {
    'الجدي': 'Capricorn',
    'الدلو': 'Aquarius',
    'الحوت': 'Pisces',
    'الحمل': 'Aries',
    'الثور': 'Taurus',
    'الجوزاء': 'Gemini',
    'السرطان': 'Cancer',
    'الأسد': 'Leo',
    'العذراء': 'Virgo',
    'الميزان': 'Libra',
    'العقرب': 'Scorpio',
    'القوس': 'Sagittarius',
  };

  @override
  void initState() {
    super.initState();
    
    // تعبئة البيانات من الـ Provider
    final registrationData = context.read<RegistrationProvider>().data;
    
    if (registrationData.phone.isNotEmpty) {
      _phoneController.text = registrationData.phone;
    }
    
    if (registrationData.bio != null && registrationData.bio!.isNotEmpty) {
      _bioController.text = registrationData.bio!;
    }
    
    if (registrationData.birthdate != null) {
      _selectedDate = registrationData.birthdate;
      _calculatedZodiacSign = registrationData.zodiac;
    }
    
    if (registrationData.zodiacDescription.isNotEmpty) {
      _zodiacDescriptionController.text = registrationData.zodiacDescription;
    }
    
    if (registrationData.interests.isNotEmpty) {
      _selectedInterests = List.from(registrationData.interests);
    }
    
    _zodiacDescriptionController.addListener(_onZodiacDescriptionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _bioController.dispose();
    _zodiacDescriptionController.dispose();
    _zodiacDescriptionController.removeListener(_onZodiacDescriptionChanged);
    super.dispose();
  }

  void _onZodiacDescriptionChanged() {
    if (_isAutoDescription) {
      setState(() {
        _isAutoDescription = false;
      });
    }
  }

  Future<void> _fetchData() async {
    final langProvider = context.read<LanguageProvider>();
    final generalRepo = GeneralRepository(dioClient: DioClient());

    setState(() {
      _isLoadingCategories = true;
      _isLoadingZodiacs = true;
    });

    try {
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
    } catch (e) {
      print('❌ Error fetching data: $e');
      if (mounted) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'فشل في تحميل البيانات'
              : 'Failed to load data',
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
      
      // تحديث الـ Provider
      context.read<RegistrationProvider>().updateField(
        birthdate: _selectedDate,
        zodiac: _calculatedZodiacSign,
      );
    }
  }

  void _calculateZodiac() {
    if (_selectedDate == null) return;

    final arabicZodiacSign = _calculateZodiacSign(_selectedDate);
    if (arabicZodiacSign != null) {
      final currentLang = context.read<LanguageProvider>().isArabic;
      String zodiacNameToSearch = currentLang 
          ? arabicZodiacSign 
          : (_zodiacTranslationMap[arabicZodiacSign] ?? arabicZodiacSign);

      final foundZodiac = _availableZodiacs.firstWhere(
        (zodiac) => zodiac.name == zodiacNameToSearch,
        orElse: () => ZodiacModel(
          id: 0,
          name: zodiacNameToSearch,
          description: currentLang ? 'لم يتم العثور على وصف' : 'Description not found',
          icon: null,
        ),
      );

      setState(() {
        _calculatedZodiacSign = arabicZodiacSign;
        _autoZodiacDescription = foundZodiac.description;
        _isAutoDescription = true;
      });

      _zodiacDescriptionController.text = foundZodiac.description;
      
      // تحديث الـ Provider
      context.read<RegistrationProvider>().updateField(
        zodiac: _calculatedZodiacSign,
        zodiacDescription: foundZodiac.description,
      );
      
      if (_formKey.currentState != null) {
        _formKey.currentState!.validate();
      }
    }
  }

  String? _calculateZodiacSign(DateTime? date) {
    if (date == null) return null;
    int month = date.month;
    int day = date.day;

    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'الجدي';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'الدلو';
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return 'الحوت';
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'الحمل';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'الثور';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'الجوزاء';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'السرطان';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'الأسد';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'العذراء';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'الميزان';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'العقرب';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'القوس';

    return null;
  }

  String _getZodiacDisplayName(BuildContext context, String? arabicZodiacSign) {
    final langProvider = context.read<LanguageProvider>();
    if (arabicZodiacSign == null) return '';

    if (langProvider.isArabic) {
      return arabicZodiacSign;
    }

    return _zodiacTranslationMap[arabicZodiacSign] ?? arabicZodiacSign;
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

  void _goToNextStep(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'يرجى اختيار تاريخ الميلاد'
              : 'Please select birth date',
        );
        return;
      }
      if (_selectedInterests.length < 3) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'يرجى اختيار 3 اهتمامات على الأقل'
              : 'Please select at least 3 interests',
        );
        return;
      }
      if (_zodiacDescriptionController.text.isEmpty) {
        _showError(
          context.read<LanguageProvider>().isArabic
              ? 'يرجى إدخال مواصفات البرج'
              : 'Please enter zodiac description',
        );
        return;
      }

      // حفظ البيانات في الـ Provider
      final provider = context.read<RegistrationProvider>();
      provider.updateField(
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        birthdate: _selectedDate,
        zodiac: _calculatedZodiacSign,
        zodiacDescription: _zodiacDescriptionController.text,
        interests: _selectedInterests,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterStep4Screen(),
        ),
      );
    }
  }

  void _saveData() {
    // حفظ البيانات قبل الرجوع
    final provider = context.read<RegistrationProvider>();
    provider.updateField(
      phone: _phoneController.text.trim(),
      bio: _bioController.text.trim(),
      birthdate: _selectedDate,
      zodiac: _calculatedZodiacSign,
      zodiacDescription: _zodiacDescriptionController.text,
      interests: _selectedInterests,
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final zodiacDisplayName = _getZodiacDisplayName(
      context,
      _calculatedZodiacSign,
    );

    return WillPopScope(
      onWillPop: () async {
        _saveData();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            langProvider.isArabic ? 'المرحلة 3: معلومات إضافية' : 'Step 3: Additional Information',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _saveData();
              Navigator.pop(context);
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
                      langProvider.isArabic ? '3 من 4' : '3 of 4',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 0.75,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      langProvider.isArabic ? 'المعلومات الإضافية' : 'Additional Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: langProvider.isArabic ? 'رقم الهاتف' : 'Phone Number',
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
                      onChanged: (value) {
                        context.read<RegistrationProvider>().updateField(
                          phone: value.trim(),
                        );
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
                      onChanged: (value) {
                        context.read<RegistrationProvider>().updateField(
                          bio: value.trim(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, color: Colors.grey),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    _selectedDate != null
                                        ? '${_selectedDate!.year}/${_selectedDate!.month}/${_selectedDate!.day}'
                                        : langProvider.isArabic
                                            ? 'اختر تاريخ الميلاد'
                                            : 'Select Birth Date',
                                    style: TextStyle(
                                      color: _selectedDate != null
                                          ? Theme.of(context).primaryColor
                                          : Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedDate != null && _calculatedZodiacSign != null)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                langProvider.isArabic
                                                    ? 'برجك الفلكي:'
                                                    : 'Your Zodiac Sign:',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                              Text(
                                                zodiacDisplayName,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Theme.of(context).primaryColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_isAutoDescription)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.info, size: 14, color: Colors.blue),
                                          const SizedBox(width: 4),
                                          Text(
                                            langProvider.isArabic
                                                ? '(تم ملؤه تلقائياً)'
                                                : '(Auto-filled)',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.blue,
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
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              langProvider.isArabic
                                  ? 'وصف البرج:'
                                  : 'Zodiac Description:',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (_isAutoDescription)
                              TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _zodiacDescriptionController.text = '';
                                    _isAutoDescription = false;
                                  });
                                },
                                icon: const Icon(Icons.edit, size: 16),
                                label: Text(
                                  langProvider.isArabic ? 'تعديل' : 'Edit',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _zodiacDescriptionController,
                          decoration: InputDecoration(
                            hintText: langProvider.isArabic
                                ? 'سيتم ملؤه تلقائياً عند اختيار تاريخ الميلاد...'
                                : 'Will be auto-filled when selecting birth date...',
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
                          onChanged: (value) {
                            context.read<RegistrationProvider>().updateField(
                              zodiacDescription: value,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            if (_isLoadingCategories)
                              const Padding(
                                padding: EdgeInsets.only(left: 8),
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (_isLoadingCategories)
                          const Center(child: CircularProgressIndicator())
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
                                const Icon(Icons.error_outline, color: Colors.red),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    langProvider.isArabic
                                        ? 'لم يتم تحميل التصنيفات'
                                        : 'Categories not loaded',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.refresh),
                                  onPressed: _fetchData,
                                ),
                              ],
                            ),
                          )
                        else
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableCategories.map((category) {
                              bool isSelected = _selectedInterests.contains(category.id);
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
                                    // تحديث الـ Provider
                                    context.read<RegistrationProvider>().updateField(
                                      interests: _selectedInterests,
                                    );
                                  });
                                },
                                showCheckmark: true,
                                checkmarkColor: Colors.white,
                              );
                            }).toList(),
                          ),
                        if (_availableCategories.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              langProvider.isArabic
                                  ? 'اخترت ${_selectedInterests.length} اهتمامات'
                                  : 'Selected ${_selectedInterests.length} interests',
                              style: TextStyle(
                                color: _selectedInterests.length >= 3
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
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
      ),
    );
  }
}