import 'package:get_it/get_it.dart';

import 'config/routes/app_router.dart';
import 'core/cache/cache_manager.dart';
import 'core/database/hive_manager.dart';
import 'core/localization/localization_manager.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/network/dio_client.dart';
import 'core/offline/connectivity_cubit.dart';
import 'core/offline/connectivity_service.dart';
import 'core/offline/offline_manager.dart';
import 'core/offline/sync_queue.dart';
// Features
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/settings/presentation/bloc/locale_cubit.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  //==============================
  // CORE
  //==============================
  sl.registerLazySingleton<CacheManager>(() => CacheManager.instance);
  sl.registerLazySingleton<DioClient>(() => DioClient.instance);
  sl.registerLazySingleton<NavigationManager>(() => NavigationManager.instance);
  sl.registerLazySingleton<LocalizationManager>(() => LocalizationManager.instance);
  sl.registerLazySingleton<AppRouter>(() => AppRouter());

  //==============================
  // OFFLINE-FIRST
  //==============================
  await _initOfflineFirst();

  //==============================
  // FEATURES
  //==============================
  await _initAuthFeature();
  await _initSettingsFeature();
}

Future<void> _initOfflineFirst() async {
  // Database
  sl.registerLazySingleton<HiveManager>(() => HiveManager.instance);

  // Connectivity
  sl.registerLazySingleton<ConnectivityService>(() => ConnectivityService.instance);

  // Sync Queue
  sl.registerLazySingleton<SyncQueue>(() => SyncQueue.instance);

  // Offline Manager (orchestrates everything)
  sl.registerLazySingleton<OfflineManager>(() => OfflineManager.instance);

  // Initialize the offline manager (initializes Hive and connectivity)
  await sl<OfflineManager>().init();

  // Connectivity Cubit for UI
  sl.registerFactory<ConnectivityCubit>(() => ConnectivityCubit(sl())..init());
}

Future<void> _initAuthFeature() async {
  // BLoC - Factory (new instance each time)
  sl.registerFactory<AuthBloc>(() => AuthBloc(
        loginUser: sl(),
        registerUser: sl(),
        logoutUser: sl(),
        getCurrentUser: sl(),
      ));

  // UseCases - LazySingleton
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl()));
  sl.registerLazySingleton<RegisterUser>(() => RegisterUser(sl()));
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl()));
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl()));

  // Repository - LazySingleton
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
        dioClient: sl(),
      ));

  // DataSources - LazySingleton
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dioClient: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(cacheManager: sl()),
  );
}

Future<void> _initSettingsFeature() async {
  // Cubit - Factory (new instance each time, or LazySingleton if app-wide)
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));
  sl.registerFactory<LocaleCubit>(() => LocaleCubit(sl()));
}
