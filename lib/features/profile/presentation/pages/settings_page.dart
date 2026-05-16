import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/locale/locale_cubit.dart';
import '../../../../core/locale/locale_state.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final cardColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.03);
    final borderColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.05);
    final dividerColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.04);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, isDark, textColor),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _buildAppearanceSection(
                      context, isDark, textColor, cardColor, borderColor, dividerColor),
                  const SizedBox(height: 24),
                  _buildSecuritySection(
                      isDark, textColor, cardColor, borderColor, dividerColor),
                  const SizedBox(height: 24),
                  _buildAccountSection(
                      isDark, textColor, cardColor, borderColor, dividerColor),
                  const SizedBox(height: 28),
                  _buildSignOutButton(isDark),
                  const SizedBox(height: 20),
                  _buildFooter(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, Color textColor) {
    final l = AppLocalizations.of(context);
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: isDark ? const Color(0xFF0A0A12) : Colors.white,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back_rounded,
              color: Colors.white, size: 20),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGreen,
                AppColors.primaryGreen.withOpacity(0.75),
                isDark ? const Color(0xFF0A0A12) : Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                  24, MediaQuery.of(context).padding.top + 48, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(Icons.settings_rounded,
                            color: Colors.black, size: 24),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l.settingsAppVersion,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    l.settingsTitle,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 28,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l.settingsSubtitle,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    bool isDark,
    Color textColor,
    Color cardColor,
    Color borderColor,
    Color dividerColor,
  ) {
    final currentMode = context.watch<ThemeCubit>().state.themeMode;
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l.settingsAppearance),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildThemeSelector(context, currentMode, isDark, textColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeMode currentMode,
    bool isDark,
    Color textColor,
  ) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          _themeChip(
            context: context,
            icon: Icons.light_mode_rounded,
            label: l.settingsThemeLight,
            mode: ThemeMode.light,
            currentMode: currentMode,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(width: 8),
          _themeChip(
            context: context,
            icon: Icons.dark_mode_rounded,
            label: l.settingsThemeDark,
            mode: ThemeMode.dark,
            currentMode: currentMode,
            isDark: isDark,
            textColor: textColor,
          ),
          const SizedBox(width: 8),
          _themeChip(
            context: context,
            icon: Icons.phone_android_rounded,
            label: l.settingsThemeSystem,
            mode: ThemeMode.system,
            currentMode: currentMode,
            isDark: isDark,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _themeChip({
    required BuildContext context,
    required IconData icon,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required bool isDark,
    required Color textColor,
  }) {
    final isSelected = currentMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () => context.read<ThemeCubit>().setTheme(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [AppColors.primaryGreen, Color(0xFF00E896)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected
                ? null
                : (isDark ? Colors.white : Colors.black).withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryGreen.withOpacity(0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.black : AppColors.gray,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.black
                      : textColor.withOpacity(0.6),
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecuritySection(
    bool isDark,
    Color textColor,
    Color cardColor,
    Color borderColor,
    Color dividerColor,
  ) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l.settingsSecurity),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: _buildActionTile(
            icon: Icons.lock_outline_rounded,
            iconColor: AppColors.primaryGreen,
            label: l.settingsUpdatePassword,
            textColor: textColor,
            onTap: () => _openUpdatePasswordSheet(context, isDark, textColor),
          ),
        ),
      ],
    );
  }

  Future<void> _openUpdatePasswordSheet(
    BuildContext context,
    bool isDark,
    Color textColor,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<AuthBloc>(),
        child: _UpdatePasswordSheet(isDark: isDark, textColor: textColor),
      ),
    );
  }

  Widget _buildAccountSection(
    bool isDark,
    Color textColor,
    Color cardColor,
    Color borderColor,
    Color dividerColor,
  ) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(l.settingsAccount),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              BlocBuilder<LocaleCubit, LocaleState>(
                builder: (context, localeState) {
                  return _buildActionTile(
                    icon: Icons.language_rounded,
                    iconColor: const Color(0xFF3B82F6),
                    label: l.settingsLanguage,
                    trailing: _localeLabel(localeState.locale, l),
                    textColor: textColor,
                    onTap: () => _openLanguagePicker(context),
                  );
                },
              ),
              Divider(height: 1, indent: 60, color: dividerColor),
              _buildActionTile(
                icon: Icons.shield_outlined,
                iconColor: AppColors.primaryGreen,
                label: l.settingsPrivacyPolicy,
                textColor: textColor,
                onTap: () {},
              ),
              Divider(height: 1, indent: 60, color: dividerColor),
              _buildActionTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.accentGold,
                label: l.settingsTermsOfService,
                textColor: textColor,
                onTap: () {},
              ),
              Divider(height: 1, indent: 60, color: dividerColor),
              _buildActionTile(
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFF6C63FF),
                label: l.settingsHelpSupport,
                textColor: textColor,
                onTap: () {},
              ),
              Divider(height: 1, indent: 60, color: dividerColor),
              _buildActionTile(
                icon: Icons.info_outline_rounded,
                iconColor: AppColors.gray,
                label: l.settingsAbout,
                trailing: l.settingsAppVersion,
                textColor: textColor,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _localeLabel(Locale? locale, AppLocalizations l) {
    if (locale == null) return l.settingsThemeSystem;
    switch (locale.languageCode) {
      case 'am':
        return l.settingsLanguageAmharic;
      case 'om':
        return 'Afaan Oromoo';
      default:
        return l.settingsLanguageEnglish;
    }
  }

  Future<void> _openLanguagePicker(BuildContext context) async {
    final cubit = context.read<LocaleCubit>();
    final current = cubit.state.locale;
    final selected = await showModalBottomSheet<Locale?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LanguagePickerSheet(current: current),
    );
    if (selected == null) return;
    // Sentinel: a Locale with empty languageCode means "follow system".
    if (selected.languageCode.isEmpty) {
      cubit.setLocale(null);
    } else {
      cubit.setLocale(selected);
    }
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? trailing,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing,
                  style: TextStyle(
                    color: AppColors.gray.withOpacity(0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gray.withOpacity(0.4),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.habeshaRed.withOpacity(0.08),
            AppColors.habeshaRed.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.habeshaRed.withOpacity(0.12),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            context.read<AuthBloc>().add(LogoutRequested());
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.habeshaRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: AppColors.habeshaRed, size: 16),
                ),
                const SizedBox(width: 12),
                Text(
                  AppLocalizations.of(context).settingsSignOut,
                  style: const TextStyle(
                    color: AppColors.habeshaRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                AppColors.primaryGreen.withOpacity(0.4),
                AppColors.primaryGreen.withOpacity(0.2),
              ],
            ).createShader(bounds),
            child: Text(
              AppLocalizations.of(context).settingsBrand,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context).appTagline,
            style: TextStyle(
              color: AppColors.gray.withOpacity(0.4),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String label) {
    return Row(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.primaryGreen.withOpacity(0.1),
          ),
        ),
      ],
    );
  }
}

