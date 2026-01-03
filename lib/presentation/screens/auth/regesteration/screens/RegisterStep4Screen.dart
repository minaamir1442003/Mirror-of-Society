import 'dart:io';
import 'package:app_1/data/services/country_service.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../cubit/register_cubit.dart';
import '../models/register_request.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/registration_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/screens/RegisterStep3Screen.dart';

class RegisterStep4Screen extends StatefulWidget {
  const RegisterStep4Screen({Key? key}) : super(key: key);

  @override
  _RegisterStep4ScreenState createState() => _RegisterStep4ScreenState();
}

class _RegisterStep4ScreenState extends State<RegisterStep4Screen> {
  final _picker = ImagePicker();
  
  String? _imagePath;
  String? _coverPath;
  bool _isLoading = false;
  
  bool _shareLocation = false;
  bool _shareZodiac = false;
  String _selectedCountry = 'Egypt';
  bool _isLoadingCountry = false;

  final List<Map<String, String>> _countriesArabic = [
    {'name': 'مصر', 'value': 'Egypt'},
    {'name': 'السعودية', 'value': 'Saudi Arabia'},
    {'name': 'الإمارات', 'value': 'UAE'},
    {'name': 'الكويت', 'value': 'Kuwait'},
    {'name': 'قطر', 'value': 'Qatar'},
    {'name': 'عمان', 'value': 'Oman'},
    {'name': 'البحرين', 'value': 'Bahrain'},
    {'name': 'الأردن', 'value': 'Jordan'},
    {'name': 'لبنان', 'value': 'Lebanon'},
    {'name': 'سوريا', 'value': 'Syria'},
    {'name': 'العراق', 'value': 'Iraq'},
    {'name': 'اليمن', 'value': 'Yemen'},
    {'name': 'ليبيا', 'value': 'Libya'},
    {'name': 'تونس', 'value': 'Tunisia'},
    {'name': 'الجزائر', 'value': 'Algeria'},
    {'name': 'المغرب', 'value': 'Morocco'},
    {'name': 'السودان', 'value': 'Sudan'},
    {'name': 'الصومال', 'value': 'Somalia'},
    {'name': 'فلسطين', 'value': 'Palestine'},
    {'name': 'جيبوتي', 'value': 'Djibouti'},
    {'name': 'موريتانيا', 'value': 'Mauritania'},
    {'name': 'جزر القمر', 'value': 'Comoros'},
    {'name': 'تركيا', 'value': 'Turkey'},
    {'name': 'إيران', 'value': 'Iran'},
    {'name': 'باكستان', 'value': 'Pakistan'},
    {'name': 'أفغانستان', 'value': 'Afghanistan'},
  ];

  final List<Map<String, String>> _countriesEnglish = [
    {'name': 'Egypt', 'value': 'Egypt'},
    {'name': 'Saudi Arabia', 'value': 'Saudi Arabia'},
    {'name': 'UAE', 'value': 'UAE'},
    {'name': 'Kuwait', 'value': 'Kuwait'},
    {'name': 'Qatar', 'value': 'Qatar'},
    {'name': 'Oman', 'value': 'Oman'},
    {'name': 'Bahrain', 'value': 'Bahrain'},
    {'name': 'Jordan', 'value': 'Jordan'},
    {'name': 'Lebanon', 'value': 'Lebanon'},
    {'name': 'Syria', 'value': 'Syria'},
    {'name': 'Iraq', 'value': 'Iraq'},
    {'name': 'Yemen', 'value': 'Yemen'},
    {'name': 'Libya', 'value': 'Libya'},
    {'name': 'Tunisia', 'value': 'Tunisia'},
    {'name': 'Algeria', 'value': 'Algeria'},
    {'name': 'Morocco', 'value': 'Morocco'},
    {'name': 'Sudan', 'value': 'Sudan'},
    {'name': 'Somalia', 'value': 'Somalia'},
    {'name': 'Palestine', 'value': 'Palestine'},
    {'name': 'Djibouti', 'value': 'Djibouti'},
    {'name': 'Mauritania', 'value': 'Mauritania'},
    {'name': 'Comoros', 'value': 'Comoros'},
    {'name': 'Turkey', 'value': 'Turkey'},
    {'name': 'Iran', 'value': 'Iran'},
    {'name': 'Pakistan', 'value': 'Pakistan'},
    {'name': 'Afghanistan', 'value': 'Afghanistan'},
  ];

