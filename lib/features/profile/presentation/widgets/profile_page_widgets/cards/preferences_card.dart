import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/settings/app_settings_cubit.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/shared/settings_card.dart';
import 'package:wsidappp/features/profile/presentation/widgets/profile_page_widgets/shared/settings_tile.dart';

/// Notifications, theme and language preferences bound to the global
/// [AppSettingsCubit] so changes apply app-wide immediately.
class PreferencesCard extends StatefulWidget {
  const PreferencesCard({super.key});

  @override
  State<PreferencesCard> createState() => _PreferencesCardState();
}

class _PreferencesCardState extends State<PreferencesCard>
    with WidgetsBindingObserver {
  /// Language names are shown in their native script regardless of locale.
  static const Map<String, String> _nativeLanguageNames = <String, String>{
    'en': 'English',
    'ar': 'العربية',
    'it': 'Italiano',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppSettingsCubit>().syncWithSystemPermissions();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      context.read<AppSettingsCubit>().syncWithSystemPermissions();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final AppSettingsCubit settingsCubit = context.read<AppSettingsCubit>();
    final AppSettingsState settings = context.watch<AppSettingsCubit>().state;

    String formatTimeOfDay(int hour, int minute) {
      final int h = hour % 12 == 0 ? 12 : hour % 12;
      final String period = hour >= 12 ? 'PM' : 'AM';
      final String hStr = h.toString().padLeft(2, '0');
      final String mStr = minute.toString().padLeft(2, '0');
      return '$hStr:$mStr $period';
    }

    return SettingsCard(
      title: l10n.preferences,
      children: <Widget>[
        SettingsTile(
          icon: Icons.notifications_outlined,
          title: l10n.pushNotifications,
          subtitle: l10n.notificationsSubtitle,
          onTap: () => settingsCubit
              .toggleNotifications(!settings.notificationsEnabled),
          trailing: Switch(
            value: settings.notificationsEnabled,
            onChanged: settingsCubit.toggleNotifications,
          ),
        ),
        if (settings.notificationsEnabled)
          SettingsTile(
            icon: Icons.access_time_outlined,
            title: l10n.reminderTime,
            subtitle: formatTimeOfDay(
              settings.reminderHour,
              settings.reminderMinute,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.primaryContainer,
                borderRadius: context.radius.full,
              ),
              child: Text(
                formatTimeOfDay(
                  settings.reminderHour,
                  settings.reminderMinute,
                ),
                style: context.txt.labelMedium?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            onTap: () async {
              final TimeOfDay initial = TimeOfDay(
                hour: settings.reminderHour,
                minute: settings.reminderMinute,
              );
              final TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: initial,
              );
              if (picked != null && context.mounted) {
                await settingsCubit.updateReminderTime(
                  picked.hour,
                  picked.minute,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${l10n.reminderTime}: ${formatTimeOfDay(picked.hour, picked.minute)}',
                      ),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        _SelectorTile(
          icon: Icons.palette_outlined,
          title: l10n.theme,
          selector: SegmentedButton<ThemeMode>(
            showSelectedIcon: false,
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto_outlined),
                label: Text(l10n.themeSystem),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text(l10n.themeLight),
              ),
              ButtonSegment<ThemeMode>(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text(l10n.themeDark),
              ),
            ],
            selected: <ThemeMode>{settings.themeMode},
            onSelectionChanged: (Set<ThemeMode> selection) =>
                settingsCubit.setThemeMode(selection.first),
          ),
        ),
        _SelectorTile(
          icon: Icons.translate,
          title: l10n.language,
          selector: SegmentedButton<String>(
            showSelectedIcon: false,
            segments: <ButtonSegment<String>>[
              for (final MapEntry<String, String> entry
                  in _nativeLanguageNames.entries)
                ButtonSegment<String>(
                  value: entry.key,
                  label: Text(entry.value),
                ),
            ],
            selected: <String>{settings.locale.languageCode},
            onSelectionChanged: (Set<String> selection) =>
                settingsCubit.setLanguage(selection.first),
          ),
        ),
      ],
    );
  }
}

class _SelectorTile extends StatelessWidget {
  const _SelectorTile({
    required this.icon,
    required this.title,
    required this.selector,
  });

  final IconData icon;
  final String title;
  final Widget selector;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          SettingsTile(icon: icon, title: title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButtonTheme(
              data: SegmentedButtonThemeData(
                style: SegmentedButton.styleFrom(
                  selectedBackgroundColor: context.colors.primaryContainer,
                  selectedForegroundColor: context.colors.primary,
                  side: BorderSide(color: context.colors.outlineVariant),
                ),
              ),
              child: selector,
            ),
          ),
        ],
      ),
    );
  }
}