class _UpdatePasswordSheet extends StatefulWidget {
  final bool isDark;
  final Color textColor;

  const _UpdatePasswordSheet({
    required this.isDark,
    required this.textColor,
  });

  @override
  State<_UpdatePasswordSheet> createState() => _UpdatePasswordSheetState();
}

class _UpdatePasswordSheetState extends State<_UpdatePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _errorMessage = null;
    });
    context.read<AuthBloc>().add(UpdatePasswordRequested(
          currentPassword: _currentController.text,
          newPassword: _newController.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final sheetBg =
        widget.isDark ? const Color(0xFF14141C) : Colors.white;
    final l = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (prev, curr) => _submitting && prev != curr,
      listener: (context, state) {
        if (state is AuthFailure) {
          setState(() {
            _submitting = false;
            _errorMessage = state.message.isNotEmpty
                ? state.message
                : l.updatePasswordFailure;
          });
        } else if (state is AuthAuthenticated) {
          setState(() {
            _submitting = false;
            _errorMessage = null;
          });
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.updatePasswordSuccess),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: sheetBg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: AppColors.gray.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Text(
                      l.updatePasswordTitle,
                      style: TextStyle(
                        color: widget.textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l.updatePasswordSubtitle,
                      style: TextStyle(
                        color: AppColors.gray.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.habeshaRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.habeshaRed.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline_rounded,
                                color: AppColors.habeshaRed, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.habeshaRed,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    _passwordField(
                      controller: _currentController,
                      label: l.updatePasswordCurrent,
                      obscure: _obscureCurrent,
                      onToggle: () => setState(
                          () => _obscureCurrent = !_obscureCurrent),
                      validator: (v) => (v == null || v.isEmpty)
                          ? l.updatePasswordEnterCurrent
                          : null,
                    ),
                    const SizedBox(height: 12),
                    _passwordField(
                      controller: _newController,
                      label: l.updatePasswordNew,
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return l.updatePasswordMinChars;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _passwordField(
                      controller: _confirmController,
                      label: l.updatePasswordConfirm,
                      obscure: _obscureConfirm,
                      onToggle: () => setState(
                          () => _obscureConfirm = !_obscureConfirm),
                      validator: (v) {
                        if (v != _newController.text) {
                          return l.updatePasswordMismatch;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            _submitting ? null : () => _submit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor:
                              AppColors.primaryGreen.withOpacity(0.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.black,
                                ),
                              )
                            : Text(
                                l.updatePasswordTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    required bool obscure,
    required VoidCallback onToggle,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(color: widget.textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: AppColors.gray.withOpacity(0.8)),
        filled: true,
        fillColor: widget.isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        suffixIcon: IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: AppColors.gray,
          ),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _LanguagePickerSheet extends StatelessWidget {
  final Locale? current;
  const _LanguagePickerSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l = AppLocalizations.of(context);
    final sheetBg = isDark ? const Color(0xFF14141C) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.lightText;

    final options = <_LangOption>[
      _LangOption(label: l.settingsThemeSystem, value: null),
      const _LangOption(label: 'English', value: Locale('en')),
      _LangOption(label: l.settingsLanguageAmharic, value: const Locale('am')),
      const _LangOption(label: 'Afaan Oromoo', value: Locale('om')),
    ];

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 6),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 14),
              child: Row(
                children: [
                  Text(
                    l.settingsLanguage,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
            for (final opt in options)
              _LangTile(
                option: opt,
                isSelected: _sameLocale(current, opt.value),
                textColor: textColor,
                onTap: () => Navigator.of(context).pop(
                  opt.value ?? const Locale('system'),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  bool _sameLocale(Locale? a, Locale? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    return a.languageCode == b.languageCode;
  }
}

class _LangOption {
  final String label;
  final Locale? value;
  const _LangOption({required this.label, required this.value});
}

class _LangTile extends StatelessWidget {
  final _LangOption option;
  final bool isSelected;
  final Color textColor;
  final VoidCallback onTap;

  const _LangTile({
    required this.option,
    required this.isSelected,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: isSelected
                        ? FontWeight.w800
                        : FontWeight.w500,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_rounded,
                    color: AppColors.primaryGreen, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
