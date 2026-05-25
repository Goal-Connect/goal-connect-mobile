import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../generated/l10n/app_localizations.dart';
import '../../../../injection_container.dart';
import '../../domain/entities/scout_preference.dart';
import '../bloc/scout_preference_bloc.dart';
import '../bloc/scout_preference_event.dart';
import '../bloc/scout_preference_state.dart';

/// Settings page where a scout configures the discovery filters that get
/// applied to `/videos/feed`. All fields are optional — leaving them empty
/// (or clearing the preference) means "show everything I can see".
class ScoutPreferencesPage extends StatelessWidget {
  const ScoutPreferencesPage({super.key});

  static Route<void> route() {
    return MaterialPageRoute(
      builder: (_) => BlocProvider<ScoutPreferenceBloc>(
        create: (_) => sl<ScoutPreferenceBloc>()
          ..add(const ScoutPreferenceLoadRequested()),
        child: const ScoutPreferencesPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _ScoutPreferencesView();
  }
}

class _ScoutPreferencesView extends StatefulWidget {
  const _ScoutPreferencesView();

  @override
  State<_ScoutPreferencesView> createState() => _ScoutPreferencesViewState();
}

class _ScoutPreferencesViewState extends State<_ScoutPreferencesView> {
  static const _positionOptions = <String>[
    'Goalkeeper',
    'Sweeper Keeper',
    'Center Back',
    'Left Center Back',
    'Right Center Back',
    'Full Back',
    'Wing Back',
    'Defensive Midfielder',
    'Central Midfielder',
    'Attacking Midfielder',
    'Wide Midfielder',
    'Winger',
    'Inside Forward',
    'Striker',
    'False 9',
  ];

  final _regionInputController = TextEditingController();
  final _minAgeController = TextEditingController();
  final _maxAgeController = TextEditingController();
  final Set<String> _selectedPositions = <String>{};
  final List<String> _selectedRegions = <String>[];
  bool _hydrated = false;

  @override
  void dispose() {
    _regionInputController.dispose();
    _minAgeController.dispose();
    _maxAgeController.dispose();
    super.dispose();
  }

  void _hydrate(ScoutPreference? pref) {
    if (_hydrated) return;
    _hydrated = true;
    if (pref == null) return;
    _selectedPositions
      ..clear()
      ..addAll(_canonicalizePositions(pref.positions));
    _selectedRegions
      ..clear()
      ..addAll(pref.regions);
    _minAgeController.text = pref.minAge?.toString() ?? '';
    _maxAgeController.text = pref.maxAge?.toString() ?? '';
  }

  /// Match server-returned positions (e.g. "goalkeeper") to our display
  /// options (e.g. "Goalkeeper") case-insensitively. Anything we don't
  /// recognise still passes through verbatim so the user doesn't lose
  /// values they set elsewhere.
  Iterable<String> _canonicalizePositions(List<String> raw) {
    return raw.map((value) {
      final match = _positionOptions.firstWhere(
        (opt) => opt.toLowerCase() == value.toLowerCase(),
        orElse: () => value,
      );
      return match;
    });
  }

  int? _parseAge(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    final parsed = int.tryParse(trimmed);
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  void _togglePosition(String value) {
    setState(() {
      if (_selectedPositions.contains(value)) {
        _selectedPositions.remove(value);
      } else {
        _selectedPositions.add(value);
      }
    });
  }

  void _addRegion() {
    final value = _regionInputController.text.trim();
    if (value.isEmpty) return;
    if (_selectedRegions
        .any((r) => r.toLowerCase() == value.toLowerCase())) {
      _regionInputController.clear();
      return;
    }
    setState(() {
      _selectedRegions.add(value);
      _regionInputController.clear();
    });
  }

  void _removeRegion(String value) {
    setState(() => _selectedRegions.remove(value));
  }

  void _onSave(BuildContext context) {
    final minAge = _parseAge(_minAgeController.text);
    final maxAge = _parseAge(_maxAgeController.text);

    context.read<ScoutPreferenceBloc>().add(
          ScoutPreferenceSaveRequested(
            positions: _selectedPositions.toList(growable: false),
            regions: List<String>.from(_selectedRegions),
            minAge: minAge,
            maxAge: maxAge,
          ),
        );
  }

  void _onClear(BuildContext context) {
    setState(() {
      _selectedPositions.clear();
      _selectedRegions.clear();
      _regionInputController.clear();
      _minAgeController.clear();
      _maxAgeController.clear();
    });
    context
        .read<ScoutPreferenceBloc>()
        .add(const ScoutPreferenceClearRequested());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.lightText;
    final cardColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.03);
    final borderColor =
        (isDark ? Colors.white : Colors.black).withOpacity(0.05);
    final l = AppLocalizations.of(context);

    return BlocConsumer<ScoutPreferenceBloc, ScoutPreferenceState>(
      listener: (context, state) {
        if (state.status == ScoutPreferenceStatus.ready) {
          _hydrate(state.preference);
        }
        if (state.justSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.scoutPreferencesSaved),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        } else if (state.justCleared) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l.scoutPreferencesCleared),
              backgroundColor: AppColors.primaryGreen,
            ),
          );
        } else if (state.status == ScoutPreferenceStatus.error &&
            state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.habeshaRed,
            ),
          );
        }
      },
      builder: (context, state) {
        final saving = state.status == ScoutPreferenceStatus.saving;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.scaffoldBackgroundColor,
            foregroundColor: textColor,
            elevation: 0,
            title: Text(
              l.scoutPreferencesTitle,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.scoutPreferencesSubtitle,
                  style: TextStyle(
                    color: AppColors.gray.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _sectionLabel(l.scoutPreferencesPositions),
                const SizedBox(height: 10),
                _PositionChips(
                  options: _positionOptions,
                  selected: _selectedPositions,
                  isDark: isDark,
                  textColor: textColor,
                  onToggle: _togglePosition,
                ),
                const SizedBox(height: 22),
                _sectionLabel(l.scoutPreferencesRegions),
                const SizedBox(height: 10),
                _RegionEditor(
                  controller: _regionInputController,
                  regions: _selectedRegions,
                  textColor: textColor,
                  isDark: isDark,
                  borderColor: borderColor,
                  cardColor: cardColor,
                  hint: l.scoutPreferencesRegionHint,
                  addLabel: l.scoutPreferencesRegionAdd,
                  onAdd: _addRegion,
                  onRemove: _removeRegion,
                ),
                const SizedBox(height: 22),
                _sectionLabel(l.scoutPreferencesAgeRange),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _OutlinedField(
                        controller: _minAgeController,
                        hint: l.scoutPreferencesAgeMin,
                        textColor: textColor,
                        isDark: isDark,
                        borderColor: borderColor,
                        cardColor: cardColor,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _OutlinedField(
                        controller: _maxAgeController,
                        hint: l.scoutPreferencesAgeMax,
                        textColor: textColor,
                        isDark: isDark,
                        borderColor: borderColor,
                        cardColor: cardColor,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saving ? null : () => _onSave(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      disabledBackgroundColor:
                          AppColors.primaryGreen.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: saving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: Colors.black,
                            ),
                          )
                        : Text(
                            l.scoutPreferencesSave,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                if (state.hasPreference)
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton(
                      onPressed: saving ? null : () => _onClear(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.habeshaRed,
                        side: BorderSide(
                          color: AppColors.habeshaRed.withOpacity(0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        l.scoutPreferencesClear,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.4,
        color: AppColors.primaryGreen,
      ),
    );
  }
}

class _PositionChips extends StatelessWidget {
  final List<String> options;
  final Set<String> selected;
  final bool isDark;
  final Color textColor;
  final ValueChanged<String> onToggle;

  const _PositionChips({
    required this.options,
    required this.selected,
    required this.isDark,
    required this.textColor,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final opt in options)
          _chip(label: opt, isSelected: selected.contains(opt)),
      ],
    );
  }

  Widget _chip({required String label, required bool isSelected}) {
    return GestureDetector(
      onTap: () => onToggle(label),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3DDB85),
                    AppColors.primaryGreen,
                    Color(0xFF1F8F4E),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? Colors.white : Colors.black).withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : (isDark ? Colors.white : Colors.black).withOpacity(0.08),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : textColor.withOpacity(0.75),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _RegionEditor extends StatelessWidget {
  final TextEditingController controller;
  final List<String> regions;
  final Color textColor;
  final bool isDark;
  final Color borderColor;
  final Color cardColor;
  final String hint;
  final String addLabel;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemove;

  const _RegionEditor({
    required this.controller,
    required this.regions,
    required this.textColor,
    required this.isDark,
    required this.borderColor,
    required this.cardColor,
    required this.hint,
    required this.addLabel,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _OutlinedField(
                controller: controller,
                hint: hint,
                textColor: textColor,
                isDark: isDark,
                borderColor: borderColor,
                cardColor: cardColor,
                onSubmitted: (_) => onAdd(),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onAdd,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.black,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                addLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        if (regions.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final r in regions)
                _RegionChip(
                  label: r,
                  textColor: textColor,
                  onRemove: () => onRemove(r),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _RegionChip extends StatelessWidget {
  final String label;
  final Color textColor;
  final VoidCallback onRemove;

  const _RegionChip({
    required this.label,
    required this.textColor,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Icon(
                Icons.close_rounded,
                size: 16,
                color: textColor.withOpacity(0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OutlinedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Color textColor;
  final bool isDark;
  final Color borderColor;
  final Color cardColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;

  const _OutlinedField({
    required this.controller,
    required this.hint,
    required this.textColor,
    required this.isDark,
    required this.borderColor,
    required this.cardColor,
    this.keyboardType,
    this.inputFormatters,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: textColor, fontSize: 14),
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction:
          onSubmitted != null ? TextInputAction.done : TextInputAction.next,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppColors.gray.withOpacity(0.6)),
        filled: true,
        fillColor: cardColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
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
