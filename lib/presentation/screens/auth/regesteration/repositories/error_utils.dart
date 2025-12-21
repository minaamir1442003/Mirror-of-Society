// lib/core/utils/error_utils.dart
class ErrorUtils {
  // تحويل رسائل الخطأ التقنية إلى رسائل مفهومة للمستخدم
  static String translateErrorMessage(String error, {bool isArabic = false}) {
    print('🔍 ErrorUtils: Translating error: $error');
    
    // تحويل النص إلى صيغة صغيرة لسهولة المقارنة
    final lowerError = error.toLowerCase();
    
    // **فحص خاص لرسائل validation error من السيرفر**
    if (error.contains('validation error') || error.contains('errors: {')) {
      return _extractValidationMessage(error, isArabic: isArabic);
    }
    
    // رسائل الأخطاء الشائعة بالعربية
    if (isArabic) {
      // أخطاء الشبكة
      if (lowerError.contains('connection timeout') ||
          lowerError.contains('connection error') ||
          lowerError.contains('network error') ||
          lowerError.contains('socket')) {
        return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصالك بالإنترنت والمحاولة مرة أخرى.';
      }
      
      if (lowerError.contains('timeout')) {
        return 'انتهت مدة الانتظار للاتصال. يرجى المحاولة مرة أخرى.';
      }
      
      // أخطاء المصادقة
      if (lowerError.contains('unauthorized') ||
          lowerError.contains('unauthenticated')) {
        return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
      }
      
      // أخطاء التحقق (Validation)
      if (lowerError.contains('validation') ||
          lowerError.contains('required') ||
          lowerError.contains('invalid')) {
        return _translateValidationError(error, isArabic: true);
      }
      
      // أخطاء التسجيل المحددة
      if (lowerError.contains('email already exists') ||
          lowerError.contains('email taken') ||
          lowerError.contains('البريد الإلكتروني مستخدم') ||
          lowerError.contains('the email has already been taken')) {
        return 'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.';
      }
      
      if (lowerError.contains('phone already exists') ||
          lowerError.contains('رقم الهاتف مستخدم')) {
        return 'رقم الهاتف مستخدم بالفعل. يرجى استخدام رقم هاتف آخر.';
      }
      
      if (lowerError.contains('weak password') ||
          lowerError.contains('كلمة مرور ضعيفة')) {
        return 'كلمة المرور ضعيفة. يجب أن تحتوي على 8 أحرف على الأقل مع مزيج من الأحرف والأرقام.';
      }
      
      // الافتراضي
      return 'حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.';
    } 
    // رسائل الأخطاء الشائعة بالإنجليزية
    else {
      // Network errors
      if (lowerError.contains('connection timeout') ||
          lowerError.contains('connection error') ||
          lowerError.contains('network error') ||
          lowerError.contains('socket')) {
        return 'Cannot connect to server. Please check your internet connection and try again.';
      }
      
      if (lowerError.contains('timeout')) {
        return 'Connection timeout. Please try again.';
      }
      
      // Authentication errors
      if (lowerError.contains('unauthorized') ||
          lowerError.contains('unauthenticated')) {
        return 'Session expired. Please log in again.';
      }
      
      // Validation errors
      if (lowerError.contains('validation') ||
          lowerError.contains('required') ||
          lowerError.contains('invalid')) {
        return _translateValidationError(error, isArabic: false);
      }
      
      // Registration errors
      if (lowerError.contains('email already exists') ||
          lowerError.contains('email taken') ||
          lowerError.contains('the email has already been taken')) {
        return 'Email address is already registered. Please use another email.';
      }
      
      if (lowerError.contains('phone already exists')) {
        return 'Phone number is already registered. Please use another phone number.';
      }
      
      if (lowerError.contains('weak password')) {
        return 'Password is too weak. Must be at least 8 characters with mix of letters and numbers.';
      }
      
      // Default
      return 'An unexpected error occurred. Please try again.';
    }
  }
  
  // دالة خاصة لاستخراج رسائل validation من response السيرفر
  static String _extractValidationMessage(String error, {bool isArabic = false}) {
    print('📝 Extracting validation message from: $error');
    
    try {
      // تحليل رسالة الخطأ لاستخراج errors
      if (error.contains('errors: {')) {
        final startIndex = error.indexOf('errors: {');
        final endIndex = error.lastIndexOf('}');
        
        if (startIndex != -1 && endIndex != -1) {
          final errorsString = error.substring(startIndex + 9, endIndex);
          print('🔍 Errors substring: $errorsString');
          
          // استخراج رسائل الخطأ
          if (errorsString.contains('email:')) {
            final emailStart = errorsString.indexOf('email:');
            final emailEnd = errorsString.indexOf(']', emailStart);
            if (emailStart != -1 && emailEnd != -1) {
              final emailError = errorsString.substring(emailStart + 6, emailEnd);
              if (emailError.contains('already been taken')) {
                return isArabic ? 
                  'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.' :
                  'Email address is already registered. Please use another email.';
              }
            }
          }
          
          // يمكن إضافة تحليل لحقول أخرى هنا
          if (errorsString.contains('phone:')) {
            return isArabic ? 
              'رقم الهاتف مستخدم بالفعل. يرجى استخدام رقم هاتف آخر.' :
              'Phone number is already registered. Please use another phone number.';
          }
        }
      }
      
      // رسائل خطأ عامة
      if (error.contains('The email has already been taken')) {
        return isArabic ? 
          'البريد الإلكتروني مستخدم بالفعل. يرجى استخدام بريد إلكتروني آخر.' :
          'Email address is already registered. Please use another email.';
      }
      
      if (error.contains('validation error')) {
        return isArabic ? 
          'حدث خطأ في التحقق من البيانات. يرجى مراجعة المعلومات المدخلة.' :
          'Validation error occurred. Please check your input data.';
      }
      
    } catch (e) {
      print('❌ Error extracting validation message: $e');
    }
    
    // الافتراضي إذا لم نتمكن من استخراج رسالة محددة
    return isArabic ? 
      'حدث خطأ في التسجيل. يرجى المحاولة مرة أخرى.' :
      'Registration error occurred. Please try again.';
  }
  
  // باقي الكود يظل كما هو...
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