  @override
  void initState() {
    super.initState();
    
    // تعبئة البيانات من الـ Provider
    final registrationData = context.read<RegistrationProvider>().data;
    
    _imagePath = registrationData.imagePath;
    _coverPath = registrationData.coverPath;
    _shareLocation = registrationData.shareLocation;
    _shareZodiac = registrationData.shareZodiac;
    _selectedCountry = registrationData.country;
    
    // **التعديل: جلب البلد من الجهاز عند تشغيل الشاشة**
    _getDeviceCountry();
  }
  
  // **التعديل: دالة جديدة لجلب البلد من الجهاز**
  Future<void> _getDeviceCountry() async {
    setState(() {
      _isLoadingCountry = true;
    });
    
    try {
      final deviceCountry = await CountryService.getDeviceCountry();
      print('📱 Device country detected: $deviceCountry');
      
      // تحديث القيمة فقط إذا كانت shareLocation مفعلة
      if (_shareLocation) {
        setState(() {
          _selectedCountry = deviceCountry;
        });
        context.read<RegistrationProvider>().updateField(
          country: deviceCountry,
        );
      }
    } catch (e) {
      print('❌ Error getting device country: $e');
    } finally {
      setState(() {
        _isLoadingCountry = false;
      });
    }
  }

  List<Map<String, String>> _getCountriesByLanguage(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    return langProvider.isArabic ? _countriesArabic : _countriesEnglish;
  }

