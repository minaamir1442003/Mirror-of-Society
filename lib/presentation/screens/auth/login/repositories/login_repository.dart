// lib/data/repositories/login_repository.dart - اسم جديد
import 'package:app_1/core/constants/api_const.dart';

import 'package:app_1/presentation/screens/auth/login/models/login_model.dart';
import 'package:app_1/presentation/screens/auth/login/models/login_response_model.dart';
import 'package:dio/dio.dart';

class LoginRepository {  // تغيير الاسم هنا
  final Dio dio;

  LoginRepository({required this.dio});  // تغيير الاسم هنا

  Future<LoginResponseModel> login(LoginModel loginData) async {
    try {
      final headers = await ApiConstants.headers;
      
      final response = await dio.post(
        ApiConstants.login,
        data: loginData.toJson(),
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw _handleError(response);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('حدث خطأ غير متوقع: $e');
    }
  }

  String _handleError(Response response) {
    if (response.statusCode == 401) {
      final message = response.data['message'] ?? 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      return message;
    } else if (response.statusCode == 422) {
      final errors = response.data['errors'];
      if (errors != null && errors['email'] != null) {
        return errors['email'][0];
      } else if (errors != null && errors['password'] != null) {
        return errors['password'][0];
      }
      return response.data['message'] ?? 'بيانات غير صالحة';
    } else if (response.statusCode == 429) {
      return 'لقد تجاوزت عدد المحاولات المسموح بها، حاول مرة أخرى لاحقاً';
    } else if (response.statusCode == 500) {
      return 'حدث خطأ في الخادم، حاول مرة أخرى لاحقاً';
    } else {
      return response.data['message'] ?? 'حدث خطأ غير متوقع';
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'انتهت مهلة الاتصال، تحقق من اتصالك بالإنترنت';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'لا يمكن الاتصال بالخادم، تحقق من اتصالك بالإنترنت';
    } else if (e.type == DioExceptionType.badResponse) {
      return _handleError(e.response!);
    } else {
      return 'حدث خطأ في الاتصال: ${e.message}';
    }
  }
}