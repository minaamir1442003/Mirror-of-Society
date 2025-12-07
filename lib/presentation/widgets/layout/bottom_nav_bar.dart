import 'package:flutter/material.dart';
import 'package:app_1/core/theme/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final int notificationCount;
  
  const BottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTabSelected,
    this.notificationCount = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, -4),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Stack(
        children: [
          // الخط العلوي الديكوري
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // محتوى الـ Navigation Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // العنصر الأول: الرئيسية
              _buildNavItem(context, 0, Icons.home_outlined, Icons.home, 'الرئيسية', 0.15),
              
              // العنصر الثاني: التصنيفات
              _buildNavItem(context, 1, Icons.category_outlined, Icons.category, 'التصنيفات', 0.15),
              
              // مساحة فارغة للزر العائم
              SizedBox(width: 70),
              
              // العنصر الرابع: الإشعارات
              _buildNotificationItem(context, 0.15),
              
              // العنصر الخامس: الملف الشخصي
              _buildNavItem(context, 4, Icons.person_outlined, Icons.person, 'الملف', 0.15),
            ],
          ),
          
          // الزر العائم في المنتصف
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35, // في المنتصف تماماً
            top: 5, // نصفه خارج الـ navigation bar
            child: _buildFloatingButton(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNavItem(BuildContext context, int index, IconData icon, IconData activeIcon, String label, double widthFactor) {
    bool isActive = currentIndex == index;
    
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      child: InkWell(
        onTap: () => onTabSelected(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.lightGray,
                size: 22,
              ),
            ),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? AppColors.primary : AppColors.lightGray,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildFloatingButton() {
    bool isActive = currentIndex == 2;
    
    return GestureDetector(
      onTap: () => onTabSelected(2),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              Color(0xFF1A8CD8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 15,
              spreadRadius: 2,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Center(
          child: Icon(
            isActive ? Icons.check : Icons.add,
            color: Colors.white,
            size: 30,
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotificationItem(BuildContext context, double widthFactor) {
    bool isActive = currentIndex == 3;
    
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      padding: EdgeInsets.only(right: 20),
      child: Stack(
        children: [
          InkWell(
            onTap: () => onTabSelected(3),
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: Icon(
                    isActive ? Icons.notifications : Icons.notifications_outlined,
                    color: isActive ? AppColors.primary : AppColors.lightGray,
                    size: 22,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 10,
                    color: isActive ? AppColors.primary : AppColors.lightGray,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
          
          // Badge للإشعارات
          if (notificationCount > 0)
            Positioned(
              right: MediaQuery.of(context).size.width * 0.04,
              top: 10,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                constraints: BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Center(
                  child: Text(
                    notificationCount > 9 ? '9+' : notificationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}