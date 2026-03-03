import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/routes/app_router.dart';
import 'core/cache/cache_manager.dart';
import 'core/database/hive_manager.dart';
import 'core/localization/localization_manager.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/network/dio_client.dart';
import 'core/network/fal_ai_client.dart';
import 'core/offline/connectivity_cubit.dart';
import 'core/offline/connectivity_service.dart';
import 'core/offline/offline_manager.dart';
import 'core/offline/sync_queue.dart';
import 'core/supabase/supabase_client_manager.dart';
// Features - Auth
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/supabase_auth_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
// Features - Patient
import 'features/patient/data/datasources/patient_local_datasource.dart';
import 'features/patient/data/datasources/patient_remote_datasource.dart';
import 'features/patient/data/repositories/patient_repository_impl.dart';
import 'features/patient/domain/repositories/patient_repository.dart';
import 'features/patient/domain/usecases/create_patient.dart';
import 'features/patient/domain/usecases/get_patients.dart';
import 'features/patient/domain/usecases/search_patients.dart';
import 'features/patient/domain/usecases/update_patient.dart';
import 'features/patient/presentation/bloc/patient_list_bloc.dart';
// Features - Surgery Case
import 'features/surgery_case/data/datasources/surgery_case_remote_datasource.dart';
import 'features/surgery_case/data/repositories/surgery_case_repository_impl.dart';
import 'features/surgery_case/domain/repositories/surgery_case_repository.dart';
import 'features/surgery_case/domain/usecases/create_surgery_case.dart';
import 'features/surgery_case/domain/usecases/get_surgery_cases.dart';
import 'features/surgery_case/domain/usecases/update_surgery_case.dart';
import 'features/surgery_case/presentation/bloc/surgery_case_bloc.dart';
// Features - Photo Capture
import 'features/photo_capture/data/datasources/photo_remote_datasource.dart';
import 'features/photo_capture/data/services/face_mesh_service.dart';
import 'features/photo_capture/data/services/image_processing_service.dart';
import 'features/photo_capture/presentation/bloc/photo_capture_bloc.dart';
// Features - Model 3D
import 'features/model_3d/data/datasources/fal_ai_datasource.dart';
import 'features/model_3d/data/datasources/model_3d_remote_datasource.dart';
import 'features/model_3d/presentation/bloc/model_viewer_bloc.dart';
import 'features/model_3d/presentation/bloc/morphing_bloc.dart';
// Features - Measurements
import 'features/measurements/data/datasources/measurement_remote_datasource.dart';
import 'features/measurements/presentation/bloc/measurement_bloc.dart';
// Features - Report
import 'features/report/data/services/pdf_report_service.dart';
// Features - Settings
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

  // Supabase
  sl.registerLazySingleton<SupabaseClientManager>(
    () => SupabaseClientManager.instance,
  );
  sl.registerLazySingleton<SupabaseClient>(
    () => SupabaseClientManager.instance.client,
  );

  //==============================
  // OFFLINE-FIRST
  //==============================
  await _initOfflineFirst();

  //==============================
  // FEATURES
  //==============================
  await _initAuthFeature();
  await _initPatientFeature();
  await _initSurgeryCaseFeature();
  _initPhotoCaptureFeature();
  _initModel3DFeature();
  _initMeasurementsFeature();
  _initReportFeature();
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
  // BLoC
  sl.registerFactory<AuthBloc>(() => AuthBloc(
        loginUser: sl(),
        registerUser: sl(),
        logoutUser: sl(),
        getCurrentUser: sl(),
      ));

  // UseCases
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl()));
  sl.registerLazySingleton<RegisterUser>(() => RegisterUser(sl()));
  sl.registerLazySingleton<LogoutUser>(() => LogoutUser(sl()));
  sl.registerLazySingleton<GetCurrentUser>(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));

  // DataSources - Supabase implementation
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => SupabaseAuthDataSource(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(cacheManager: sl()),
  );
}

