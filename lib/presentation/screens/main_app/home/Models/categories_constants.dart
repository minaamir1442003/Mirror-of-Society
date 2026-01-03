class CategoriesConstants {
  // ✅ التصنيفات باللغة الإنجليزية
  static List<Map<String, dynamic>> englishCategories = [
    {
      "id": "1",
      "name": "Politics",
      "color": "#dc3545",
      "icon": null,
      "telegrams_count": 33
    },
    {
      "id": "2",
      "name": "Sports",
      "color": "#28a745",
      "icon": null,
      "telegrams_count": 35
    },
    {
      "id": "3",
      "name": "Arts",
      "color": "#6f42c1",
      "icon": null,
      "telegrams_count": 34
    },
    {
      "id": "4",
      "name": "Technology",
      "color": "#007bff",
      "icon": null,
      "telegrams_count": 36
    },
    {
      "id": "5",
      "name": "Health",
      "color": "#17a2b8",
      "icon": null,
      "telegrams_count": 26
    },
    {
      "id": "6",
      "name": "Travel",
      "color": "#ffc107",
      "icon": null,
      "telegrams_count": 38
    },
    {
      "id": "7",
      "name": "Food",
      "color": "#fd7e14",
      "icon": null,
      "telegrams_count": 27
    },
    {
      "id": "8",
      "name": "Fashion",
      "color": "#e83e8c",
      "icon": null,
      "telegrams_count": 31
    },
    {
      "id": "9",
      "name": "Science",
      "color": "#20c997",
      "icon": null,
      "telegrams_count": 33
    },
    {
      "id": "10",
      "name": "Business",
      "color": "#343a40",
      "icon": null,
      "telegrams_count": 44
    },
    {
      "id": "11",
      "name": "Music",
      "color": "#6610f2",
      "icon": null,
      "telegrams_count": 33
    },
    {
      "id": "12",
      "name": "Movies",
      "color": "#d63384",
      "icon": null,
      "telegrams_count": 37
    },
    {
      "id": "13",
      "name": "Gaming",
      "color": "#198754",
      "icon": null,
      "telegrams_count": 26
    },
    {
      "id": "14",
      "name": "Literature",
      "color": "#fd7e14",
      "icon": null,
      "telegrams_count": 39
    },
    {
      "id": "15",
      "name": "Education",
      "color": "#0dcaf0",
      "icon": null,
      "telegrams_count": 30
    }
  ];

  // ✅ التصنيفات باللغة العربية
  static List<Map<String, dynamic>> arabicCategories = [
    {
      "id": "1",
      "name": "سياسة",
      "color": "#dc3545",
      "icon": null,
      "telegrams_count": 33
    },
    {
      "id": "2",
      "name": "رياضة",
      "color": "#28a745",
      "icon": null,
      "telegrams_count": 35
    },
    {
      "id": "3",
      "name": "فن",
      "color": "#6f42c1",
      "icon": null,
      "telegrams_count": 34
    },
    {
      "id": "4",
      "name": "تكنولوجيا",
      "color": "#007bff",
      "icon": null,
      "telegrams_count": 36
    },
    {
      "id": "5",
      "name": "صحة",
      "color": "#17a2b8",
      "icon": null,
      "telegrams_count": 26
    },
    {
      "id": "6",
      "name": "سفر",
      "color": "#ffc107",
      "icon": null,
      "telegrams_count": 38
    },
    {
      "id": "7",
      "name": "طعام",
      "color": "#fd7e14",
      "icon": null,
      "telegrams_count": 27
    },
    {
      "id": "8",
      "name": "موضة",
      "color": "#e83e8c",
      "icon": null,
      "telegrams_count": 31
    },
    {
      "id": "9",
      "name": "علوم",
      "color": "#20c997",
      "icon": null,
      "telegrams_count": 33
    },
    {
      "id": "10",
      "name": "أعمال",
      "color": "#343a40",
      "icon": null,
      "telegrams_count": 44
    },
    {
      "id": "11",
      "name": "موسيقى",
      "color": "#6610f2",
      "icon": null,
      "telegrams_count": 33
    },
    {
      "id": "12",
      "name": "أفلام",
      "color": "#d63384",
      "icon": null,
      "telegrams_count": 37
    },
    {
      "id": "13",
      "name": "ألعاب",
      "color": "#198754",
      "icon": null,
      "telegrams_count": 26
    },
    {
      "id": "14",
      "name": "أدب",
      "color": "#fd7e14",
      "icon": null,
      "telegrams_count": 39
    },
    {
      "id": "15",
      "name": "تعليم",
      "color": "#0dcaf0",
      "icon": null,
      "telegrams_count": 30
    }
  ];

  // ✅ دالة للحصول على التصنيفات بناءً على اللغة
  static List<Map<String, dynamic>> getCategories(bool isArabic) {
    return isArabic ? arabicCategories : englishCategories;
  }

  // ✅ دالة للحصول على اسم "الكل" بناءً على اللغة
  static String getAllCategoryName(bool isArabic) {
    return isArabic ? "الكل" : "All";
  }
}