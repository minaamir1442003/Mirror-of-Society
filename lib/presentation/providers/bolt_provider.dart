import 'package:flutter/material.dart';
import '../../../data/models/bolt_model.dart';

class BoltProvider with ChangeNotifier {
  List<BoltModel> _bolts = [];
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  
  List<BoltModel> get bolts => _bolts;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadBolts() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    
    try {
      // محاكاة تأخير الشبكة
      await Future.delayed(Duration(seconds: 1));
      
      // بيانات وهمية مع أيقونات مناسبة لكل فئة
      _bolts = [
        BoltModel(
          id: '1',
          content: 'هطلت اليوم، أمطار من متوسطة إلى غزيرة على منطقة حالل. فصلت مدينة حالل وبعض المحافظات، ولا تزال الفرصة متاحة لهطول الأمطار .',
          category: 'أخبار',
          categoryColor: Colors.blue,
          categoryIcon: Icons.newspaper, // أيقونة الأخبار
          createdAt: DateTime.now().subtract(Duration(minutes: 30)),
          userName: 'أحمد محمد',
          userImage: 'assets/image/images.jpg',
          likes: 42,
          comments: 12,
          shares: 5,
        ),
        BoltModel(
          id: '2',
          content: 'جلسة برمجة ليلية مع فلاتر، هناك شيء سحري في البرمجة عندما يكون العالم نائماً 🌙💻',
          category: 'تكنولوجيا',
          categoryColor: Colors.purple,
          categoryIcon: Icons.computer, // أيقونة التكنولوجيا
          createdAt: DateTime.now().subtract(Duration(hours: 2)),
          userName: 'مبرمج فلاتر',
          userImage: 'assets/image/images.jpg',
          likes: 89,
          comments: 23,
          shares: 8,
        ),
        BoltModel(
          id: '3',
          content: 'مباراة رائعة اليوم بين الفريقين، الرياضة تجمعنا رغم الاختلافات ⚽️❤️',
          category: 'رياضة',
          categoryColor: Colors.green,
          categoryIcon: Icons.sports_soccer, // أيقونة الرياضة
          createdAt: DateTime.now().subtract(Duration(hours: 5)),
          userName: 'محب الرياضة',
          userImage: 'assets/image/images.jpg',
          likes: 156,
          comments: 45,
          shares: 21,
        ),
        BoltModel(
          id: '4',
          content: 'قراءة كتاب جديد عن فن الكتابة الإبداعية. الكلمات هي أقوى وسيلة للتعبير عن الذات 📚✨',
          category: 'أدب',
          categoryColor: Colors.orange,
          categoryIcon: Icons.menu_book, // أيقونة الأدب
          createdAt: DateTime.now().subtract(Duration(hours: 8)),
          userName: 'قارئ نهم',
          userImage: 'assets/image/images.jpg',
          likes: 78,
          comments: 32,
          shares: 15,
        ),
        BoltModel(
          id: '5',
          content: 'نقاش حول مستقبل الاقتصاد العربي في ظل التغيرات العالمية الحالية 💹',
          category: 'اقتصاد',
          categoryColor: Colors.red,
          categoryIcon: Icons.trending_up, // أيقونة الاقتصاد
          createdAt: DateTime.now().subtract(Duration(hours: 12)),
          userName: 'خبير اقتصادي',
          userImage: 'assets/image/images.jpg',
          likes: 203,
          comments: 67,
          shares: 34,
        ),
        // يمكنك إضافة المزيد مع أيقونات مناسبة:
        BoltModel(
          id: '6',
          content: 'حفل موسيقي رائع الليلة، الفن غذاء الروح 🎵🎻',
          category: 'فن',
          categoryColor: Colors.pink,
          categoryIcon: Icons.music_note, // أيقونة الفن
          createdAt: DateTime.now().subtract(Duration(hours: 3)),
          userName: 'فنان',
          userImage: 'assets/image/images.jpg',
          likes: 120,
          comments: 40,
          shares: 18,
        ),
        BoltModel(
          id: '7',
          content: 'اكتشاف جديد في مجال الطب يحمل الأمل لمرضى السرطان 🩺💊',
          category: 'صحة',
          categoryColor: Colors.teal,
          categoryIcon: Icons.medical_services, // أيقونة الصحة
          createdAt: DateTime.now().subtract(Duration(hours: 6)),
          userName: 'طبيب',
          userImage: 'assets/image/images.jpg',
          likes: 210,
          comments: 55,
          shares: 32,
        ),
        BoltModel(
          id: '8',
          content: 'رحلة إلى جبال الألب، الطبيعة تمنحنا السلام الداخلي 🏔️🌲',
          category: 'سفر',
          categoryColor: Colors.brown,
          categoryIcon: Icons.flight_takeoff, // أيقونة السفر
          createdAt: DateTime.now().subtract(Duration(hours: 10)),
          userName: 'مسافر',
          userImage: 'assets/image/images.jpg',
          likes: 95,
          comments: 28,
          shares: 12,
        ),
      ];
      
      _isLoading = false;
    } catch (e) {
      _hasError = true;
      _errorMessage = 'حدث خطأ في تحميل البيانات';
      _isLoading = false;
    }
    
    notifyListeners();
  }
  
  void clearBolts() {
    _bolts = [];
    notifyListeners();
  }
  
  void addBolt(BoltModel bolt) {
    _bolts.insert(0, bolt);
    notifyListeners();
  }
  
  void likeBolt(String boltId) {
    final index = _bolts.indexWhere((bolt) => bolt.id == boltId);
    if (index != -1) {
      _bolts[index] = BoltModel(
        id: _bolts[index].id,
        content: _bolts[index].content,
        category: _bolts[index].category,
        categoryColor: _bolts[index].categoryColor,
        categoryIcon: _bolts[index].categoryIcon, // أضف هذا
        createdAt: _bolts[index].createdAt,
        userName: _bolts[index].userName,
        userImage: _bolts[index].userImage,
        likes: _bolts[index].likes + 1,
        comments: _bolts[index].comments,
        shares: _bolts[index].shares,
      );
      notifyListeners();
    }
  }
  
  void addComment(String boltId) {
    final index = _bolts.indexWhere((bolt) => bolt.id == boltId);
    if (index != -1) {
      _bolts[index] = BoltModel(
        id: _bolts[index].id,
        content: _bolts[index].content,
        category: _bolts[index].category,
        categoryColor: _bolts[index].categoryColor,
        categoryIcon: _bolts[index].categoryIcon, // أضف هذا
        createdAt: _bolts[index].createdAt,
        userName: _bolts[index].userName,
        userImage: _bolts[index].userImage,
        likes: _bolts[index].likes,
        comments: _bolts[index].comments + 1,
        shares: _bolts[index].shares,
      );
      notifyListeners();
    }
  }
}