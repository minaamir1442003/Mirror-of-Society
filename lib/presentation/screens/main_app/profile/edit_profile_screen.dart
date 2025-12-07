// lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:app_1/core/theme/app_theme.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController _nameController = TextEditingController(text: 'أحمد محمد');
  TextEditingController _usernameController = TextEditingController(text: '@ahmed_dev');
  TextEditingController _bioController = TextEditingController(
    text: 'مطور تطبيقات وهواة كتابة. أحب مشاركة الأفكار والتجارب في عالم التقنية.',
  );
  
  List<String> _selectedInterests = ['تكنولوجيا', 'برمجة', 'رياضة'];
  final List<String> _allInterests = [
    'تكنولوجيا', 'برمجة', 'رياضة', 'قراءة', 'سفر', 
    'فن', 'موسيقى', 'طبخ', 'تصوير', 'كتابة'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تعديل الملف الشخصي'),
        actions: [
          TextButton(
            onPressed: _saveProfile,
            child: Text(
              'حفظ',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // صورة البروفايل
            GestureDetector(
              onTap: _changeProfileImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: NetworkImage(
                      'https://ui-avatars.com/api/?name=أحمد+محمد&background=1DA1F2&color=fff&size=400',
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
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // الاسم
            _buildTextField(
              controller: _nameController,
              label: 'الاسم',
              icon: Icons.person,
            ),
            SizedBox(height: 16),
            
            // اسم المستخدم
            _buildTextField(
              controller: _usernameController,
              label: 'اسم المستخدم',
              icon: Icons.alternate_email,
            ),
            SizedBox(height: 16),
            
            // السيرة الذاتية
            _buildTextField(
              controller: _bioController,
              label: 'السيرة الذاتية',
              icon: Icons.description,
              maxLines: 4,
            ),
            SizedBox(height: 24),
            
            // الاهتمامات
            _buildInterestsSection(),
            SizedBox(height: 32),
            
            // حذف الحساب
            TextButton(
              onPressed: _showDeleteDialog,
              child: Text(
                'حذف الحساب',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                ),
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
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
  
  Widget _buildInterestsSection() {
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
          spacing: 10,
          runSpacing: 10,
          children: _allInterests.map((interest) {
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
              selectedColor: AppTheme.primaryColor,
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  void _changeProfileImage() {
    // اختيار صورة جديدة
  }
  
  void _saveProfile() {
    // حفظ البيانات
    Navigator.pop(context, true); // الرجوع مع إشارة التحديث
  }
  
  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('حذف الحساب'),
        content: Text('هل أنت متأكد من حذف حسابك؟ هذه العملية لا يمكن التراجع عنها.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              // حذف الحساب
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'حذف',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}