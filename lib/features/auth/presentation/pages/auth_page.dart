import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wsidappp/config/theme/theme_extensions.dart';
import 'package:wsidappp/core/constants/app_assets.dart';
import 'package:wsidappp/core/l10n/app_localizations.dart';
import 'package:wsidappp/core/utils/app_motion.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:wsidappp/features/auth/presentation/cubit/auth_state.dart';
import 'package:wsidappp/shared/widgets/wsid_button.dart';
import 'package:wsidappp/shared/widgets/wsid_text_field.dart';
import 'package:wsidappp/features/auth/presentation/widgets/auth_page_widgets/shared/auth_mode_switch.dart';

/// Login and register screen aligned with Figma frames `181:379` / `18:5`.
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  bool _isSignUp = false;
  bool _obscurePassword = true;

  static const double _cardMaxWidth = 390;
  static const double _loginMascotHeight = 230;
  static const double _registerMascotHeight = 205;
  static const double _mascotWidth = 224;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<AuthCubit>();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (_isSignUp) {
      cubit.signUp(
        email: email,
        password: password,
        displayName: _nameController.text.trim(),
      );
    } else {
      cubit.signIn(email: email, password: password);
    }
  }

  void _toggleMode(bool isLoading) {
    if (isLoading) return;
    setState(() {
      _isSignUp = !_isSignUp;
      _formKey.currentState?.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final brand = context.brand;

    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              AppAssets.authBackground,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: BlocConsumer<AuthCubit, AuthState>(
              listener: (BuildContext context, AuthState state) {
                state.whenOrNull(
                  error: (String message) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(message),
                        backgroundColor: context.colors.error,
                      ),
                    );
                  },
                );
              },
              builder: (BuildContext context, AuthState state) {
                final bool isLoading = state.maybeWhen(
                  loading: () => true,
                  orElse: () => false,
                );
                final Duration motion = AppMotion.of(context, AppMotion.medium);

                return Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: _cardMaxWidth),
                      child: _AuthFormShell(
                        child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                SizedBox(
                                  width: _mascotWidth,
                                  height: _isSignUp
                                      ? _registerMascotHeight
                                      : _loginMascotHeight,
                                  child: Image.asset(
                                    _isSignUp
                                        ? AppAssets.authRegister
                                        : AppAssets.authLogin,
                                    fit: BoxFit.contain,
                                    filterQuality: FilterQuality.high,
                                  ),
                                )
                                    .animate(key: ValueKey<bool>(_isSignUp))
                                    .fadeIn(
                                      duration: motion,
                                      curve: AppMotion.standard,
                                    ),
                                const SizedBox(height: 32),
                                Text(
                                  _isSignUp
                                      ? l10n.createAccountTitle
                                      : l10n.welcomeBack,
                                  textAlign: TextAlign.center,
                                  style: context.screenTitleStyle,
                                ),
                                Text(
                                  _isSignUp
                                      ? l10n.createAccountSubtitle
                                      : l10n.logInSubtitle,
                                  textAlign: TextAlign.center,
                                  style: context.screenSubtitleStyle,
                                ),
                                const SizedBox(height: 32),
                                if (_isSignUp) ...<Widget>[
                                  WsidTextField(
                                    controller: _nameController,
                                    label: l10n.nameLabel,
                                    hintText: l10n.nameFieldPlaceholder,
                                    prefixIcon: Icons.person_outline,
                                    textInputAction: TextInputAction.next,
                                    validator: (String? value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return l10n.enterDisplayNamePrompt;
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                ],
                                WsidTextField(
                                  controller: _emailController,
                                  label: l10n.emailLabel,
                                  hintText: l10n.emailFieldPlaceholder,
                                  prefixIcon: Icons.person_outline,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (String? value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return l10n.enterEmailPrompt;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: <Widget>[
                                    WsidTextField(
                                      controller: _passwordController,
                                      label: _isSignUp
                                          ? l10n.createPasswordLabel
                                          : l10n.passwordLabel,
                                      hintText: '••••••••',
                                      prefixIcon: Icons.lock_outline,
                                      textInputAction: TextInputAction.done,
                                      obscureText: _obscurePassword,
                                      onToggleObscure: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                      onFieldSubmitted: (_) => _submit(),
                                      validator: (String? value) {
                                        if (value == null || value.length < 6) {
                                          return l10n.passwordTooShort;
                                        }
                                        return null;
                                      },
                                    ),
                                    if (!_isSignUp)
                                      Align(
                                        alignment: AlignmentDirectional.centerEnd,
                                        child: WsidButton(
                                          label: l10n.forgotPassword,
                                          variant: WsidButtonVariant.link,
                                          size: WsidButtonSize.small,
                                          onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                l10n.enterEmailPrompt,
                                              ),
                                            ),
                                          );
                                          },
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                WsidButton(
                                  onPressed: isLoading ? null : _submit,
                                  label: _isSignUp
                                      ? l10n.createAccountButton
                                      : l10n.logInButton,
                                  size: WsidButtonSize.large,
                                  isLoading: isLoading,
                                  isExpanded: true,
                                ),
                                const SizedBox(height: 16),
                                AuthModeSwitch(
                                  prompt: _isSignUp
                                      ? l10n.alreadyHaveAccountLink
                                      : l10n.newHere,
                                  actionLabel: _isSignUp
                                      ? l10n.logInLink
                                      : l10n.createAccountLink,
                                  enabled: !isLoading,
                                  onTap: () => _toggleMode(isLoading),
                                ),
                              ],
                            ),
                          ),
                    ),
                  ),
                ),
              );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthFormShell extends StatelessWidget {
  const _AuthFormShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (context.isLightTheme) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: context.brand.cardFill,
          borderRadius: context.radius.xl,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          child: child,
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
        child: child,
      ),
    );
  }
}