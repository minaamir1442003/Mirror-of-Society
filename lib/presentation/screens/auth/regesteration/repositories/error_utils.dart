class ErrorUtils {
  // تحويل رسائل الخطأ التقنية إلى رسائل مفهومة للمستخدم
  static String translateErrorMessage(String error, {bool isArabic = false}) {
    print('🔍 ErrorUtils: Translating error: $error');
    
    // **بسيط جداً: إذا كانت الرسالة تحتوي على جملة معينة نترجمها**
    if (error.contains('The email has already been taken')) {
      return isArabic ? 
        'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.' :
        'The email has already been taken. Please use another email.';
    }
    
    if (error.contains('The phone has already been taken')) {
      return isArabic ? 
        'رقم الهاتف مستخدم بالفعل. يرجى استخدام رقم هاتف آخر.' :
        'The phone has already been taken. Please use another phone number.';
    }
    
    if (error.contains('The interests field is required')) {
      return isArabic ? 
        'الاهتمامات مطلوبة. يرجى اختيار 3 اهتمامات على الأقل.' :
        'Interests are required. Please select at least 3 interests.';
    }
    
    // إذا كانت الرسالة تحتوي على "validation error" نعرض الرسالة الأصلية
    if (error.toLowerCase().contains('validation error')) {
      return isArabic ? 
        'خطأ في التحقق من البيانات: $error' :
        'Validation error: $error';
    }
    
    // رسائل الأخطاء الشائعة بالعربية
    if (isArabic) {
      // أخطاء الشبكة
      if (error.toLowerCase().contains('connection timeout') ||
          error.toLowerCase().contains('connection error') ||
          error.toLowerCase().contains('network error') ||
          error.toLowerCase().contains('socket')) {
        return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
      }
      
      if (error.toLowerCase().contains('timeout')) {
        return 'انتهت مدة الانتظار للاتصال. يرجى المحاولة مرة أخرى.';
      }
      
      // أخطاء المصادقة
      if (error.toLowerCase().contains('unauthorized') ||
          error.toLowerCase().contains('unauthenticated')) {
        return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
      }
      
      // الافتراضي - نعرض الرسالة كما هي
      return error.isNotEmpty ? error : 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    } 
    // رسائل الأخطاء الشائعة بالإنجليزية
    else {
      // Network errors
      if (error.toLowerCase().contains('connection timeout') ||
          error.toLowerCase().contains('connection error') ||
          error.toLowerCase().contains('network error') ||
          error.toLowerCase().contains('socket')) {
        return 'Cannot connect to server. Please check your internet connection and try again.';
      }
      
      if (error.toLowerCase().contains('timeout')) {
        return 'Connection timeout. Please try again.';
      }
      
      // Authentication errors
      if (error.toLowerCase().contains('unauthorized') ||
          error.toLowerCase().contains('unauthenticated')) {
        return 'Session expired. Please log in again.';
      }
      
      // Default - نعرض الرسالة كما هي
      return error.isNotEmpty ? error : 'An unexpected error occurred. Please try again.';
    }
  }
  
  static String _translateValidationError(String error, {required bool isArabic}) {
    final lowerError = error.toLowerCase();
    
    if (isArabic) {
      if (lowerError.contains('email')) {
        return 'البريد الإلكتروني غير صالح. يرجى إدخال بريد إلكتروني صحيح.';
      }
      
      if (lowerError.contains('password') || lowerError.contains('كلمة')) {
        if (lowerError.contains('min') || lowerError.contains('8')) {
          return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل.';
        }
        if (lowerError.contains('confirmation') || lowerError.contains('تأكيد')) {
          return 'كلمات المرور غير متطابقة.';
        }
        return 'كلمة المرور غير صالحة.';
      }
      
      return _cleanErrorMessage(error);
    } else {
      if (lowerError.contains('email')) {
        return 'Invalid email address. Please enter a valid email.';
      }
      
      if (lowerError.contains('password')) {
        if (lowerError.contains('min') || lowerError.contains('8')) {
          return 'Password must be at least 8 characters.';
        }
        if (lowerError.contains('confirmation')) {
          return 'Passwords do not match.';
        }
        return 'Invalid password.';
      }
      
      return _cleanErrorMessage(error);
    }
  }
  
  static String _cleanErrorMessage(String error) {
    // إزالة "Exception: " من البداية
    String cleaned = error.replaceAll('Exception: ', '');
    
    // إزالة رموز الـ JSON أو الفاصلة العليا
    cleaned = cleaned.replaceAll('"', '').replaceAll("'", '');
    
    // إزالة الأقواس المعقوفة
    cleaned = cleaned.replaceAll('{', '').replaceAll('}', '');
    
    // إزالة المحتوى التقني
    if (cleaned.contains('status code:')) {
      cleaned = cleaned.split('status code:').first.trim();
    }
    
    if (cleaned.contains('dioexception')) {
      cleaned = cleaned.replaceAll('dioexception', '');
    }
    
    return cleaned.trim();
  }

  
  // تحويل أخطاء الـ validation من الـ API
  static String formatApiValidationErrors(Map<String, dynamic> errors, {bool isArabic = false}) {
    final messages = <String>[];
    
    errors.forEach((field, errorList) {
      if (errorList is List) {
        for (var error in errorList) {
          final fieldName = _translateFieldName(field, isArabic: isArabic);
          final translatedError = _translateErrorText(error.toString(), isArabic: isArabic);
          messages.add('$fieldName: $translatedError');
        }
      } else if (errorList is String) {
        final fieldName = _translateFieldName(field, isArabic: isArabic);
        final translatedError = _translateErrorText(errorList, isArabic: isArabic);
        messages.add('$fieldName: $translatedError');
      }
    });
    
    return messages.join('\n');
  }
  
  static String _translateFieldName(String field, {required bool isArabic}) {
    final fieldMap = {
      'firstname': isArabic ? 'الاسم الأول' : 'First name',
      'lastname': isArabic ? 'الاسم الأخير' : 'Last name',
      'email': isArabic ? 'البريد الإلكتروني' : 'Email',
      'password': isArabic ? 'كلمة المرور' : 'Password',
      'password_confirmation': isArabic ? 'تأكيد كلمة المرور' : 'Password confirmation',
      'phone': isArabic ? 'رقم الهاتف' : 'Phone number',
      'bio': isArabic ? 'نبذة عنك' : 'Bio',
      'zodiac': isArabic ? 'البرج الفلكي' : 'Zodiac',
      'zodiac_description': isArabic ? 'وصف البرج' : 'Zodiac description',
      'birthdate': isArabic ? 'تاريخ الميلاد' : 'Birth date',
      'country': isArabic ? 'الدولة' : 'Country',
      'interests': isArabic ? 'الاهتمامات' : 'Interests',
      'image': isArabic ? 'الصورة الشخصية' : 'Profile image',
      'cover': isArabic ? 'صورة الغلاف' : 'Cover image',
    };
    
    return fieldMap[field] ?? field;
  }
  
  static String _translateErrorText(String error, {required bool isArabic}) {
    final lowerError = error.toLowerCase();
    
    if (isArabic) {
      if (lowerError.contains('required')) return 'مطلوب';
      if (lowerError.contains('invalid')) return 'غير صالح';
      if (lowerError.contains('taken')) return 'مستخدم بالفعل';
      if (lowerError.contains('min')) return 'قيمة قصيرة جداً';
      if (lowerError.contains('max')) return 'قيمة طويلة جداً';
      if (lowerError.contains('email')) return 'بريد إلكتروني غير صالح';
      if (lowerError.contains('password')) return 'كلمة مرور غير صالحة';
      if (lowerError.contains('phone')) return 'رقم هاتف غير صالح';
      if (lowerError.contains('date')) return 'تاريخ غير صالح';
    } else {
      if (lowerError.contains('required')) return 'is required';
      if (lowerError.contains('invalid')) return 'is invalid';
      if (lowerError.contains('taken')) return 'is already taken';
      if (lowerError.contains('min')) return 'is too short';
      if (lowerError.contains('max')) return 'is too long';
      if (lowerError.contains('email')) return 'must be a valid email';
      if (lowerError.contains('password')) return 'must be a valid password';
      if (lowerError.contains('phone')) return 'must be a valid phone number';
      if (lowerError.contains('date')) return 'must be a valid date';
    }
    
    return error;
  }
}