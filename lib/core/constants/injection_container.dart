import 'package:app_1/core/constants/dio_client.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
import 'package:app_1/data/services/language_service.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/cubit/forgot_password_cubit.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/cubit/otp_cubit.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/repository/logout_repository.dart';
import 'package:app_1/presentation/screens/auth/forgetpassword/repository/otp_repository.dart';
import 'package:app_1/presentation/screens/auth/login/cubit/login_cubit.dart';
import 'package:app_1/presentation/screens/auth/login/repositories/login_repository.dart';
import 'package:app_1/presentation/screens/auth/regesteration/repositories/register_repository.dart';
import 'package:app_1/presentation/screens/auth/regesteration/cubit/register_cubit.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/cubits/telegram_cubit.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/repositories/telegram_repository.dart';
import 'package:app_1/presentation/screens/main_app/create_bolt/services/category_service.dart';
import 'package:app_1/presentation/screens/main_app/explore/cubits/category_cubit.dart';
import 'package:app_1/presentation/screens/main_app/explore/repositories/category_repository.dart';
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/home/Repository/home_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/auth_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/comment_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/like_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/repost_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/update_profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/auth_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/comment_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/like_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/profile_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/repost_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/update_profile_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/cubits/verification_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/verification/repositories/verification_repository.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/cubits/user_profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/user_profile/repositories/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final GetIt sl = GetIt.instance;

Future<void> init(GlobalKey<NavigatorState> navigatorKey) async {
  // Services
  sl.registerSingleton<StorageService>(StorageService());
  
  // Network
  sl.registerSingleton<DioClient>(DioClient(navigatorKey: navigatorKey));
  
  // Repositories
  sl.registerSingleton<LoginRepository>(
    LoginRepository(dio: sl<DioClient>().dio),
  );
  
  sl.registerSingleton<RegisterRepository>(
    RegisterRepository(dioClient: sl<DioClient>()),
  );
  
  sl.registerSingleton<AuthRepository>(
    AuthRepository(dio: sl<DioClient>().dio),
  );
  
  sl.registerSingleton<ProfileRepository>(
    ProfileRepository(dio: sl<DioClient>().dio),
  );
  
  sl.registerSingleton<LogoutRepository>(
    LogoutRepository(dio: sl<DioClient>().dio),
  );
  
  sl.registerSingleton<VerificationRepository>(
    VerificationRepository(dioClient: sl<DioClient>()),
  );
  
sl.registerSingleton<TelegramRepository>(
    TelegramRepository(dio: sl<DioClient>().dio), // ✅ استخدام dio مباشرة
  );
  
  sl.registerSingleton<CategoryService>(
    CategoryService(dioClient: sl<DioClient>()),
  );
  
  sl.registerSingleton<UpdateProfileRepository>(
    UpdateProfileRepository(dio: sl<DioClient>().dio),
  );
  
  sl.registerSingleton<HomeRepository>(
    HomeRepository(dio: sl<DioClient>().dio),
  );
  
  sl.registerSingleton<UserProfileRepository>(
    UserProfileRepository(dio: sl<DioClient>().dio),
  );

  // ✅ تسجيل LikeRepository كـ Singleton
  sl.registerLazySingleton<LikeRepository>(
    () => LikeRepository(dio: sl<DioClient>().dio),
  );

  // Cubits
  sl.registerFactory<LoginCubit>(
    () => LoginCubit(
      loginRepository: sl<LoginRepository>(),
      storageService: sl<StorageService>(),
    ),
  );
  
  sl.registerFactory<RegisterCubit>(
    () => RegisterCubit(
      registerRepository: sl<RegisterRepository>(),
      storageService: sl<StorageService>(),
    ),
  );
  
  sl.registerFactory<AuthCubit>(
    () => AuthCubit(
      authRepository: sl<AuthRepository>(),
      profileCubit: sl<ProfileCubit>(),
    ),
  );
  
  sl.registerSingleton<ProfileCubit>(
    ProfileCubit(profileRepository: sl<ProfileRepository>()),
  );
  
  sl.registerFactory<ForgotPasswordCubit>(
    () => ForgotPasswordCubit(authRepository: sl<LogoutRepository>()),
  );
  
  sl.registerFactory<HomeCubit>(
    () => HomeCubit(
      homeRepository: sl<HomeRepository>(),
      storageService: sl<StorageService>(),
    ),
  );

  sl.registerFactory<UpdateProfileCubit>(
    () => UpdateProfileCubit(updateRepository: sl<UpdateProfileRepository>()),
  );
  
  sl.registerFactory<OtpCubit>(
    () => OtpCubit(otpRepository: sl<OtpRepository>()),
  );
  
   sl.registerFactory<TelegramCubit>(
    () => TelegramCubit(
      telegramRepository: sl<TelegramRepository>(),
      categoryService: sl<CategoryService>(),
    ),
  );
  
  sl.registerFactory<VerificationCubit>(
    () => VerificationCubit(
      verificationRepository: sl<VerificationRepository>(),
    ),
  );
  
  sl.registerFactory<UserProfileCubit>(
    () => UserProfileCubit(
      repository: sl<UserProfileRepository>(),
      storageService: sl<StorageService>(),
    ),
  );
  sl.registerLazySingleton<CategoryRepository>(
  () => CategoryRepository(dio: sl<DioClient>().dio),
);

// ✅ إضافة CategoryCubit
sl.registerFactory<CategoryCubit>(
  () => CategoryCubit(
    categoryRepository: sl<CategoryRepository>(),
  
  ),
);
  
  // ✅ تسجيل LikeCubit كـ Singleton (مهم)
  sl.registerLazySingleton<LikeCubit>(
    () => LikeCubit(likeRepository: sl<LikeRepository>()),
  );
  sl.registerLazySingleton<CommentRepository>(
  () => CommentRepository(dio: sl<DioClient>().dio),
);

// ✅ تسجيل CommentCubit
sl.registerLazySingleton<CommentCubit>(
  () => CommentCubit(commentRepository: sl<CommentRepository>()),
);
sl.registerLazySingleton<RepostRepository>(
  () => RepostRepository(dio: sl<DioClient>().dio),
);

// Cubits
sl.registerLazySingleton<RepostCubit>(
  () => RepostCubit(repostRepository: sl<RepostRepository>()),
);
}

