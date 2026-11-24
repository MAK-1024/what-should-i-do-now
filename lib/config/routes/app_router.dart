import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/app/app_shell.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/features/auth/domain/repositories/auth_repository.dart';
import 'package:wsidappp/features/auth/presentation/pages/auth_page.dart';
import 'package:wsidappp/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:wsidappp/features/onboarding/presentation/pages/splash_page.dart';
import 'package:wsidappp/features/categories/presentation/pages/categories_page.dart';
import 'package:wsidappp/features/profile/presentation/pages/profile_page.dart';
import 'package:wsidappp/features/suggestion/presentation/pages/home_suggestion_page.dart';
import 'package:wsidappp/features/tasks/presentation/pages/tasks_page.dart';

/// Bridges a [Stream] to a [ChangeNotifier] for [GoRouter.refreshListenable].
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Application router configuration using [GoRouter] with authentication guards and app shell.
abstract final class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: RouteList.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(
      getIt<AuthRepository>().authStateChanges,
    ),
    redirect: (BuildContext context, GoRouterState state) {
      final bool isAuthenticated =
          getIt<SupabaseClient>().auth.currentSession != null;
      final bool isAuthRoute = state.matchedLocation == RouteList.auth;
      final bool isSplashRoute = state.matchedLocation == RouteList.splash;
      final bool isOnboardingRoute =
          state.matchedLocation == RouteList.onboarding;

      // Allow splash and onboarding to be accessed without auth.
      if (isSplashRoute || isOnboardingRoute) {
        return null;
      }

      if (!isAuthenticated && !isAuthRoute) {
        return RouteList.auth;
      }

      if (isAuthenticated && isAuthRoute) {
        return RouteList.home;
      }

      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: RouteList.splash,
        name: 'splash',
        builder: (BuildContext context, GoRouterState state) =>
            const SplashPage(),
      ),
      GoRoute(
        path: RouteList.onboarding,
        name: 'onboarding',
        builder: (BuildContext context, GoRouterState state) =>
            const OnboardingPage(),
      ),
      GoRoute(
        path: RouteList.auth,
        name: 'auth',
        builder: (BuildContext context, GoRouterState state) =>
            const AuthPage(),
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) =>
            AppShell(child: child),
        routes: <RouteBase>[
          GoRoute(
            path: RouteList.home,
            name: 'home',
            builder: (BuildContext context, GoRouterState state) =>
                const HomeSuggestionPage(),
          ),
          GoRoute(
            path: RouteList.tasks,
            name: 'tasks',
            builder: (BuildContext context, GoRouterState state) =>
                const TasksPage(),
          ),
          GoRoute(
            path: RouteList.categories,
            name: 'categories',
            builder: (BuildContext context, GoRouterState state) =>
                const CategoriesPage(),
          ),
          GoRoute(
            path: RouteList.profile,
            name: 'profile',
            builder: (BuildContext context, GoRouterState state) =>
                const ProfilePage(),
          ),
        ],
      ),
    ],
  );
}

/// Convenience getter for the application's root [GoRouter].
GoRouter get appRouter => AppRouter.router;
