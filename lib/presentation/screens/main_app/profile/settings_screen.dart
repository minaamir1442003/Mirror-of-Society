import 'package:app_1/core/theme/app_theme.dart';
import 'package:app_1/presentation/providers/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  
  // متغيرات للإعدادات
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;
  bool _privateAccount = false;
  bool _autoPlayVideos = true;
  bool _saveToGallery = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الإعدادات',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                // قسم الحساب
                _buildSection(
                  title: 'الحساب',
                  icon: Icons.person_outline,
                  children: [
                    _buildSettingItem(
                      icon: Icons.edit,
                      title: 'تعديل الملف الشخصي',
                      subtitle: 'تعديل معلومات حسابك',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {
                        // الانتقال لتعديل الملف الشخصي
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.lock_outline,
                      title: 'الأمان والخصوصية',
                      subtitle: 'إدارة أمان حسابك',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {
                        // الانتقال لإعدادات الأمان
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.email_outlined,
                      title: 'البريد الإلكتروني',
                      subtitle: 'ahmed@example.com',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {
                        // تغيير البريد الإلكتروني
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // قسم الإشعارات
                _buildSection(
                  title: 'الإشعارات',
                  icon: Icons.notifications_outlined,
                  children: [
                    _buildToggleItem(
                      icon: Icons.notifications_active,
                      title: 'تفعيل الإشعارات',
                      subtitle: 'تلقي إشعارات عن الأنشطة',
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.message_outlined,
                      title: 'إشعارات الرسائل',
                      subtitle: 'إشعارات الدردشات والرسائل',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.favorite_outline,
                      title: 'إشعارات التفاعلات',
                      subtitle: 'الإعجابات والتعليقات',
                      value: true,
                      onChanged: (value) {},
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // قسم الخصوصية
                _buildSection(
                  title: 'الخصوصية',
                  icon: Icons.security_outlined,
                  children: [
                    _buildToggleItem(
                      icon: Icons.visibility_off,
                      title: 'حساب خاص',
                      subtitle: 'يظهر حسابك للمتابعين فقط',
                      value: _privateAccount,
                      onChanged: (value) {
                        setState(() {
                          _privateAccount = value;
                        });
                      },
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.block,
                      title: 'الحسابات المحظورة',
                      subtitle: 'إدارة الحسابات المحظورة',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildToggleItem(
                      icon: Icons.location_off_outlined,
                      title: 'إخفاء الموقع',
                      subtitle: 'إخفاء موقعك الجغرافي',
                      value: false,
                      onChanged: (value) {},
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // قسم التطبيق (يحتوي على اللغة)
                _buildSection(
                  title: 'التطبيق',
                  icon: Icons.app_settings_alt_outlined,
                  children: [
                    // قسم اللغة - نفس الشكل
                    _buildLanguageSection(),
                    
                    _buildDivider(),
                    
                    _buildToggleItem(
                      icon: Icons.dark_mode_outlined,
                      title: 'الوضع الداكن',
                      subtitle: 'تفعيل الوضع الداكن',
                      value: _darkModeEnabled,
                      onChanged: (value) {
                        setState(() {
                          _darkModeEnabled = value;
                        });
                      },
                    ),
                    
                    _buildDivider(),
                    
                    _buildToggleItem(
                      icon: Icons.play_circle_outline,
                      title: 'التشغيل التلقائي',
                      subtitle: 'تشغيل الفيديوهات تلقائياً',
                      value: _autoPlayVideos,
                      onChanged: (value) {
                        setState(() {
                          _autoPlayVideos = value;
                        });
                      },
                    ),
                    
                    _buildDivider(),
                    
                    _buildToggleItem(
                      icon: Icons.save_alt_outlined,
                      title: 'حفظ الوسائط',
                      subtitle: 'حفظ الصور والفيديوهات تلقائياً',
                      value: _saveToGallery,
                      onChanged: (value) {
                        setState(() {
                          _saveToGallery = value;
                        });
                      },
                    ),
                  ],
                ),
                
                SizedBox(height: 24),
                
                // قسم الدعم والمساعدة
                _buildSection(
                  title: 'الدعم والمساعدة',
                  icon: Icons.help_outline_outlined,
                  children: [
                    _buildSettingItem(
                      icon: Icons.help_outline,
                      title: 'الأسئلة الشائعة',
                      subtitle: 'إجابات على الأسئلة المتكررة',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.contact_support_outlined,
                      title: 'اتصل بنا',
                      subtitle: 'تواصل مع فريق الدعم',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.description_outlined,
                      title: 'سياسة الخصوصية',
                      subtitle: 'اقرأ سياسة الخصوصية',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildSettingItem(
                      icon: Icons.description_outlined,
                      title: 'شروط الخدمة',
                      subtitle: 'اقرأ شروط الخدمة',
                      trailing: Icons.arrow_forward_ios,
                      onTap: () {},
                    ),
                  ],
                ),
                
                SizedBox(height: 32),
                
                // أزرار الإجراءات
                _buildActionButtons(),
                
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // دالة لبناء قسم
  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان القسم
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor, size: 22),
                SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // محتوى القسم
            Column(children: children),
          ],
        ),
      ),
    );
  }

  // دالة لبناء عنصر إعداد مع زر تبديل
  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primaryColor,
        activeTrackColor: AppTheme.primaryColor.withOpacity(0.3),
      ),
    );
  }

  // دالة لبناء عنصر إعداد عادي
  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required IconData trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(trailing, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // خط فاصل
  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  // قسم اللغة - نفس الشكل الموجود لديك
  Widget _buildLanguageSection() {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.blue[50]!, Colors.white]),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.language, color: AppTheme.primaryColor),
                  SizedBox(width: 8),
                  Text(
                    'لغة التطبيق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text(
                'اختر اللغة التي تفضل عرض التطبيق بها',
                style: TextStyle(color: AppTheme.darkGray, fontSize: 13),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: languageProvider.currentLanguage,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: AppTheme.primaryColor,
                    ),
                    iconSize: 24,
                    isExpanded: true,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                    dropdownColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 2,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        _changeAppLanguage(context, newValue, languageProvider);
                      }
                    },
                    items: languageProvider.getAvailableLanguages().map((language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[100],
                              ),
                              child: Center(
                                child: Text(
                                  _getLanguageEmoji(language),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(language),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'التطبيق حاليًا باللغة: ',
                    style: TextStyle(color: AppTheme.darkGray, fontSize: 11),
                  ),
                  SizedBox(width: 4),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      languageProvider.currentLanguage,
                      style: TextStyle(
                        color: AppTheme.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // أزرار الإجراءات (تسجيل الخروج وحذف الحساب)
  Widget _buildActionButtons() {
    return Column(
      children: [
        // زر تسجيل الخروج
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.1),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              _showLogoutDialog(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout, size: 20),
                SizedBox(width: 10),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        
        SizedBox(height: 16),
        
        // زر حذف الحساب
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              _showDeleteAccountDialog(context);
            },
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey[400]!),
            ),
            child: Text(
              'حذف الحساب',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // دالة تغيير اللغة - نفس الدالة
  void _changeAppLanguage(
    BuildContext context,
    String language,
    LanguageProvider languageProvider,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(Icons.language, color: AppTheme.primaryColor),
              SizedBox(width: 8),
              Text(
                'تغيير اللغة',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('هل تريد تغيير لغة التطبيق إلى:'),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _getLanguageEmoji(language),
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(width: 12),
                    Text(
                      language,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Text(
                'ملاحظة: سيتم تحديث اللغة فوراً',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(color: AppTheme.darkGray),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);

                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'جاري تغيير اللغة إلى $language...',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: AppTheme.primaryColor,
                    duration: Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                  ),
                );

                try {
                  await languageProvider.changeLanguage(language);
                  _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  setState(() {});
                } catch (error) {
                  _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
                  _scaffoldMessengerKey.currentState?.showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          Icon(Icons.error, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'حدث خطأ في تغيير اللغة',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('تغيير'),
            ),
          ],
        ),
      ),
    );
  }

  // حوار تسجيل الخروج
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('تسجيل الخروج'),
          content: Text('هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // كود تسجيل الخروج هنا
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('تم تسجيل الخروج بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  // حوار حذف الحساب
  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: Text('حذف الحساب'),
          content: Text('هل أنت متأكد أنك تريد حذف حسابك؟ هذه العملية غير قابلة للتراجع.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // كود حذف الحساب هنا
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('تم حذف الحساب بنجاح'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('حذف الحساب'),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageEmoji(String language) {
    switch (language) {
      case 'English':
        return '🇺🇸';
      case 'العربية':
        return '🇸🇦';
      case 'Français':
        return '🇫🇷';
      case 'Español':
        return '🇪🇸';
      default:
        return '🌐';
    }
  }
}