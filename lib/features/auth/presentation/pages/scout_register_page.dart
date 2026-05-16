import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';
import 'package:goal_connect/features/auth/domain/entities/scout_account_registration.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_event.dart';
import 'package:goal_connect/features/auth/presentation/bloc/auth_state.dart';
import 'package:goal_connect/features/auth/presentation/widgets/pending_approval_dialog.dart';
import 'package:image_picker/image_picker.dart';

class ScoutRegisterPage extends StatefulWidget {
  const ScoutRegisterPage({super.key});

  @override
  State<ScoutRegisterPage> createState() => _ScoutRegisterPageState();
}

class _ScoutRegisterPageState extends State<ScoutRegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nationalIdFanNoController = TextEditingController();
  final _phoneController = TextEditingController();
  final _organizationController = TextEditingController();
  final _countryController = TextEditingController(text: 'Ethiopia');
  final _yearsExperienceController = TextEditingController();

  final _picker = ImagePicker();
  String? _licencePhotoPath;
  bool _obscurePassword = true;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  int _currentStep = 0;
  static const int _totalSteps = 3;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nationalIdFanNoController.dispose();
    _phoneController.dispose();
    _organizationController.dispose();
    _countryController.dispose();
    _yearsExperienceController.dispose();
    super.dispose();
  }

  Future<void> _pickLicencePhoto() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (x == null) return;
    setState(() {
      _licencePhotoPath = x.path.isNotEmpty ? x.path : 'web:${x.name}';
    });
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1Key.currentState?.validate() ?? false;
      case 1:
        return _step2Key.currentState?.validate() ?? false;
      case 2:
        return _step3Key.currentState?.validate() ?? false;
      default:
        return false;
    }
  }

  void _next() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentStep == 0) {
      Navigator.of(context).pop();
    } else {
      setState(() => _currentStep--);
    }
  }

  void _submit() {
    int? years;
    final y = _yearsExperienceController.text.trim();
    if (y.isNotEmpty) {
      years = int.tryParse(y);
    }

    context.read<AuthBloc>().add(
          CreateScoutAccountRequested(
            ScoutAccountRegistration(
              fullName: _fullNameController.text.trim(),
              email: _emailController.text.trim(),
              password: _passwordController.text,
              licencePhotoPath: _licencePhotoPath,
              nationalIdFanNo: _nationalIdFanNoController.text.trim(),
              phoneNumber: _phoneController.text.trim(),
              organizationName: _organizationController.text.trim(),
              country: _countryController.text.trim(),
              yearsExperience: years,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A12) : const Color(0xFFF7F8FA),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthPendingApproval) {
            final navigator = Navigator.of(context);
            PendingApprovalDialog.show(
              context,
              email: state.email,
              justRegistered: state.justRegistered,
            ).then((_) => navigator.popUntil((route) => route.isFirst));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.habeshaRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;

          return SafeArea(
            child: Column(
              children: [
                _buildHeader(isDark, l),
                _buildProgressBar(isDark),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: _buildCurrentStep(isDark, l, loading),
                  ),
                ),
                _buildBottomBar(isDark, l, loading),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(bool isDark, AppLocalizations l) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: _back,
            icon: Icon(
              Icons.arrow_back_rounded,
              color: isDark ? Colors.white : AppColors.lightText,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.scoutRegisterAppBarTitle,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  AppLocalizations.of(context).scoutRegisterStepOf(_currentStep + 1, _totalSteps),
                  style: TextStyle(
                    color: AppColors.gray.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(_totalSteps, (i) {
          final isActive = i <= _currentStep;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < _totalSteps - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryGreen
                      : (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: AppColors.primaryGreen.withOpacity(0.4),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ]
                      : null,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStep(
      bool isDark, AppLocalizations l, bool loading) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(isDark, l);
      case 1:
        return _buildStep2(isDark, l, loading);
      case 2:
        return _buildStep3(isDark, l);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1(bool isDark, AppLocalizations l) {
    return Form(
      key: _step1Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeader(
            isDark: isDark,
            icon: Icons.person_outline_rounded,
            title: l.scoutRegisterStep1Title,
            subtitle: l.scoutRegisterStep1Subtitle,
          ),
          const SizedBox(height: 24),
          _PillField(
            controller: _fullNameController,
            label: l.scoutRegisterFullName,
            icon: Icons.badge_outlined,
            isDark: isDark,
            validator: _required(l.scoutRegisterFullName),
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _emailController,
            label: l.scoutRegisterEmail,
            icon: Icons.mail_outline_rounded,
            isDark: isDark,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty) return l.scoutRegisterFieldRequired(l.scoutRegisterEmail);
              if (!v.contains('@')) return l.scoutRegisterEmailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _passwordController,
            label: l.scoutRegisterPassword,
            icon: Icons.lock_outline_rounded,
            isDark: isDark,
            obscure: _obscurePassword,
            suffix: IconButton(
              splashRadius: 20,
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.gray,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.length < 6) {
                return l.scoutRegisterMinChars;
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark, AppLocalizations l, bool loading) {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeader(
            isDark: isDark,
            icon: Icons.verified_user_outlined,
            title: l.scoutRegisterStep2Title,
            subtitle: l.scoutRegisterStep2Subtitle,
          ),
          const SizedBox(height: 24),
          _PillField(
            controller: _nationalIdFanNoController,
            label: l.scoutRegisterNationalId,
            icon: Icons.credit_card_outlined,
            isDark: isDark,
            validator: _required(l.scoutRegisterNationalId),
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _phoneController,
            label: l.scoutRegisterPhone,
            icon: Icons.phone_outlined,
            isDark: isDark,
            keyboardType: TextInputType.phone,
            validator: _required(l.scoutRegisterPhone),
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _countryController,
            label: l.scoutRegisterCountry,
            icon: Icons.public_rounded,
            isDark: isDark,
            validator: _required(l.scoutRegisterCountry),
          ),
          const SizedBox(height: 20),
          Text(
            l.scoutRegisterLicencePhoto,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isDark ? Colors.white70 : AppColors.lightText,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          _LicencePicker(
            isDark: isDark,
            licencePhotoPath: _licencePhotoPath,
            loading: loading,
            onPick: _pickLicencePhoto,
            uploadLabel: l.scoutRegisterUploadLicence,
            changeLabel: l.scoutRegisterChangeLicence,
            selectedLabel: l.scoutRegisterPhotoSelected,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark, AppLocalizations l) {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _stepHeader(
            isDark: isDark,
            icon: Icons.work_outline_rounded,
            title: l.scoutRegisterStep3Title,
            subtitle: l.scoutRegisterStep3Subtitle,
          ),
          const SizedBox(height: 24),
          _PillField(
            controller: _organizationController,
            label: l.scoutRegisterOrganization,
            icon: Icons.apartment_rounded,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _yearsExperienceController,
            label: l.scoutRegisterYearsExperience,
            icon: Icons.timeline_rounded,
            isDark: isDark,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          _SummaryCard(
            isDark: isDark,
            fullName: _fullNameController.text,
            email: _emailController.text,
            phone: _phoneController.text,
            country: _countryController.text,
            hasLicence: _licencePhotoPath != null,
          ),
        ],
      ),
    );
  }

  Widget _stepHeader({
    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: AppColors.primaryGreen, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightText,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: AppColors.gray.withOpacity(0.8),
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
      bool isDark, AppLocalizations l, bool loading) {
    final isLast = _currentStep == _totalSteps - 1;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0A12) : const Color(0xFFF7F8FA),
        border: Border(
          top: BorderSide(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
        ),
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: loading ? null : _back,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: AppColors.gray.withOpacity(0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context).scoutRegisterBack,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.lightText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor:
                      AppColors.primaryGreen.withOpacity(0.5),
                ),
                child: loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.black,
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? l.scoutRegisterSubmit : l.scoutRegisterContinue,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            isLast
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  FormFieldValidator<String> _required(String label) {
    return (v) {
      if (v == null || v.trim().isEmpty) {
        return AppLocalizations.of(context).scoutRegisterFieldRequired(label);
      }
      return null;
    };
  }
}

class _PillField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscure;
  final bool isDark;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final FormFieldValidator<String>? validator;

  const _PillField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.obscure = false,
    this.keyboardType,
    this.suffix,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(
        color: isDark ? Colors.white : AppColors.lightText,
        fontSize: 14,
      ),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: TextStyle(
          color: AppColors.gray.withOpacity(0.7),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: AppColors.gray, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: fill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryGreen,
            width: 1.4,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.habeshaRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.habeshaRed, width: 1.4),
        ),
      ),
    );
  }
}

class _LicencePicker extends StatelessWidget {
  final bool isDark;
  final String? licencePhotoPath;
  final bool loading;
  final VoidCallback onPick;
  final String uploadLabel;
  final String changeLabel;
  final String selectedLabel;

  const _LicencePicker({
    required this.isDark,
    required this.licencePhotoPath,
    required this.loading,
    required this.onPick,
    required this.uploadLabel,
    required this.changeLabel,
    required this.selectedLabel,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = licencePhotoPath != null;
    final isLocalFile = hasPhoto &&
        !kIsWeb &&
        licencePhotoPath!.isNotEmpty &&
        !licencePhotoPath!.startsWith('web:');

    return GestureDetector(
      onTap: loading ? null : onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.black.withOpacity(0.02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto
                ? AppColors.primaryGreen.withOpacity(0.5)
                : AppColors.gray.withOpacity(0.25),
            width: 1.4,
            style: hasPhoto ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: Column(
          children: [
            if (isLocalFile) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(licencePhotoPath!),
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    hasPhoto
                        ? Icons.check_circle_rounded
                        : Icons.cloud_upload_outlined,
                    color: AppColors.primaryGreen,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasPhoto
                        ? (isLocalFile ? changeLabel : selectedLabel)
                        : uploadLabel,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightText,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gray.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final bool isDark;
  final String fullName;
  final String email;
  final String phone;
  final String country;
  final bool hasLicence;

  const _SummaryCard({
    required this.isDark,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.country,
    required this.hasLicence,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.fact_check_outlined,
                color: AppColors.primaryGreen,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).scoutRegisterReview,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightText,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(AppLocalizations.of(context).scoutRegisterReviewName, fullName.isEmpty ? '—' : fullName, isDark),
          _row(AppLocalizations.of(context).scoutRegisterReviewEmail, email.isEmpty ? '—' : email, isDark),
          _row(AppLocalizations.of(context).scoutRegisterReviewPhone, phone.isEmpty ? '—' : phone, isDark),
          _row(AppLocalizations.of(context).scoutRegisterReviewCountry, country.isEmpty ? '—' : country, isDark),
          _row(AppLocalizations.of(context).scoutRegisterReviewLicence,
              hasLicence
                  ? AppLocalizations.of(context).scoutRegisterReviewUploaded
                  : AppLocalizations.of(context).scoutRegisterReviewNotUploaded,
              isDark),
        ],
      ),
    );
  }

  Widget _row(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.gray.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.lightText,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
