import 'package:flutter/material.dart';

class FoldedCornerEffect extends StatelessWidget {
  final double size;
  final Color color;
  final Widget? icon;

  const FoldedCornerEffect({
    Key? key,
    this.size = 60,
    this.color = const Color(0xFFF5F5F5),
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // الظل الخلفي
          Positioned(
            top: 8,
            left: 8,
            child: Transform.rotate(
              angle: -0.4,
              child: Container(
                width: size * 0.7,
                height: size * 0.7,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          
          // الزاوية المطوية الرئيسية
          Positioned(
            top: 0,
            left: 0,
            child: Transform.rotate(
              angle: 0.05,
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      color.withOpacity(0.9),
                      color.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // خط التطويق الداخلي
                    Positioned(
                      top: size * 0.15,
                      left: size * 0.15,
                      child: Transform.rotate(
                        angle: -0.4,
                        child: Container(
                          width: size * 0.6,
                          height: 1,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ),
                    
                    // أيقونة (اختياري)
                    if (icon != null)
                      Positioned(
                        top: size * 0.3,
                        left: size * 0.3,
                        child: icon!,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}