Future<void> _initPatientFeature() async {
  // BLoC
  sl.registerFactory<PatientListBloc>(() => PatientListBloc(
        getPatients: sl(),
        createPatient: sl(),
        updatePatient: sl(),
        searchPatients: sl(),
      ));

  // UseCases
  sl.registerLazySingleton<GetPatients>(() => GetPatients(sl()));
  sl.registerLazySingleton<CreatePatient>(() => CreatePatient(sl()));
  sl.registerLazySingleton<UpdatePatient>(() => UpdatePatient(sl()));
  sl.registerLazySingleton<SearchPatients>(() => SearchPatients(sl()));

  // Repository
  sl.registerLazySingleton<PatientRepository>(() => PatientRepositoryImpl(
        remoteDataSource: sl(),
        localDataSource: sl(),
      ));

  // DataSources
  sl.registerLazySingleton<PatientRemoteDataSource>(
    () => PatientRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PatientLocalDataSource>(
    () => PatientLocalDataSourceImpl(hiveManager: sl()),
  );
}

Future<void> _initSurgeryCaseFeature() async {
  // BLoC
  sl.registerFactory<SurgeryCaseBloc>(() => SurgeryCaseBloc(
        getSurgeryCases: sl(),
        createSurgeryCase: sl(),
        updateSurgeryCase: sl(),
      ));

  // UseCases
  sl.registerLazySingleton<GetSurgeryCases>(() => GetSurgeryCases(sl()));
  sl.registerLazySingleton<CreateSurgeryCase>(() => CreateSurgeryCase(sl()));
  sl.registerLazySingleton<UpdateSurgeryCase>(() => UpdateSurgeryCase(sl()));

  // Repository
  sl.registerLazySingleton<SurgeryCaseRepository>(
    () => SurgeryCaseRepositoryImpl(remoteDataSource: sl()),
  );

  // DataSources
  sl.registerLazySingleton<SurgeryCaseRemoteDataSource>(
    () => SurgeryCaseRemoteDataSourceImpl(client: sl()),
  );
}

void _initPhotoCaptureFeature() {
  // BLoC
  sl.registerFactory<PhotoCaptureBloc>(() => PhotoCaptureBloc(
        remoteDataSource: sl(),
        imageProcessingService: sl(),
        faceMeshService: sl(),
      ));

  // Services — registerFactory for FaceMeshService because BLoC.close()
  // disposes the detector; each BLoC instance needs its own service instance.
  sl.registerFactory<FaceMeshService>(() => FaceMeshService());
  sl.registerLazySingleton<ImageProcessingService>(
    () => ImageProcessingService(),
  );

  // DataSources
  sl.registerLazySingleton<PhotoRemoteDataSource>(
    () => PhotoRemoteDataSourceImpl(client: sl()),
  );
}

void _initModel3DFeature() {
  // BLoCs
  sl.registerFactory<ModelViewerBloc>(() => ModelViewerBloc(
        remoteDataSource: sl(),
        falAiDataSource: sl(),
      ));
  sl.registerFactory<MorphingBloc>(() => MorphingBloc(
        remoteDataSource: sl(),
      ));

  // Core service
  sl.registerLazySingleton<FalAiClient>(() => FalAiClient());

  // DataSources
  sl.registerLazySingleton<FalAiDataSource>(
    () => FalAiDataSource(falAiClient: sl()),
  );
  sl.registerLazySingleton<Model3DRemoteDataSource>(
    () => Model3DRemoteDataSourceImpl(client: sl()),
  );
}

void _initMeasurementsFeature() {
  // BLoC
  sl.registerFactory<MeasurementBloc>(() => MeasurementBloc(
        remoteDataSource: sl(),
      ));

  // DataSources
  sl.registerLazySingleton<MeasurementRemoteDataSource>(
    () => MeasurementRemoteDataSourceImpl(client: sl()),
  );
}

void _initReportFeature() {
  sl.registerLazySingleton<PdfReportService>(() => PdfReportService());
}

Future<void> _initSettingsFeature() async {
  sl.registerFactory<ThemeCubit>(() => ThemeCubit(sl()));
  sl.registerFactory<LocaleCubit>(() => LocaleCubit(sl()));
}
