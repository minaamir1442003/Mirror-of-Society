// lib/presentation/screens/main_app/profile/screen/update_telegram_screen.dart

import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_cubit.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_state.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/models/user_profile_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:app_1/presentation/providers/language_provider.dart';

class UpdateTelegramScreen extends StatefulWidget {
  final TelegramModel telegram;

  const UpdateTelegramScreen({Key? key, required this.telegram})
    : super(key: key);

  @override
  _UpdateTelegramScreenState createState() => _UpdateTelegramScreenState();
}

class _UpdateTelegramScreenState extends State<UpdateTelegramScreen> {
  late TextEditingController _controller;
  int? _selectedCategoryId;
  bool _isAd = false;
  int _charCount = 0;
  List<Map<String, dynamic>> _categories = [];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.telegram.content);
    _selectedCategoryId = widget.telegram.category.id;
    _isAd = widget.telegram.isAd;
    _charCount = widget.telegram.content.length;

    // تحميل الفئات من القائمة الثابتة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCategories();
    });
  }

  void _loadCategories() {
    final isArabic =
        Provider.of<LanguageProvider>(
          context,
          listen: false,
        ).getCurrentLanguageName() ==
        'العربية';

    setState(() {
      _categories = _getStaticCategories(isArabic);
    });
  }

  List<Map<String, dynamic>> _getStaticCategories(bool isArabic) {
    if (isArabic) {
      return [
        {"id": 1, "name": "سياسة", "color": "#dc3545", "icon": null},
        {"id": 2, "name": "رياضة", "color": "#28a745", "icon": null},
        {"id": 3, "name": "فن", "color": "#6f42c1", "icon": null},
        {"id": 4, "name": "تكنولوجيا", "color": "#007bff", "icon": null},
        {"id": 5, "name": "صحة", "color": "#17a2b8", "icon": null},
        {"id": 6, "name": "سفر", "color": "#ffc107", "icon": null},
        {"id": 7, "name": "طعام", "color": "#fd7e14", "icon": null},
        {"id": 8, "name": "موضة", "color": "#e83e8c", "icon": null},
        {"id": 9, "name": "علوم", "color": "#20c997", "icon": null},
        {"id": 10, "name": "أعمال", "color": "#343a40", "icon": null},
        {"id": 11, "name": "موسيقى", "color": "#6610f2", "icon": null},
        {"id": 12, "name": "أفلام", "color": "#d63384", "icon": null},
        {"id": 13, "name": "ألعاب", "color": "#198754", "icon": null},
        {"id": 14, "name": "أدب", "color": "#fd7e14", "icon": null},
        {"id": 15, "name": "تعليم", "color": "#0dcaf0", "icon": null},
      ];
    } else {
      return [
        {"id": 1, "name": "Politics", "color": "#dc3545", "icon": null},
        {"id": 2, "name": "Sports", "color": "#28a745", "icon": null},
        {"id": 3, "name": "Arts", "color": "#6f42c1", "icon": null},
        {"id": 4, "name": "Technology", "color": "#007bff", "icon": null},
        {"id": 5, "name": "Health", "color": "#17a2b8", "icon": null},
        {"id": 6, "name": "Travel", "color": "#ffc107", "icon": null},
        {"id": 7, "name": "Food", "color": "#fd7e14", "icon": null},
        {"id": 8, "name": "Fashion", "color": "#e83e8c", "icon": null},
        {"id": 9, "name": "Science", "color": "#20c997", "icon": null},
        {"id": 10, "name": "Business", "color": "#343a40", "icon": null},
        {"id": 11, "name": "Music", "color": "#6610f2", "icon": null},
        {"id": 12, "name": "Movies", "color": "#d63384", "icon": null},
        {"id": 13, "name": "Gaming", "color": "#198754", "icon": null},
        {"id": 14, "name": "Literature", "color": "#fd7e14", "icon": null},
        {"id": 15, "name": "Education", "color": "#0dcaf0", "icon": null},
      ];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateBolt() {
    if (!_canUpdate()) return;

    final content = _controller.text.trim();

    if (_selectedCategoryId == null) {
      final isArabic =
          Provider.of<LanguageProvider>(
            context,
            listen: false,
          ).getCurrentLanguageName() ==
          'العربية';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isArabic ? 'الرجاء اختيار تصنيف' : 'Please select a category',
          ),
          backgroundColor: Color(0xFFFFC107),
        ),
      );
      return;
    }

    // ✅ تأكد من أن الـ Cubit متاح
    final telegramCubit = context.read<TelegramCubit>();

    // ✅ طباعة logs للتتبع
    print('🔄 Starting update for telegram ID: ${widget.telegram.id}');
    print('📝 New content: $content');
    print('🏷️ New category ID: $_selectedCategoryId');
    print('📢 Is ad: $_isAd');

    // ✅ استدعاء دالة التحديث
  
  }

  bool _canUpdate() {
    return _charCount > 0 && _charCount <= 250;
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final isArabic =
        Provider.of<LanguageProvider>(context).getCurrentLanguageName() ==
        'العربية';

    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'تحديث البرقية' : 'Update Telegram'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(left: 12),
            child: BlocConsumer<TelegramCubit, TelegramState>(
              listener: (context, state) {
                if (state is TelegramUpdated) {
                  print(
                    '✅ UpdateTelegramScreen: Telegram updated successfully',
                  );

                  // ✅ تحديث البروفايل تلقائيًا
                  final profileCubit = context.read<ProfileCubit>();

                  // ✅ تأكد من وجود category في الـ state
                  final category =
                      state.telegram.category?['name'] ?? 'Unknown';

                  profileCubit.updateTelegramInList({
                    'id': state.telegram.id,
                    'content': state.telegram.content,
                    'category_id': state.telegram.categoryId,
                    'is_ad': state.telegram.isAd,
                    'category': {
                      'id': state.telegram.categoryId,
                      'name': category,
                      'color': '#007bff', // لون افتراضي
                      'icon': null,
                    },
                  });

                  print('✅ UpdateTelegramScreen: Profile updated locally');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isArabic
                            ? 'تم تحديث البرقية بنجاح!'
                            : 'Telegram updated successfully!',
                      ),
                      backgroundColor: AppTheme.successColor,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  // ✅ تأخير العودة للسماح بعرض الـ Snackbar
                  Future.delayed(Duration(milliseconds: 1500), () {
                    Navigator.pop(context, true);
                  });
                } else if (state is TelegramError) {
                  print('❌ UpdateTelegramScreen: Error: ${state.message}');

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.dangerColor,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isUpdating = state is TelegramUpdating;

                return ElevatedButton(
                  onPressed: (!isUpdating && _canUpdate()) ? _updateBolt : null,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(90, 30),
                    backgroundColor:
                        isUpdating
                            ? AppTheme.lightGray
                            : (_canUpdate()
                                ? AppTheme.primaryColor
                                : AppTheme.lightGray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child:
                      isUpdating
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : Text(
                            isArabic ? 'حفظ' : 'Save',
                            style: TextStyle(color: Colors.white),
                          ),
                );
              },
            ),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                maxLength: 250,
                maxLines: null,
                decoration: InputDecoration(
                  hintText:
                      isArabic
                          ? 'ماذا تريد أن تعدل؟...'
                          : 'What do you want to edit?...',
                  hintStyle: TextStyle(fontSize: 20, color: AppTheme.lightGray),
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 20, height: 1.5),
                onChanged: (value) {
                  setState(() {
                    _charCount = value.length;
                  });
                },
              ),
            ),
            SizedBox(height: 24),
            _buildCategorySelector(isArabic),
            SizedBox(height: 16),
            _buildAdToggle(isArabic),
            SizedBox(height: 16),
            _buildCharCounter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector(bool isArabic) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isArabic ? 'التصنيف' : 'Category',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children:
              _categories.map((category) {
                bool isSelected = _selectedCategoryId == category['id'];
                Color categoryColor = _hexToColor(category['color']);

                return ChoiceChip(
                  label: Text(category['name']),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedCategoryId = category['id'];
                      } else if (_selectedCategoryId == category['id']) {
                        _selectedCategoryId = null;
                      }
                    });
                  },
                  backgroundColor:
                      isSelected
                          ? categoryColor.withOpacity(0.2)
                          : AppTheme.extraLightGray,
                  selectedColor: categoryColor.withOpacity(0.3),
                  labelStyle: TextStyle(
                    color: isSelected ? categoryColor : AppTheme.darkGray,
                    fontWeight: FontWeight.w500,
                  ),
                  side: BorderSide(
                    color: isSelected ? categoryColor : Colors.transparent,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildAdToggle(bool isArabic) {
    return Row(
      children: [
        Icon(Icons.campaign, color: Colors.orange),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            isArabic ? 'نشر كإعلان' : 'Publish as ad',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.secondaryColor,
            ),
          ),
        ),
        Switch(
          value: _isAd,
          onChanged: (value) {
            setState(() {
              _isAd = value;
            });
          },
          activeColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildCharCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$_charCount / 250',
          style: TextStyle(
            color: _charCount > 250 ? AppTheme.dangerColor : AppTheme.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
