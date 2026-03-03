import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

// Pages
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/main_navigation/presentation/pages/main_navigation_page.dart';
import '../../features/measurements/presentation/pages/measurements_page.dart';
import '../../features/model_3d/presentation/pages/comparison_page.dart';
import '../../features/model_3d/presentation/pages/model_viewer_page.dart';
import '../../features/model_3d/presentation/pages/morphing_page.dart';
import '../../features/patient/presentation/pages/patient_detail_page.dart';
import '../../features/patient/presentation/pages/patient_form_page.dart';
import '../../features/patient/presentation/pages/patient_list_page.dart';
import '../../features/photo_capture/presentation/pages/photo_capture_page.dart';
import '../../features/photo_capture/presentation/pages/photo_gallery_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/surgery_case/presentation/pages/surgery_case_detail_page.dart';
import '../../features/surgery_case/presentation/pages/surgery_case_form_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        // Auth
        AutoRoute(page: LoginRoute.page, initial: true),
        AutoRoute(page: RegisterRoute.page),

        // Main App with Bottom Navigation (3 tabs)
        AutoRoute(
          page: MainNavigationRoute.page,
          children: [
            AutoRoute(page: DashboardRoute.page, initial: true),
            AutoRoute(page: PatientListRoute.page),
            AutoRoute(page: SettingsRoute.page),
          ],
        ),

        // Patient routes (pushed on top of navigation)
        AutoRoute(page: PatientDetailRoute.page, path: '/patient/:id'),
        AutoRoute(page: PatientFormRoute.page, path: '/patient/form'),

        // Surgery case routes
        AutoRoute(
          page: SurgeryCaseDetailRoute.page,
          path: '/case/:id',
        ),
        AutoRoute(
          page: SurgeryCaseFormRoute.page,
          path: '/patient/:patientId/case/new',
        ),

        // Photo capture routes
        AutoRoute(
          page: PhotoCaptureRoute.page,
          path: '/case/:caseId/capture',
        ),
        AutoRoute(
          page: PhotoGalleryRoute.page,
          path: '/case/:caseId/photos',
        ),

        // 3D Model routes
        AutoRoute(
          page: ModelViewerRoute.page,
          path: '/case/:caseId/model',
        ),
        AutoRoute(page: MorphingRoute.page),
        AutoRoute(page: ComparisonRoute.page),

        // Measurement routes
        AutoRoute(
          page: MeasurementsRoute.page,
          path: '/case/:caseId/measurements',
        ),
      ];

  @override
  List<AutoRouteGuard> get guards => [];
}
