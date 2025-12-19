import 'package:flutter/material.dart';
import 'package:app_1/core/theme/app_colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      height: 90.h,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15.r,
            offset: Offset(0, -4),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.r),
          topRight: Radius.circular(25.r),
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
              height: 4.h,
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
              SizedBox(width: 70.w), // استخدام .w
              
              // العنصر الرابع: الإشعارات
              _buildNotificationItem(context, 0.15),
              
              // العنصر الخامس: الملف الشخصي
              _buildNavItem(context, 4, Icons.person_outlined, Icons.person, 'الملف', 0.15),
            ],
          ),
          
          // الزر العائم في المنتصف
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 35.w, // استخدام .w
            top: 5.h, // استخدام .h
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
        borderRadius: BorderRadius.circular(12.r), // استخدام .r
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.w), // استخدام .w
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
              ),
              child: Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppColors.primary : AppColors.lightGray,
                size: 22.sp, // استخدام .sp
              ),
            ),
            SizedBox(height: 4.h), // استخدام .h
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp, // استخدام .sp
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
        width: 70.w, // استخدام .w
        height: 70.h, // استخدام .h
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
              blurRadius: 15.r, // استخدام .r
              spreadRadius: 2.w, // استخدام .w
              offset: Offset(0, 5.h), // استخدام .h
            ),
          ],
          border: Border.all(
            color: Colors.white,
            width: 4.w, // استخدام .w
          ),
        ),
        child: Center(
          child: Icon(
            isActive ? Icons.check : Icons.add,
            color: Colors.white,
            size: 30.sp, // استخدام .sp
          ),
        ),
      ),
    );
  }
  
  Widget _buildNotificationItem(BuildContext context, double widthFactor) {
    bool isActive = currentIndex == 3;
    
    return Container(
      width: MediaQuery.of(context).size.width * widthFactor,
      padding: EdgeInsets.only(right: 20.w), // استخدام .w
      child: Stack(
        children: [
          InkWell(
            onTap: () => onTabSelected(3),
            borderRadius: BorderRadius.circular(12.r), // استخدام .r
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(8.w), // استخدام .w
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
                  ),
                  child: Icon(
                    isActive ? Icons.notifications : Icons.notifications_outlined,
                    color: isActive ? AppColors.primary : AppColors.lightGray,
                    size: 22.sp, // استخدام .sp
                  ),
                ),
                SizedBox(height: 4.h), // استخدام .h
                Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 8.sp, // استخدام .sp
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
              top: 10.h, // استخدام .h
              child: Container(
                padding: EdgeInsets.all(4.w), // استخدام .w
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2.w, // استخدام .w
                  ),
                ),
                constraints: BoxConstraints(
                  minWidth: 20.w, // استخدام .w
                  minHeight: 20.h, // استخدام .h
                ),
                child: Center(
                  child: Text(
                    notificationCount > 9 ? '9+' : notificationCount.toString(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9.sp, // استخدام .sp
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