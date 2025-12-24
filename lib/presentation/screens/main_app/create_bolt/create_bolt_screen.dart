import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_cubit.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_1/core/theme/app_theme.dart';

class CreateBoltScreen extends StatefulWidget {
  const CreateBoltScreen({Key? key}) : super(key: key);

  @override
  _CreateBoltScreenState createState() => _CreateBoltScreenState();
}

class _CreateBoltScreenState extends State<CreateBoltScreen> {
  final TextEditingController _controller = TextEditingController();
  int? _selectedCategoryId;
  bool _isAd = false;
  int _charCount = 0;

  @override
  void initState() {
    super.initState();
    // تحميل الفئات عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TelegramCubit>().loadCategories();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('برقية جديدة'),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(left: 12),
            child: BlocConsumer<TelegramCubit, TelegramState>(
              listener: (context, state) {
                if (state is TelegramCreated) {
                  // إظهار رسالة نجاح
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم نشر البرقية بنجاح!'),
                      backgroundColor: AppTheme.successColor,
                    ),
                  );
                  // العودة للشاشة السابقة
                  Navigator.pop(context);
                } else if (state is TelegramError) {
                  // إظهار رسالة خطأ
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppTheme.dangerColor,
                    ),
                  );
                }
              },
              builder: (context, state) {
                final isCreating = state is TelegramCreating;
                
                return ElevatedButton(
                  onPressed: (!isCreating && _canPost())
                      ? _postBolt
                      : null,
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(90, 30),
                    backgroundColor: isCreating
                        ? AppTheme.lightGray
                        : (_canPost() ? AppTheme.primaryColor : AppTheme.lightGray),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: isCreating
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('نشر', style: TextStyle(color: Colors.white)),
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
                  hintText: 'ماذا يحدث؟...',
                  hintStyle: TextStyle(
                    fontSize: 20,
                    color: AppTheme.lightGray,
                  ),
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
            _buildCategorySelector(),
            SizedBox(height: 16),
            _buildAdToggle(),
            SizedBox(height: 16),
            _buildCharCounter(),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return BlocBuilder<TelegramCubit, TelegramState>(
      builder: (context, state) {
        if (state is TelegramLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is CategoriesLoaded) {
          final categories = state.categories;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'التصنيف',
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
                children: categories.map((category) {
                  bool isSelected = _selectedCategoryId == category.id;
                  Color categoryColor = _hexToColor(category.color);
                  
                  return ChoiceChip(
                    label: Text(category.name),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCategoryId = category.id;
                        } else if (_selectedCategoryId == category.id) {
                          _selectedCategoryId = null;
                        }
                      });
                    },
                    backgroundColor: isSelected 
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
        } else if (state is TelegramError) {
          return Column(
            children: [
              Text(
                'فشل في تحميل الفئات',
                style: TextStyle(color: AppTheme.dangerColor),
              ),
              SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  context.read<TelegramCubit>().loadCategories(forceRefresh: true);
                },
                child: Text('إعادة المحاولة'),
              ),
            ],
          );
        }
        
        return SizedBox();
      },
    );
  }

  Widget _buildAdToggle() {
    return Row(
      children: [
        Icon(Icons.campaign, color: Colors.orange),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'نشر كإعلان',
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
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.image_outlined, color: AppTheme.primaryColor),
              onPressed: () {
                // TODO: إضافة صورة
              },
            ),
            IconButton(
              icon: Icon(Icons.tag, color: AppTheme.primaryColor),
              onPressed: () {
                // TODO: إضافة هاشتاج
              },
            ),
            IconButton(
              icon: Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
              onPressed: () {
                // TODO: إضافة موقع
              },
            ),
          ],
        ),
      ],
    );
  }

  void _postBolt() {
    if (!_canPost()) return;

    final content = _controller.text.trim();
    
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('الرجاء اختيار تصنيف'),
          backgroundColor: Color(0xFFFFC107),
        ),
      );
      return;
    }

    context.read<TelegramCubit>().createTelegram(
      content: content,
      categoryId: _selectedCategoryId!,
      isAd: _isAd,
    );
  }

  bool _canPost() {
    return _charCount > 0 && 
           _charCount <= 250 && 
           _selectedCategoryId != null;
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}