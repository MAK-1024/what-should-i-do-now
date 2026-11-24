import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:wsidappp/config/routes/route_list.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/core/settings/app_settings_cubit.dart';
import 'package:wsidappp/core/services/notification_service.dart';
import 'package:wsidappp/shared/widgets/notification_permission_dialog.dart';
import 'package:wsidappp/features/onboarding/presentation/widgets/splash_screen.dart';

/// Brand splash aligned with Figma `448:3734`, then routes to onboarding/auth/home.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Future<void> _maybePromptForNotifications() async {
    final NotificationService notifications = getIt<NotificationService>();
    if (!notifications.shouldPromptFirstLaunchPermission()) {
      return;
    }
    if (!mounted) return;
    final bool? allow = await showNotificationPermissionDialog(context);
    if (!mounted) return;
    await notifications.completeFirstLaunchPermissionPrompt(
      userWantsNotifications: allow ?? false,
    );
    if (mounted) {
      await context.read<AppSettingsCubit>().loadSettings();
    }
  }

  Future<void> _navigate() async {
    if (!mounted) return;

    await _maybePromptForNotifications();
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool hasCompletedOnboarding =
        prefs.getBool('has_completed_onboarding') ??
        prefs.getBool('onboarding_complete') ??
        false;

    if (!mounted) return;

    if (!hasCompletedOnboarding) {
      context.go(RouteList.onboarding);
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      context.go(RouteList.home);
    } else {
      context.go(RouteList.auth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onFinished: _navigate,
      finalBackgroundColor: context.brand.splashBackground,
      wordmarkAsset: AppAssets.splashWordmark,
      iconAsset: AppAssets.splashIcon,
    );
  }
}
