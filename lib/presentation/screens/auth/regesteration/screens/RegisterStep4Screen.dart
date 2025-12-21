import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:app_1/presentation/screens/auth/regesteration/models/RegisterData.dart';
import 'package:app_1/presentation/screens/auth/regesteration/repositories/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../cubit/register_cubit.dart';
import '../models/register_request.dart';

class RegisterStep4Screen extends StatefulWidget {
  final RegisterData registerData;
  
  const RegisterStep4Screen({
    Key? key,
    required this.registerData,
  }) : super(key: key);

  @override
  _RegisterStep4ScreenState createState() => _RegisterStep4ScreenState();
}

class _RegisterStep4ScreenState extends State<RegisterStep4Screen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  
  String? _imagePath;
  String? _coverPath;
  bool _isLoading = false; // إضافة متغير لتحميل الحالة محلياً

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
    final isArabic = langProvider.isArabic;

    try {
      // التحقق من البيانات الأساسية
      if (widget.registerData.birthdate == null) {
        _showError(
          isArabic
              ? 'يرجى اختيار تاريخ الميلاد'
              : 'Please select birth date',
        );
        return;
      }

      if (widget.registerData.zodiac == null) {
        _showError(
          isArabic
              ? 'تعذر حساب البرج الفلكي'
              : 'Failed to calculate zodiac sign',
        );
        return;
      }

      if (widget.registerData.interests.length < 3) {
        _showError(
          isArabic
              ? 'يرجى اختيار 3 اهتمامات على الأقل'
              : 'Please select at least 3 interests',
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // إنشاء Request
      final request = RegisterRequest(
        firstname: widget.registerData.firstName,
        lastname: widget.registerData.lastName,
        email: widget.registerData.email,
        password: widget.registerData.password,
        passwordConfirmation: widget.registerData.password,
        phone: widget.registerData.phone,
        bio: widget.registerData.bio ?? '',
        zodiac: widget.registerData.zodiac!,
        zodiacDescription: widget.registerData.zodiacDescription,
        shareLocation: true,
        shareZodiac: true,
        birthdate: widget.registerData.birthdate!.toIso8601String().split('T')[0],
        country: 'Egypt', // يمكن تعديله ليكون اختيار المستخدم
        interests: widget.registerData.interests,
        imagePath: _imagePath,
        coverPath: _coverPath,
      );

      // استدعاء الـ Cubit
      await context.read<RegisterCubit>().register(request);
      
    } catch (e) {
      final errorMessage = ErrorUtils.translateErrorMessage(
        e.toString(),
        isArabic: isArabic,
      );
      _showError(errorMessage);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = context.read<LanguageProvider>();
    final isArabic = langProvider.isArabic;

    return BlocListener<RegisterCubit, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          _showSuccess(
            isArabic ? 'تم إنشاء الحساب بنجاح!' : 'Account created successfully!'
          );
          
          // الانتقال للصفحة الرئيسية بعد تأخير بسيط
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
          // تحويل رسالة الخطأ
          final errorMessage = ErrorUtils.translateErrorMessage(
            state.error,
            isArabic: isArabic,
          );
          
          _showError(errorMessage);
          
        
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isArabic ? 'المرحلة 4: الصور الشخصية' : 'Step 4: Profile Pictures',
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _isLoading ? null : () => Navigator.pop(context),
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
                      isArabic ? '4 من 4' : '4 of 4',
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
                      isArabic ? 'الصور الشخصية' : 'Profile Pictures',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      isArabic
                          ? 'الصور اختيارية - يمكنك تخطي هذه الخطوة'
                          : 'Photos are optional - You can skip this step',
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
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
                              isArabic
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
                                isArabic
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
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: Text(
                                  isArabic
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
                              isArabic ? 'صورة الغلاف' : 'Cover Photo',
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
                                isArabic
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
                                },
                                icon: const Icon(Icons.delete, color: Colors.red),
                                label: Text(
                                  isArabic
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
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.green),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isArabic
                                    ? 'تم إضافة ${_imagePath != null ? "صورة شخصية" : ""}${_imagePath != null && _coverPath != null ? " و " : ""}${_coverPath != null ? "صورة غلاف" : ""}'
                                    : 'Added ${_imagePath != null ? "profile picture" : ""}${_imagePath != null && _coverPath != null ? " and " : ""}${_coverPath != null ? "cover photo" : ""}',
                                style: const TextStyle(
                                  color: Colors.green,
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
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              isArabic
                                  ? 'يمكنك تخطي إضافة الصور والاستمرار'
                                  : 'You can skip adding photos and continue',
                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                                isArabic
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
                    // زر تخطي إضافة الصور
                    TextButton(
                      onPressed: _isLoading ? null : () => _registerUser(context),
                      child: Text(
                        isArabic
                            ? 'تخطي إضافة الصور'
                            : 'Skip Adding Photos',
                      ),
                    ),
                    // عرض رسالة التحميل إذا كانت هناك
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          isArabic
                              ? 'جاري إنشاء حسابك...'
                              : 'Creating your account...',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontStyle: FontStyle.italic,
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