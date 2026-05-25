import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/auth/domain/entities/academy.dart';
import 'package:goal_connect/features/auth/domain/entities/player_application.dart';
import 'package:goal_connect/features/auth/presentation/bloc/player_application_bloc.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';
import 'package:goal_connect/injection_container.dart';

/// All position codes accepted by `POST /auth/player-application`.
/// See docs/features/player_application.md §3 (field reference).
const List<String> _kPositions = <String>[
  'GK', 'CB', 'LB', 'RB', 'LWB', 'RWB',
  'CDM', 'CM', 'CAM', 'LM', 'RM',
  'LW', 'RW', 'ST', 'CF',
];

/// "Region · Woreda · Address" with empty pieces dropped.
String _academyLocationLine(Academy a) {
  final parts = <String>[
    if ((a.region ?? '').trim().isNotEmpty) a.region!.trim(),
    if ((a.woreda ?? '').trim().isNotEmpty) 'Woreda ${a.woreda!.trim()}',
    if ((a.address ?? '').trim().isNotEmpty) a.address!.trim(),
  ];
  return parts.join(' · ');
}

class PlayerApplicationPage extends StatelessWidget {
  const PlayerApplicationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayerApplicationBloc>(
      create: (_) => sl<PlayerApplicationBloc>()..add(const AcademiesRequested()),
      child: const _PlayerApplicationView(),
    );
  }
}

class _PlayerApplicationView extends StatefulWidget {
  const _PlayerApplicationView();

  @override
  State<_PlayerApplicationView> createState() => _PlayerApplicationViewState();
}

