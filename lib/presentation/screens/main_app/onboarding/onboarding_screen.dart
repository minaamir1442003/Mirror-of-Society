import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      check: true,
      title: 'مرحباً بك في مرآة المجتمع',
      description: 'منصة التواصل العربي النصي الأولى\nانشر أفكارك بسرعة وسهولة',
      icon: Icons.bolt,
      backgroundColor: Color(0xFF1DA1F2),
      textColor: Colors.white,
      image: 'assets/image/logo.png',
    ),
    OnboardingPage(
      title: 'نشر برقيات',
      description:
          'اكتب برقياتك القصيرة (حتى 250 حرف)\nواختر تصنيفها الملون المناسب',
      icon: Icons.edit,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      image: '📝',
    ),
    OnboardingPage(
      title: 'التصنيفات الملونة',
      description: 'كل تصنيف له لون مميز\nتكنولوجيا، رياضة، فن، اقتصاد وأكثر',
      icon: Icons.category,
      backgroundColor: Colors.orange,
      textColor: Colors.white,
      image: '🎨',
    ),
    OnboardingPage(
      title: 'نظام الأبراج',
      description: 'اكتشف برجك وصفاته\nواسمح للآخرين بمشاهدته في ملفك الشخصي',
      icon: Icons.star,
      backgroundColor: Color(0xFF9B59B6),
      textColor: Colors.white,
      image: '✨',
    ),
    OnboardingPage(
      title: 'الرتب والأوسمة',
      description:
          'احصل على رتبة جديدة مع كل برقية\nوتحلى بألوان الرتب المميزة',
      icon: Icons.workspace_premium,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      image: '🏆',
    ),
  ];

  void _goToLogin() async {
    await SharedPrefsService.setOnboardingCompleted();
    await SharedPrefsService.setFirstLaunchCompleted();

    Navigator.of(context).pushReplacementNamed('/login');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], index);
            },
          ),

          // زر التخطي (يظهر في كل الصفحات ما عدا الأخيرة)
          if (_currentPage != _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: Text(
                    'تخطي',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // المؤشرات
          Positioned(bottom: 100, left: 0, right: 0, child: _buildIndicators()),

          // زر السابق
          if (_currentPage > 0)
            Positioned(
              left: 20,
              bottom: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextButton(
                  onPressed: _previousPage,
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, size: 20, color: Colors.white),
                      SizedBox(width: 5),
                      Text(
                        'السابق',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // زر التالي (للصفحات ما عدا الأخيرة)
          if (_currentPage < _pages.length - 1)
            Positioned(
              right: 20,
              bottom: 40,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextButton(
                  onPressed: _nextPage,
                  child: Row(
                    children: [
                      Text(
                        'التالي',
                        style: TextStyle(
                          color: _pages[_currentPage].backgroundColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 5),
                      Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: _pages[_currentPage].backgroundColor,
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

  Widget _buildPage(OnboardingPage page, int index) {
    return Container(
      color: page.backgroundColor,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Emoji كبير
              Container(
                height: 180,
                width: 180,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child:  page.check? Image.asset("assets/image/logo.png"):Text(page.image, style: TextStyle(fontSize: 80)),
                ),
              ),

              SizedBox(height: 40),

              // الأيقونة
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(35),
                ),
                child: Icon(page.icon, size: 35, color: Colors.white),
              ),

              SizedBox(height: 30),

              // العنوان
              Text(
                page.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 15),

              // الوصف
              Text(
                page.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40),

              // زر الاستمرار (يظهر فقط في الصفحة الأخيرة)
              if (index == _pages.length - 1)
                Container(
                  width: double.infinity,
                  height: 55,
                  margin: EdgeInsets.symmetric(horizontal: 40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextButton(
                    onPressed: _goToLogin,
                    style: TextButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ابدأ الآن',
                          style: TextStyle(
                            color: page.backgroundColor,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 10),
                        Icon(Icons.arrow_forward, color: page.backgroundColor),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 24 : 10,
          height: 10,
          decoration: BoxDecoration(
            color:
                _currentPage == index
                    ? Colors.white
                    : Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(5),
          ),
        );
      }),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color backgroundColor;
  final Color textColor;
  final String image;
  final bool check;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
    required this.image,
    this.check =false
  });
}
