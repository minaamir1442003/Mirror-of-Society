// lib/presentation/screens/main_app/profile/edit_profile_screen.dart
import 'package:app_1/presentation/screens/main_app/profile/models/update_profile_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/update_profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _zodiacDescriptionController;
  
  String? _selectedZodiacValue;
  bool _shareLocation = false;
  bool _shareZodiac = false;
  DateTime _selectedDate = DateTime.now();
  String? _selectedCountryValue;
  
  List<int> _selectedInterestsIds = [];
  String? _profileImagePath;
  String? _coverImagePath;
  
  // لتتبع إذا تم اختيار صور جديدة أو الحالية
  bool _profileImageChanged = false;
  bool _coverImageChanged = false;
  
  // لتخزين رابط الصور الحالية
  String? _currentProfileImageUrl;
  String? _currentCoverImageUrl;
  
  // قائمة الدول المنظمة
  final List<String> _countries = [
    'مصر', 'السعودية', 'الإمارات', 'الكويت', 'قطر',
    'عمان', 'البحرين', 'الأردن', 'لبنان', 'سوريا',
    'العراق', 'اليمن', 'ليبيا', 'تونس', 'الجزائر',
    'المغرب', 'السودان', 'الصومال', 'فلسطين', 'جيبوتي'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    final profileCubit = context.read<ProfileCubit>();
    final state = profileCubit.state;
    
    UserProfileModel profile;
    if (state is ProfileLoaded || state is ProfileUpdated) {
      profile = (state as dynamic).profile;
    } else {
      profile = UserProfileModel(
        id: 0,
        firstname: '',
        lastname: '',
        email: '',
        rank: '0',
        phone: '',
        bio: '',
        image: '',
        cover: '',
        zodiac: '',
        zodiacDescription: '',
        shareLocation: false,
        shareZodiac: false,
        birthdate: DateTime.now(),
        country: '',
        interests: [],
        statistics: ProfileStatistics(
          followersCount: 0,
          followingCount: 0,
          telegramsCount: 0,
        ),
        telegrams: [],
      );
    }
    
    _firstNameController = TextEditingController(text: profile.firstname);
    _lastNameController = TextEditingController(text: profile.lastname);
    _emailController = TextEditingController(text: profile.email);
    _phoneController = TextEditingController(text: profile.phone);
    _bioController = TextEditingController(text: profile.bio);
    _zodiacDescriptionController = TextEditingController(text: profile.zodiacDescription);
    
    _shareLocation = profile.shareLocation;
    _shareZodiac = profile.shareZodiac;
    _selectedDate = profile.birthdate;
    
    // نستخدم القيم مباشرة وسيتم تحديثها عند بناء القوائم المنسدلة
    _selectedZodiacValue = profile.zodiac.isNotEmpty ? profile.zodiac : null;
    _selectedCountryValue = profile.country.isNotEmpty ? profile.country : null;
    
    _selectedInterestsIds = profile.interests.map((interest) => interest.id).toList();
    
    // حفظ روابط الصور الحالية
    _currentProfileImageUrl = profile.image;
    _currentCoverImageUrl = profile.cover;
    
    // تحميل البيانات الأولية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UpdateProfileCubit>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _zodiacDescriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isProfile, ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      final XFile? image = await picker.pickImage(source: source);
      
      if (image != null) {
        setState(() {
          if (isProfile) {
            _profileImagePath = image.path;
            _profileImageChanged = true;
          } else {
            _coverImagePath = image.path;
            _coverImageChanged = true;
          }
        });
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ في اختيار الصورة: $e')),
      );
    }
  }

  void _showImageSourceDialog(bool isProfile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('اختر مصدر الصورة'),
        content: Text('من أين تريد اختيار الصورة؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(isProfile, ImageSource.camera);
            },
            child: Text('الكاميرا'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _pickImage(isProfile, ImageSource.gallery);
            },
            child: Text('المعرض'),
          ),
        ],
      ),
    );
  }

  void _saveProfile() {
    // التحقق من صحة البريد الإلكتروني
    final email = _emailController.text.trim();
    if (email.isNotEmpty && !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('يرجى إدخال بريد إلكتروني صحيح')),
      );
      return;
    }
    
    // التحقق من طول رقم الهاتف
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty && phone.length > 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('رقم الهاتف يجب ألا يتجاوز 20 حرفاً')),
      );
      return;
    }
    
    // التحقق من صحة تاريخ الميلاد
    if (_selectedDate.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تاريخ الميلاد يجب أن يكون في الماضي')),
      );
      return;
    }
    
    final updateCubit = context.read<UpdateProfileCubit>();
    
    final request = UpdateProfileRequest(
      firstname: _firstNameController.text.trim(),
      lastname: _lastNameController.text.trim(),
      email: email,
      phone: phone,
      bio: _bioController.text.trim(),
      zodiac: _selectedZodiacValue ?? '',
      zodiacDescription: _zodiacDescriptionController.text.trim(),
      shareLocation: _shareLocation,
      shareZodiac: _shareZodiac,
      birthdate: _selectedDate,
      country: _selectedCountryValue ?? '',
      interests: _selectedInterestsIds.isNotEmpty ? _selectedInterestsIds : null,
      imagePath: _profileImageChanged ? _profileImagePath : null,
      coverPath: _coverImageChanged ? _coverImagePath : null,
    );
    
    updateCubit.updateProfile(request);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendar,
      helpText: 'اختر تاريخ الميلاد',
      confirmText: 'تأكيد',
      cancelText: 'إلغاء',
      errorFormatText: 'أدخل تاريخ صحيح',
      errorInvalidText: 'أدخل تاريخ في النطاق',
      fieldLabelText: 'تاريخ الميلاد',
      fieldHintText: 'يوم/شهر/سنة',
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // دالة مساعدة لبناء قائمة الأبراج بدون تكرار
  List<DropdownMenuItem<String>> _buildZodiacItems(List<Map<String, dynamic>> zodiacs) {
    final items = <DropdownMenuItem<String>>[
      DropdownMenuItem<String>(
        value: null,
        child: Text('اختر برجك', style: TextStyle(color: Colors.grey)),
      ),
    ];
    
    // استخدام Set لإزالة التكرارات
    final seen = <String>{};
    for (var zodiac in zodiacs) {
      final name = zodiac['name']?.toString() ?? '';
      if (name.isNotEmpty && !seen.contains(name)) {
        seen.add(name);
        items.add(
          DropdownMenuItem<String>(
            value: name,
            child: Text(name),
          ),
        );
      }
    }
    
    return items;
  }

  // دالة مساعدة لبناء قائمة الدول
  List<DropdownMenuItem<String>> _buildCountryItems() {
    return [
      DropdownMenuItem<String>(
        value: null,
        child: Text('اختر الدولة', style: TextStyle(color: Colors.grey)),
      ),
      ..._countries.map((country) {
        return DropdownMenuItem<String>(
          value: country,
          child: Text(country),
        );
      }).toList(),
    ];
  }

  // دالة لبناء زر الاختيار مع الصورة
  Widget _buildImagePickerButton(
    BuildContext context,
    bool isProfile,
    String? currentImageUrl,
    bool imageChanged,
    String? newImagePath,
  ) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.camera_alt, color: Colors.white),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('الكاميرا'),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text('المعرض'),
            ],
          ),
        ),
      
      ],
      onSelected: (value) {
        if (value == 'camera') {
          _pickImage(isProfile, ImageSource.camera);
        } else if (value == 'gallery') {
          _pickImage(isProfile, ImageSource.gallery);
        } else if (value == 'remove') {
          setState(() {
            if (isProfile) {
              _profileImagePath = null;
              _profileImageChanged = true;
            } else {
              _coverImagePath = null;
              _coverImageChanged = true;
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<UpdateProfileCubit, UpdateProfileState>(
      listener: (context, state) {
        if (state is UpdateProfileSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
          
          // تحديث ProfileCubit بالبيانات الجديدة
          if (state.updatedProfile != null) {
            context.read<ProfileCubit>().clearProfile();
            Navigator.pop(context, true);
          }
        } else if (state is UpdateProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('تعديل الملف الشخصي'),
          actions: [
            BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state is UpdateProfileUpdating ? null : _saveProfile,
                  child: Text(
                    'حفظ',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<UpdateProfileCubit, UpdateProfileState>(
          builder: (context, state) {
            if (state is UpdateProfileLoading) {
              return Center(child: CircularProgressIndicator());
            }
            
            return _buildContent(state);
          },
        ),
      ),
    );
  }

  Widget _buildContent(UpdateProfileState state) {
    final updateCubit = context.read<UpdateProfileCubit>();
    final availableZodiacs = updateCubit.availableZodiacs;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // صورة الغلاف
          _buildCoverImageSection(),
          SizedBox(height: 100),
          
          // صورة الملف الشخصي
          _buildProfileImageSection(),
          SizedBox(height: 20),
          
          // البيانات الشخصية
          _buildPersonalInfoSection(availableZodiacs),
          SizedBox(height: 20),
          
          // الاهتمامات
          _buildInterestsSection(state),
          SizedBox(height: 20),
          
          // إعدادات الخصوصية
          _buildPrivacySection(),
          SizedBox(height: 30),
          
          // زر الحفظ
          _buildSaveButton(state),
        ],
      ),
    );
  }

  Widget _buildCoverImageSection() {
    // تحديد الصورة المعروضة
    Widget? coverImage;
    String? imagePath;
    
    if (_coverImageChanged && _coverImagePath != null) {
      // إذا تم اختيار صورة جديدة
      coverImage = Image.file(
        File(_coverImagePath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
      imagePath = _coverImagePath;
    } else if (_currentCoverImageUrl != null && _currentCoverImageUrl!.isNotEmpty) {
      // إذا كانت هناك صورة حالية
      coverImage = Image.network(
        _currentCoverImageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(Icons.image, size: 50, color: Colors.grey[400]),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => _showImageSourceDialog(false),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: Stack(
          children: [
            if (coverImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: coverImage,
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, size: 40, color: Colors.grey[400]),
                    SizedBox(height: 8),
                    Text(
                      'اضغط لاختيار صورة الغلاف',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.8),
                  shape: BoxShape.circle,
                ),
                child: _buildImagePickerButton(
                  context,
                  false,
                  _currentCoverImageUrl,
                  _coverImageChanged,
                  _coverImagePath,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImageSection() {
    // تحديد الصورة المعروضة
    Widget? profileImage;
    
    if (_profileImageChanged && _profileImagePath != null) {
      // إذا تم اختيار صورة جديدة
      profileImage = Image.file(
        File(_profileImagePath!),
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    } else if (_currentProfileImageUrl != null && _currentProfileImageUrl!.isNotEmpty) {
      // إذا كانت هناك صورة حالية
      profileImage = Image.network(
        _currentProfileImageUrl!,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: 60, color: Colors.grey[400]);
        },
      );
    }

    return GestureDetector(
      onTap: () => _showImageSourceDialog(true),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 70,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 68,
                backgroundColor: Colors.grey[200],
                backgroundImage: profileImage != null
                    ? (_profileImageChanged && _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : NetworkImage(_currentProfileImageUrl!) as ImageProvider)
                    : null,
                child: profileImage == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                    : null,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                shape: BoxShape.circle,
              ),
              child: _buildImagePickerButton(
                context,
                true,
                _currentProfileImageUrl,
                _profileImageChanged,
                _profileImagePath,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(List<Map<String, dynamic>> availableZodiacs) {
    final zodiacItems = _buildZodiacItems(availableZodiacs);
    final countryItems = _buildCountryItems();
    
    // التحقق من أن القيمة المختارة موجودة في القائمة
    if (_selectedZodiacValue != null) {
      final exists = zodiacItems.any((item) => item.value == _selectedZodiacValue);
      if (!exists) {
        // إذا لم تكن موجودة، نضيفها كخيار مؤقت
        zodiacItems.add(
          DropdownMenuItem<String>(
            value: _selectedZodiacValue,
            child: Text(_selectedZodiacValue!),
          ),
        );
      }
    }
    
    // نفس الشيء للدولة
    if (_selectedCountryValue != null) {
      final exists = countryItems.any((item) => item.value == _selectedCountryValue);
      if (!exists && _selectedCountryValue!.isNotEmpty) {
        countryItems.add(
          DropdownMenuItem<String>(
            value: _selectedCountryValue,
            child: Text(_selectedCountryValue!),
          ),
        );
      }
    }
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _firstNameController,
                label: 'الاسم الأول',
                icon: Icons.person,
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _buildTextField(
                controller: _lastNameController,
                label: 'اسم العائلة',
                icon: Icons.person_outline,
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _emailController,
          label: 'البريد الإلكتروني',
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _phoneController,
          label: 'رقم الهاتف',
          icon: Icons.phone,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: 16),
        _buildTextField(
          controller: _bioController,
          label: 'نبذة عنك',
          icon: Icons.description,
          maxLines: 3,
        ),
        SizedBox(height: 16),
        
        // تاريخ الميلاد
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                SizedBox(width: 12),
                Text(
                  'تاريخ الميلاد: ${_selectedDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(fontSize: 16),
                ),
                Spacer(),
                Text(
                  'تغيير',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
        
        // الدولة
        DropdownButtonFormField<String>(
          value: _selectedCountryValue,
          decoration: InputDecoration(
            labelText: 'الدولة',
            prefixIcon: Icon(Icons.location_on, color: AppTheme.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: countryItems,
          onChanged: (value) {
            setState(() {
              _selectedCountryValue = value;
            });
          },
        ),
        SizedBox(height: 16),
        
        // البرج
        DropdownButtonFormField<String>(
          value: _selectedZodiacValue,
          decoration: InputDecoration(
            labelText: 'البرج',
            prefixIcon: Icon(Icons.star, color: AppTheme.primaryColor),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: zodiacItems,
          onChanged: (value) {
            setState(() {
              _selectedZodiacValue = value;
              if (value != null) {
                final updateCubit = context.read<UpdateProfileCubit>();
                final zodiac = updateCubit.findZodiacByName(value);
                if (zodiac != null && zodiac.isNotEmpty) {
                  _zodiacDescriptionController.text = zodiac['description'] ?? '';
                }
              }
            });
          },
        ),
        SizedBox(height: 16),
        
        // وصف البرج
        _buildTextField(
          controller: _zodiacDescriptionController,
          label: 'وصف البرج',
          icon: Icons.description,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildInterestsSection(UpdateProfileState state) {
    final updateCubit = context.read<UpdateProfileCubit>();
    final availableInterests = updateCubit.availableInterests;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الاهتمامات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: availableInterests.map((interest) {
            bool isSelected = _selectedInterestsIds.contains(interest['id']);
            return FilterChip(
              label: Text(interest['name']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterestsIds.add(interest['id']);
                  } else {
                    _selectedInterestsIds.remove(interest['id']);
                  }
                });
              },
              selectedColor: _parseColor(interest['color']),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
              backgroundColor: _parseColor(interest['color']).withOpacity(0.1),
              shape: StadiumBorder(
                side: BorderSide(
                  color: isSelected 
                      ? _parseColor(interest['color'])
                      : Colors.grey[300]!,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إعدادات الخصوصية',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
        SizedBox(height: 16),
        SwitchListTile(
          title: Text('مشاركة الموقع'),
          subtitle: Text('السماح للآخرين برؤية موقعك'),
          value: _shareLocation,
          onChanged: (value) {
            setState(() {
              _shareLocation = value;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        SwitchListTile(
          title: Text('مشاركة معلومات البرج'),
          subtitle: Text('السماح للآخرين برؤية معلومات برجك'),
          value: _shareZodiac,
          onChanged: (value) {
            setState(() {
              _shareZodiac = value;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildSaveButton(UpdateProfileState state) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: state is UpdateProfileUpdating ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: state is UpdateProfileUpdating
            ? CircularProgressIndicator(color: Colors.white)
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save, size: 20),
                  SizedBox(width: 10),
                  Text(
                    'حفظ التغييرات',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
        ),
      ),
    );
  }

  Color _parseColor(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }
}