// ✅ تعديل دالة resetUserDependencies
Future<void> resetUserDependencies() async {
  print('🔄 Resetting user dependencies...');
  
  try {
    // 1. Reset ProfileCubit
    final profileCubit = sl.get<ProfileCubit>();
    profileCubit.clearAllData();
    
    // 2. Reset HomeCubit
    if (sl.isRegistered<HomeCubit>()) {
      final homeCubit = sl.get<HomeCubit>();
      await homeCubit.clearCacheAndData();
    }
    
    // 3. Reset AuthCubit فقط (لأنه مرتبط بالدخول والخروج)
    if (sl.isRegistered<AuthCubit>()) {
      sl.unregister<AuthCubit>();
    }
    
    // ✅ لا تقم بإلغاء تسجيل LikeCubit و LikeRepository
    // لأنها لا تعتمد على حالة المستخدم
    
    // ✅ إعادة تسجيل AuthCubit
    sl.registerFactory<AuthCubit>(
      () => AuthCubit(
        authRepository: sl<AuthRepository>(),
        profileCubit: sl<ProfileCubit>(),
      ),
    );
    
    // ✅ إعادة تسجيل باقي الـ Cubits إذا لزم الأمر
    // (تأكد من أنها مسجلة بالفعل في init)
    
    // ✅ إعادة تسجيل VerificationCubit إذا لزم الأمر
    if (!sl.isRegistered<VerificationCubit>()) {
      sl.registerFactory<VerificationCubit>(
        () => VerificationCubit(
          verificationRepository: sl<VerificationRepository>(),
        ),
      );
    }
    
    // ✅ إعادة تسجيل UserProfileCubit إذا لزم الأمر
    if (!sl.isRegistered<UserProfileCubit>()) {
      sl.registerFactory<UserProfileCubit>(
        () => UserProfileCubit(
          repository: sl<UserProfileRepository>(),
          storageService: sl<StorageService>(),
        ),
      );
    }
    
    // ✅ إعادة تسجيل TelegramCubit إذا لزم الأمر
    if (!sl.isRegistered<TelegramCubit>()) {
      sl.registerFactory<TelegramCubit>(
        () => TelegramCubit(
          telegramRepository: sl<TelegramRepository>(),
          categoryService: sl<CategoryService>(),
        ),
      );
    }

    print('✅ User dependencies reset successfully');
  } catch (e) {
    print('❌ Error resetting dependencies: $e');
  }
}