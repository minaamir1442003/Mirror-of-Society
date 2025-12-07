// lib/screens/create_bolt_screen.dart
import 'package:app_1/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CreateBoltScreen extends StatefulWidget {
  @override
  _CreateBoltScreenState createState() => _CreateBoltScreenState();
}

class _CreateBoltScreenState extends State<CreateBoltScreen> {
  final TextEditingController _controller = TextEditingController();
  String selectedCategory = 'عامة';
  bool isAd = false;
  int charCount = 0;

  final List<Map<String, dynamic>> categories = [
    {'name': 'عامة', 'color': AppTheme.categoryColors['عامة']!},
    {'name': 'تكنولوجيا', 'color': AppTheme.categoryColors['تكنولوجيا']!},
    {'name': 'رياضة', 'color': AppTheme.categoryColors['رياضة']!},
    {'name': 'فن', 'color': AppTheme.categoryColors['فن']!},
    {'name': 'سياسة', 'color': AppTheme.categoryColors['سياسة']!},
    {'name': 'اقتصاد', 'color': AppTheme.categoryColors['اقتصاد']!},
  ];

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
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
              onPressed: charCount > 0 ? _postBolt : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text('نشر', style: TextStyle(color: Colors.white)),
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
                    charCount = value.length;
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
            bool isSelected = selectedCategory == category['name'];
            return ChoiceChip(
              label: Text(category['name']),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  selectedCategory = category['name'];
                });
              },
              backgroundColor: isSelected 
                  ? category['color'].withOpacity(0.2)
                  : AppTheme.extraLightGray,
              selectedColor: category['color'].withOpacity(0.3),
              labelStyle: TextStyle(
                color: isSelected ? category['color'] : AppTheme.darkGray,
                fontWeight: FontWeight.w500,
              ),
              side: BorderSide(
                color: isSelected ? category['color'] : Colors.transparent,
              ),
            );
          }).toList(),
        ),
      ],
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
          value: isAd,
          onChanged: (value) {
            setState(() {
              isAd = value;
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
          '$charCount / 250',
          style: TextStyle(
            color: charCount > 250 ? AppTheme.dangerColor : AppTheme.darkGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.image_outlined, color: AppTheme.primaryColor),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.tag, color: AppTheme.primaryColor),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
              onPressed: () {},
            ),
          ],
        ),
      ],
    );
  }

  void _postBolt() {
    // هنا كود نشر البرقية
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نشر البرقية بنجاح!'),
        backgroundColor: AppTheme.successColor,
      ),
    );
  }
}