class _PlayerApplicationViewState extends State<_PlayerApplicationView> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _countryController = TextEditingController(text: 'Ethiopia');
  final _regionController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  String? _primaryPosition;
  String? _secondaryPosition;
  Academy? _selectedAcademy;

  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();
  final _step3Key = GlobalKey<FormState>();
  int _currentStep = 0;
  static const int _totalSteps = 3;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _nationalIdController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _countryController.dispose();
    _regionController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _step1Key.currentState?.validate() ?? false;
      case 1:
        return _step2Key.currentState?.validate() ?? false;
      case 2:
        final ok = _step3Key.currentState?.validate() ?? false;
        if (!ok) return false;
        if (_primaryPosition == null) {
          _snack(AppLocalizations.of(context).playerAppErrorPickPrimary);
          return false;
        }
        if (_selectedAcademy == null) {
          _snack(AppLocalizations.of(context).playerAppErrorPickAcademy);
          return false;
        }
        if (_secondaryPosition != null &&
            _secondaryPosition == _primaryPosition) {
          _snack(AppLocalizations.of(context).playerAppErrorPositionsMustDiffer);
          return false;
        }
        return true;
      default:
        return false;
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.habeshaRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final application = PlayerApplication(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      nationalIdFanNo: _nationalIdController.text.trim(),
      age: age,
      phoneNumber: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      country: _countryController.text.trim(),
      region: _regionController.text.trim(),
      primaryPosition: _primaryPosition!,
      secondaryPosition: _secondaryPosition,
      academyId: _selectedAcademy!.id,
      additionalInfo: _additionalInfoController.text.trim().isEmpty
          ? null
          : _additionalInfoController.text.trim(),
    );
    context
        .read<PlayerApplicationBloc>()
        .add(PlayerApplicationSubmitted(application));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0A0A12) : const Color(0xFFF7F8FA),
      body: BlocConsumer<PlayerApplicationBloc, PlayerApplicationState>(
        listener: (context, state) {
          if (state.status == PlayerApplicationStatus.submitted &&
              state.receipt != null) {
            _showSubmittedDialog(state.receipt!.email);
          } else if (state.status == PlayerApplicationStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.habeshaRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final submitting =
              state.status == PlayerApplicationStatus.submitting;
          return SafeArea(
            child: Column(
              children: [
                _Header(isDark: isDark, l: l, step: _currentStep + 1, total: _totalSteps, onBack: _back),
                _ProgressBar(isDark: isDark, current: _currentStep, total: _totalSteps),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                    child: _buildCurrentStep(isDark, l, state),
                  ),
                ),
                _BottomBar(
                  isDark: isDark,
                  l: l,
                  submitting: submitting,
                  isLast: _currentStep == _totalSteps - 1,
                  hasBack: _currentStep > 0,
                  onBack: _back,
                  onNext: _next,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentStep(
    bool isDark,
    AppLocalizations l,
    PlayerApplicationState state,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildStep1(isDark, l);
      case 1:
        return _buildStep2(isDark, l);
      case 2:
        return _buildStep3(isDark, l, state);
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
          _StepHeader(
            isDark: isDark,
            icon: Icons.badge_outlined,
            title: l.playerAppStep1Title,
            subtitle: l.playerAppStep1Subtitle,
          ),
          const SizedBox(height: 24),
          _PillField(
            controller: _fullNameController,
            label: l.playerAppFullName,
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            validator: _required(l.playerAppFullName, l),
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _emailController,
            label: l.playerAppEmail,
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            isDark: isDark,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l.playerAppFieldRequired(l.playerAppEmail);
              }
              if (!v.contains('@')) return l.playerAppEmailInvalid;
              return null;
            },
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _nationalIdController,
            label: l.playerAppNationalId,
            icon: Icons.credit_card_outlined,
            isDark: isDark,
            validator: _required(l.playerAppNationalId, l),
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _ageController,
            label: l.playerAppAge,
            icon: Icons.cake_outlined,
            keyboardType: TextInputType.number,
            isDark: isDark,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return l.playerAppFieldRequired(l.playerAppAge);
              }
              final n = int.tryParse(v.trim());
              if (n == null) return l.playerAppAgeInvalid;
              if (n < 10 || n > 60) return l.playerAppAgeOutOfRange;
              return null;
            },
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _phoneController,
            label: l.playerAppPhone,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            isDark: isDark,
            validator: _required(l.playerAppPhone, l),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark, AppLocalizations l) {
    return Form(
      key: _step2Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepHeader(
            isDark: isDark,
            icon: Icons.location_on_outlined,
            title: l.playerAppStep2Title,
            subtitle: l.playerAppStep2Subtitle,
          ),
          const SizedBox(height: 24),
          _PillField(
            controller: _addressController,
            label: l.playerAppAddress,
            icon: Icons.home_outlined,
            isDark: isDark,
            validator: _required(l.playerAppAddress, l),
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _regionController,
            label: l.playerAppRegion,
            icon: Icons.map_outlined,
            isDark: isDark,
            validator: _required(l.playerAppRegion, l),
          ),
          const SizedBox(height: 12),
          _PillField(
            controller: _countryController,
            label: l.playerAppCountry,
            icon: Icons.public_rounded,
            isDark: isDark,
            validator: _required(l.playerAppCountry, l),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3(
    bool isDark,
    AppLocalizations l,
    PlayerApplicationState state,
  ) {
    return Form(
      key: _step3Key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _StepHeader(
            isDark: isDark,
            icon: Icons.sports_soccer_rounded,
            title: l.playerAppStep3Title,
            subtitle: l.playerAppStep3Subtitle,
          ),
          const SizedBox(height: 24),
          _Label(text: l.playerAppPrimaryPosition, isDark: isDark),
          const SizedBox(height: 8),
          _PositionPicker(
            isDark: isDark,
            selected: _primaryPosition,
            onChanged: (v) => setState(() => _primaryPosition = v),
          ),
          const SizedBox(height: 18),
          _Label(text: l.playerAppSecondaryPosition, isDark: isDark),
          const SizedBox(height: 8),
          _PositionPicker(
            isDark: isDark,
            selected: _secondaryPosition,
            allowClear: true,
            onChanged: (v) => setState(() => _secondaryPosition = v),
          ),
          const SizedBox(height: 18),
          _Label(text: l.playerAppAcademy, isDark: isDark),
          const SizedBox(height: 8),
          _AcademyPicker(
            isDark: isDark,
            academies: state.academies,
            loading:
                state.status == PlayerApplicationStatus.loadingAcademies,
            selected: _selectedAcademy,
            onTap: () => _openAcademyPicker(state.academies),
            onRetry: () => context
                .read<PlayerApplicationBloc>()
                .add(const AcademiesRequested()),
            placeholderLabel: l.playerAppAcademyPlaceholder,
            retryLabel: l.playerAppRetry,
            l: l,
          ),
          const SizedBox(height: 18),
          _Label(text: l.playerAppAdditionalInfo, isDark: isDark),
          const SizedBox(height: 8),
          _PillField(
            controller: _additionalInfoController,
            label: l.playerAppAdditionalInfoHint,
            icon: Icons.note_alt_outlined,
            isDark: isDark,
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Future<void> _openAcademyPicker(List<Academy> academies) async {
    final l = AppLocalizations.of(context);
    final selected = await showModalBottomSheet<Academy>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AcademyPickerSheet(
        academies: academies,
        searchHint: l.playerAppAcademySearchHint,
        emptyLabel: l.playerAppAcademyEmpty,
      ),
    );
    if (selected != null) {
      setState(() => _selectedAcademy = selected);
    }
  }

  Future<void> _showSubmittedDialog(String email) async {
    final l = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF14141C) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_rounded,
                  color: AppColors.primaryGreen,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l.playerAppSubmittedTitle,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightText,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l.playerAppSubmittedBody(email),
                style: TextStyle(
                  color: AppColors.gray.withOpacity(0.9),
                  fontSize: 13,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.black,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    l.playerAppSubmittedClose,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  FormFieldValidator<String> _required(String label, AppLocalizations l) {
    return (v) {
      if (v == null || v.trim().isEmpty) {
        return l.playerAppFieldRequired(label);
      }
      return null;
    };
  }
}

// ── Sub-widgets ─────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final int step;
  final int total;
  final VoidCallback onBack;
  const _Header({
    required this.isDark,
    required this.l,
    required this.step,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
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
                  l.playerAppAppBarTitle,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.lightText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  l.playerAppStepOf(step, total),
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
}

class _ProgressBar extends StatelessWidget {
  final bool isDark;
  final int current;
  final int total;
  const _ProgressBar({
    required this.isDark,
    required this.current,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(total, (i) {
          final isActive = i <= current;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primaryGreen
                      : (isDark ? Colors.white : Colors.black)
                          .withOpacity(0.08),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _StepHeader extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final String title;
  final String subtitle;
  const _StepHeader({
    required this.isDark,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
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
}

class _Label extends StatelessWidget {
  final String text;
  final bool isDark;
  const _Label({required this.text, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: isDark ? Colors.white70 : AppColors.lightText,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _PillField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final int? maxLines;

  const _PillField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType,
    this.validator,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      maxLines: maxLines ?? 1,
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
          borderSide:
              const BorderSide(color: AppColors.habeshaRed, width: 1.4),
        ),
      ),
    );
  }
}

class _PositionPicker extends StatelessWidget {
  final bool isDark;
  final String? selected;
  final bool allowClear;
  final ValueChanged<String?> onChanged;
  const _PositionPicker({
    required this.isDark,
    required this.selected,
    required this.onChanged,
    this.allowClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _kPositions.map((pos) {
        final isSel = selected == pos;
        return GestureDetector(
          onTap: () {
            if (isSel && allowClear) {
              onChanged(null);
            } else {
              onChanged(pos);
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSel
                  ? AppColors.primaryGreen
                  : (isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.black.withOpacity(0.04)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSel
                    ? AppColors.primaryGreen
                    : AppColors.gray.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Text(
              pos,
              style: TextStyle(
                color: isSel
                    ? Colors.black
                    : (isDark ? Colors.white : AppColors.lightText),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _AcademyPicker extends StatelessWidget {
  final bool isDark;
  final List<Academy> academies;
  final bool loading;
  final Academy? selected;
  final VoidCallback onTap;
  final VoidCallback onRetry;
  final String placeholderLabel;
  final String retryLabel;
  final AppLocalizations l;

  const _AcademyPicker({
    required this.isDark,
    required this.academies,
    required this.loading,
    required this.selected,
    required this.onTap,
    required this.onRetry,
    required this.placeholderLabel,
    required this.retryLabel,
    required this.l,
  });

  @override
  Widget build(BuildContext context) {
    final fill = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.black.withOpacity(0.03);
    if (loading) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l.playerAppAcademiesLoading,
              style: TextStyle(
                color: AppColors.gray.withOpacity(0.9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }

    if (academies.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline_rounded,
                color: AppColors.gray.withOpacity(0.8), size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                l.playerAppAcademiesEmpty,
                style: TextStyle(
                  color: AppColors.gray.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: Text(
                retryLabel,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected != null
                ? AppColors.primaryGreen.withOpacity(0.5)
                : AppColors.gray.withOpacity(0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected != null
                  ? Icons.school_rounded
                  : Icons.school_outlined,
              color: AppColors.primaryGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selected?.name ?? placeholderLabel,
                    style: TextStyle(
                      color: selected != null
                          ? (isDark ? Colors.white : AppColors.lightText)
                          : AppColors.gray.withOpacity(0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (selected != null &&
                      _academyLocationLine(selected!).isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _academyLocationLine(selected!),
                      style: TextStyle(
                        color: AppColors.gray.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.gray.withOpacity(0.6),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademyLocationLines extends StatelessWidget {
  final Academy academy;
  final bool isDark;
  const _AcademyLocationLines({required this.academy, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final lines = <String>[
      if ((academy.region ?? '').trim().isNotEmpty) academy.region!.trim(),
      if ((academy.woreda ?? '').trim().isNotEmpty)
        'Woreda ${academy.woreda!.trim()}',
      if ((academy.address ?? '').trim().isNotEmpty) academy.address!.trim(),
    ];
    if (lines.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: lines
            .map(
              (t) => Text(
                t,
                style: TextStyle(
                  color: AppColors.gray.withOpacity(0.85),
                  fontSize: 12,
                  height: 1.3,
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _AcademyPickerSheet extends StatefulWidget {
  final List<Academy> academies;
  final String searchHint;
  final String emptyLabel;
  const _AcademyPickerSheet({
    required this.academies,
    required this.searchHint,
    required this.emptyLabel,
  });

  @override
  State<_AcademyPickerSheet> createState() => _AcademyPickerSheetState();
}

class _AcademyPickerSheetState extends State<_AcademyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? widget.academies
        : widget.academies.where((a) {
            return a.name.toLowerCase().contains(q) ||
                (a.region ?? '').toLowerCase().contains(q) ||
                (a.woreda ?? '').toLowerCase().contains(q) ||
                (a.address ?? '').toLowerCase().contains(q);
          }).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF14141C) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightText,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  hintStyle: TextStyle(
                    color: AppColors.gray.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.gray,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.black.withOpacity(0.03),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          widget.emptyLabel,
                          style: TextStyle(
                            color: AppColors.gray.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          height: 1,
                          color: AppColors.gray.withOpacity(0.12),
                        ),
                        itemBuilder: (_, i) {
                          final a = filtered[i];
                          return ListTile(
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.school_rounded,
                                color: AppColors.primaryGreen,
                                size: 18,
                              ),
                            ),
                            title: Text(
                              a.name,
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppColors.lightText,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: _AcademyLocationLines(
                              academy: a,
                              isDark: isDark,
                            ),
                            onTap: () => Navigator.of(context).pop(a),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final bool isDark;
  final AppLocalizations l;
  final bool submitting;
  final bool isLast;
  final bool hasBack;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const _BottomBar({
    required this.isDark,
    required this.l,
    required this.submitting,
    required this.isLast,
    required this.hasBack,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
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
          if (hasBack)
            Expanded(
              child: SizedBox(
                height: 52,
                child: OutlinedButton(
                  onPressed: submitting ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.gray.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    l.playerAppBack,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.lightText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          if (hasBack) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: submitting ? null : onNext,
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
                child: submitting
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
                            isLast ? l.playerAppSubmit : l.playerAppContinue,
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
}
