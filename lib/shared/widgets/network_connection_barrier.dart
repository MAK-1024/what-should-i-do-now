import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/di/injection.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/network/network_cubit.dart';
import 'package:wsidappp/shared/widgets/mascot_state_view.dart';
import 'package:wsidappp/shared/widgets/wsid_gradient_background.dart';

/// Full-screen overlay barrier that blocks interaction and displays the
/// offline illustration and retry action when there is no internet connection.
class NetworkConnectionBarrier extends StatelessWidget {
  const NetworkConnectionBarrier({
    super.key,
    required this.child,
    this.cubit,
  });

  final Widget child;
  final NetworkCubit? cubit;

  @override
  Widget build(BuildContext context) {
    final NetworkCubit effectiveCubit = cubit ??
        (context.readOrNull<NetworkCubit>() ??
            (getIt.isRegistered<NetworkCubit>()
                ? getIt<NetworkCubit>()
                : null))!;

    return BlocBuilder<NetworkCubit, NetworkState>(
      bloc: effectiveCubit,
      builder: (BuildContext context, NetworkState state) {
        final bool isOffline = !state.isConnected;

        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            // The underlying app screens
            AbsorbPointer(
              absorbing: isOffline,
              child: child,
            ),

            // Blocking offline view
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isOffline
                  ? PopScope(
                      canPop: false,
                      child: Material(
                        type: MaterialType.transparency,
                        child: WsidGradientBackground(
                          child: SafeArea(
                            child: MascotStateView.offline(
                              key: const ValueKey<String>('network_offline_view'),
                              imagePath: AppAssets.noconnection,
                              title: context.l10n.offlineTitle,
                              subtitle: context.l10n.offlineSubtitle,
                              actionLabel: context.l10n.retry,
                              isActionLoading: state.isChecking,
                              onAction: () => effectiveCubit.checkConnection(),
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey<String>('network_online_view'),
                    ),
            ),
          ],
        );
      },
    );
  }
}

extension _ContextReadOrNull on BuildContext {
  T? readOrNull<T>() {
    try {
      return read<T>();
    } catch (_) {
      return null;
    }
  }
}