  Future<void> _pickImage(BuildContext context, bool isCover) async {
    final langProvider = context.read<LanguageProvider>();

    try {
      final ImageSource? source = await _showImageSourceDialog(context);
      if (source == null) return;

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

        // تحديث الـ Provider
        context.read<RegistrationProvider>().updateField(
          imagePath: _imagePath,
          coverPath: _coverPath,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              langProvider.isArabic
                  ? 'تم إضافة الصورة بنجاح'
                  : 'Image added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            langProvider.isArabic
                ? 'حدث خطأ في اختيار الصورة'
                : 'Error selecting image',
          ),
          backgroundColor: Colors.red,
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
                leading: const Icon(Icons.camera_alt),
                title: Text(
                  langProvider.isArabic
                      ? 'التقاط صورة جديدة'
                      : 'Take New Photo',
                ),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
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

  Future<void> _registerUser(BuildContext context) async {
    final langProvider = context.read<LanguageProvider>();
    final registrationData = context.read<RegistrationProvider>().data;

    try {
      // التحقق من البيانات المطلوبة
      if (registrationData.birthdate == null) {
        _showErrorAndNavigate(
          context,
          langProvider.isArabic ? 'يرجى اختيار تاريخ الميلاد' : 'Please select birth date',
          3,
        );
        return;
      }

      if (registrationData.zodiac == null) {
        _showErrorAndNavigate(
          context,
          langProvider.isArabic ? 'تعذر حساب البرج الفلكي' : 'Failed to calculate zodiac sign',
          3,
        );
        return;
      }

      if (registrationData.interests.length < 3) {
        _showErrorAndNavigate(
          context,
          langProvider.isArabic ? 'يرجى اختيار 3 اهتمامات على الأقل' : 'Please select at least 3 interests',
          3,
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final request = RegisterRequest(
        firstname: registrationData.firstName,
        lastname: registrationData.lastName,
        email: registrationData.email,
        password: registrationData.password,
        passwordConfirmation: registrationData.password,
        phone: registrationData.phone,
        bio: registrationData.bio ?? '',
        zodiac: registrationData.zodiac!,
        zodiacDescription: registrationData.zodiacDescription,
        shareLocation: _shareLocation,
        shareZodiac: _shareZodiac,
        birthdate: registrationData.birthdate!.toIso8601String().split('T')[0],
        country: _selectedCountry,
        interests: registrationData.interests,
        imagePath: _imagePath,
        coverPath: _coverPath,
      );

      print('📧 Attempting registration with email: ${registrationData.email}');
      
      await context.read<RegisterCubit>().register(request);
      
    } catch (e) {
      print('❌ Error in _registerUser: $e');
      
      final errorStr = e.toString();
      int navigateToStep = 2;
      
      if (errorStr.contains('The email has already been taken') ||
          errorStr.toLowerCase().contains('email') && 
          errorStr.toLowerCase().contains('already')) {
        navigateToStep = 2;
      } else if (errorStr.contains('The phone has already been taken') ||
                errorStr.toLowerCase().contains('phone') && 
                errorStr.toLowerCase().contains('already')) {
        navigateToStep = 3;
      } else if (errorStr.contains('The interests field is required') ||
                errorStr.toLowerCase().contains('interests')) {
        navigateToStep = 3;
      }
      
      _showErrorAndNavigate(context, errorStr, navigateToStep);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorAndNavigate(BuildContext context, String message, int navigateToStep) {
    final langProvider = context.read<LanguageProvider>();
    
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.white),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.red,
      duration: const Duration(seconds: 10),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    
    Future.delayed(Duration(seconds: 1), () {
      if (mounted) {
        _navigateToStep(context, navigateToStep);
      }
    });
  }

  void _navigateToStep(BuildContext context, int step) {
    context.read<RegisterCubit>().reset();
    
    final langProvider = context.read<LanguageProvider>();
    
    switch (step) {
      case 2:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RegisterStep2Screen(
              errorMessage: langProvider.isArabic
                  ? 'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.'
                  : 'The email has already been taken. Please use another email.',
            ),
          ),
          (route) => false,
        );
        break;
      case 3:
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => RegisterStep3Screen(),
          ),
          (route) => false,
        );
        break;
      default:
        Navigator.pop(context);
    }
  }

  List<DropdownMenuItem<String>> _buildCountryDropdownItems(BuildContext context) {
    final countries = _getCountriesByLanguage(context);
    
    return countries.map<DropdownMenuItem<String>>((country) {
      return DropdownMenuItem<String>(
        value: country['value'],
        child: Text(country['name'] ?? ''),
      );
    }).toList();
  }

  String _getCountryDisplayName(BuildContext context, String value) {
    final langProvider = context.read<LanguageProvider>();
    final countries = langProvider.isArabic ? _countriesArabic : _countriesEnglish;
    
    final country = countries.firstWhere(
      (c) => c['value'] == value,
      orElse: () => {'name': value, 'value': value},
    );
    return country['name'] ?? value;
  }

  // **التعديل: عند تغيير حالة shareLocation**
  void _onShareLocationChanged(bool value) {
    setState(() {
      _shareLocation = value;
    });
    
    context.read<RegistrationProvider>().updateField(
      shareLocation: value,
    );
    
    // إذا تم تفعيل shareLocation، جلب البلد من الجهاز
    if (value) {
      _getDeviceCountry();
    }
  }

  // **التعديل: تعديل دالة build لتعكس التغيرات**
  Widget _buildPrivacySettings(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  langProvider.isArabic ? 'إعدادات الخصوصية' : 'Privacy Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            SwitchListTile(
              title: Text(
                langProvider.isArabic ? 'مشاركة الموقع' : 'Share Location',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                langProvider.isArabic 
                  ? 'السماح للآخرين برؤية دولتك'
                  : 'Allow others to see your country',
              ),
              value: _shareLocation,
              onChanged: _onShareLocationChanged, // **التعديل هنا**
              secondary: Icon(Icons.location_on, color: _shareLocation ? Colors.green : Colors.grey),
              activeColor: Colors.green,
            ),
            
            if (_shareLocation) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _isLoadingCountry
                    ? Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              langProvider.isArabic
                                  ? 'جاري تحديد موقعك...'
                                  : 'Detecting your location...',
                              style: TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : DropdownButton<String>(
                        value: _selectedCountry,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: Colors.blue),
                        iconSize: 24,
                        elevation: 16,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                        underline: SizedBox(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCountry = newValue!;
                          });
                          context.read<RegistrationProvider>().updateField(
                            country: _selectedCountry,
                          );
                        },
                        items: _buildCountryDropdownItems(context),
                      ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.info, size: 16, color: Colors.blue),
                  SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      langProvider.isArabic 
                        ? 'تم تحديد موقعك تلقائياً من إعدادات الجهاز'
                        : 'Your location was automatically detected from device settings',
                      style: TextStyle(fontSize: 12, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: 8),
              Text(
                langProvider.isArabic 
                  ? 'الدولة الحالية: ${CountryService.getCountryNameInArabic(_selectedCountry)}'
                  : 'Current country: $_selectedCountry',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
            
            SizedBox(height: 16),
            
            SwitchListTile(
              title: Text(
                langProvider.isArabic ? 'مشاركة معلومات البرج' : 'Share Zodiac Information',
                style: TextStyle(fontSize: 16),
              ),
              subtitle: Text(
                langProvider.isArabic 
                  ? 'السماح للآخرين برؤية معلومات برجك الفلكي'
                  : 'Allow others to see your zodiac information',
              ),
              value: _shareZodiac,
              onChanged: (value) {
                setState(() {
                  _shareZodiac = value;
                });
                context.read<RegistrationProvider>().updateField(
                  shareZodiac: value,
                );
              },
              secondary: Icon(Icons.star, color: _shareZodiac ? Colors.orange : Colors.grey),
              activeColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  void _saveData() {
    // حفظ البيانات قبل الرجوع
    final provider = context.read<RegistrationProvider>();
    provider.updateField(
      imagePath: _imagePath,
      coverPath: _coverPath,
      shareLocation: _shareLocation,
      shareZodiac: _shareZodiac,
      country: _selectedCountry,
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          // مسح بيانات التسجيل بعد النجاح
          context.read<RegistrationProvider>().clear();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    langProvider.isArabic ? 'تم إنشاء الحساب بنجاح!' : 'Account created successfully!',
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
          
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/home',
                (route) => false,
              );
            }
          });
        }
        
        if (state is RegisterFailure) {
          print('🎯 BlocListener received RegisterFailure');
          print('🎯 Error message: "${state.error}"');
          print('🎯 Error type: ${state.errorType}');
          
          String errorMessage = state.error;
          
          if (errorMessage.isEmpty || errorMessage == 'validation error') {
            print('⚠️ Empty or generic error message detected');
            errorMessage = langProvider.isArabic 
                ? 'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.'
                : 'The email has already been taken. Please use another email.';
          }
          
          int navigateToStep = 2;
          
          if (state.errorType == RegisterErrorType.emailAlreadyUsed ||
              errorMessage.contains('البريد الإلكتروني') ||
              errorMessage.contains('The email has already been taken') ||
              (errorMessage.toLowerCase().contains('email') && 
               errorMessage.toLowerCase().contains('already'))) {
            navigateToStep = 2;
          } else if (state.errorType == RegisterErrorType.phoneAlreadyUsed ||
                    errorMessage.contains('رقم الهاتف') ||
                    errorMessage.contains('The phone has already been taken') ||
                    (errorMessage.toLowerCase().contains('phone') && 
                     errorMessage.toLowerCase().contains('already'))) {
            navigateToStep = 3;
          } else if (errorMessage.contains('الاهتمامات') ||
                    errorMessage.contains('The interests field is required') ||
                    errorMessage.toLowerCase().contains('interests')) {
            navigateToStep = 3;
          }
          
          _showErrorAndNavigate(context, errorMessage, navigateToStep);
        }
      },
      child: WillPopScope(
        onWillPop: () async {
          _saveData();
          return true;
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              langProvider.isArabic ? 'المرحلة 4: الصور الشخصية' : 'Step 4: Profile Pictures',
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: _isLoading ? null : () {
                _saveData();
                Navigator.pop(context);
              },
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      langProvider.isArabic ? '4 من 4' : '4 of 4',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: 1.0,
                      backgroundColor: Colors.grey[200],
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      langProvider.isArabic ? 'الصور الشخصية' : 'Profile Pictures',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      langProvider.isArabic
                          ? 'الصور اختيارية - يمكنك تخطي هذه الخطوة'
                          : 'Photos are optional - You can skip this step',
                      style: TextStyle(color: Colors.grey),
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
                                color: Theme.of(context).primaryColor,
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
                                        color: Theme.of(context).primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _pickImage(context, false),
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
                                onPressed: _isLoading ? null : () {
                                  setState(() {
                                    _imagePath = null;
                                  });
                                  context.read<RegistrationProvider>().updateField(
                                    imagePath: null,
                                  );
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
                                color: Theme.of(context).primaryColor,
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
                                        color: Theme.of(context).primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : () => _pickImage(context, true),
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
                                onPressed: _isLoading ? null : () {
                                  setState(() {
                                    _coverPath = null;
                                  });
                                  context.read<RegistrationProvider>().updateField(
                                    coverPath: null,
                                  );
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
                    
                    // إعدادات الخصوصية
                    _buildPrivacySettings(context),
                    
                    const SizedBox(height: 32),
                    
                    // زر إنشاء الحساب
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () => _registerUser(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                langProvider.isArabic
                                    ? 'إنشاء الحساب'
                                    : 'Create Account',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    TextButton(
                      onPressed: _isLoading ? null : () => _registerUser(context),
                      child: Text(
                        langProvider.isArabic
                            ? 'تخطي إضافة الصور'
                            : 'Skip Adding Photos',
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