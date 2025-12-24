import 'package:app_1/core/constants/dio_client.dart';
import 'package:app_1/core/constants/shared%20pref.dart';
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
import 'package:app_1/presentation/screens/main_app/home/Cubit/home_cubit.dart';
import 'package:app_1/presentation/screens/main_app/home/Repository/home_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/auth_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/cubits/update_profile_cubit.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/auth_repository.dart';
import 'package:app_1/presentation/screens/main_app/profile/repositories/profile_repository.dart';
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
  
  // ✅ أضف VerificationRepository هنا
  sl.registerSingleton<VerificationRepository>(
    VerificationRepository(dioClient: sl<DioClient>()),
  );
  
  sl.registerSingleton<TelegramRepository>(
    TelegramRepository(dioClient: sl<DioClient>()),
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
  
  // ✅ أضف UserProfileRepository هنا - داخل دالة init()
  sl.registerSingleton<UserProfileRepository>(
    UserProfileRepository(dio: sl<DioClient>().dio),
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
  
  // ✅ أضف VerificationCubit هنا
  sl.registerFactory<VerificationCubit>(
    () => VerificationCubit(
      verificationRepository: sl<VerificationRepository>(),
    ),
  );
  
  // ✅ أضف UserProfileCubit هنا - داخل دالة init()
  sl.registerFactory<UserProfileCubit>(
    () => UserProfileCubit(
      repository: sl<UserProfileRepository>(),
      storageService: sl<StorageService>(),
    ),
  );
}

// ✅ دالة reset للـ user dependencies
Future<void> resetUserDependencies() async {
  print('🔄 Resetting user dependencies...');
  
  try {
    // 1. Reset ProfileCubit
    final profileCubit = sl.get<ProfileCubit>();
    profileCubit.clearAllData();
    //2

       if (sl.isRegistered<HomeCubit>()) {
      final homeCubit = sl.get<HomeCubit>();
      await homeCubit.clearCacheAndData();
    }
    
    // 3. Reset AuthCubit
    if (sl.isRegistered<AuthCubit>()) {
      sl.unregister<AuthCubit>();
    }
    
  

    // 3. إعادة تسجيل الـ Cubits
    sl.registerFactory<AuthCubit>(
      () => AuthCubit(
        authRepository: sl<AuthRepository>(),
        profileCubit: sl<ProfileCubit>(),
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
    
    sl.registerFactory<TelegramCubit>(
      () => TelegramCubit(
        telegramRepository: sl<TelegramRepository>(),
        categoryService: sl<CategoryService>(),
      ),
    );

    print('✅ User dependencies reset successfully');
  } catch (e) {
    print('❌ Error resetting dependencies: $e');
  }
}