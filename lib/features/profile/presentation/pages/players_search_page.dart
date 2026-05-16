import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/player_profile.dart';
import '../bloc/player_search_bloc.dart';
import '../bloc/player_search_event.dart';
import '../bloc/player_search_state.dart';
import 'player_profile_page.dart';

/// Discover tab: horizontal player strip + search via `GET /api/players`.
class PlayersSearchPage extends StatefulWidget {
  const PlayersSearchPage({super.key});

  @override
  State<PlayersSearchPage> createState() => _PlayersSearchPageState();
}

class _PlayersSearchPageState extends State<PlayersSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final off = _scrollController.offset;
    if (max > 0 && off > max - 280) {
      context.read<PlayerSearchBloc>().add(const PlayerSearchLoadMore());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<PlayerSearchBloc>().add(PlayerSearchQuerySubmitted(value));
    });
  }

  Future<void> _openFilters(BuildContext context) async {
    final bloc = context.read<PlayerSearchBloc>();
    final current = bloc.state.filters;
    final result = await showModalBottomSheet<PlayerSearchFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(initial: current),
    );
    if (result == null) return;
    if (!result.isActive) {
      bloc.add(const PlayerSearchFiltersCleared());
    } else {
      bloc.add(PlayerSearchFiltersApplied(
        position: result.position,
        strongFoot: result.strongFoot,
        minAge: result.minAge,
        maxAge: result.maxAge,
        minHeight: result.minHeight,
        maxHeight: result.maxHeight,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A12) : AppColors.lightBg;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: BlocConsumer<PlayerSearchBloc, PlayerSearchState>(
          listenWhen: (p, c) =>
              c.errorMessage != null && c.errorMessage != p.errorMessage,
          listener: (context, state) {
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.errorMessage!)),
              );
            }
          },
          builder: (context, state) {
            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Text(
                      'Search',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.lightText,
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSearchField(context, isDark, state),
                ),
                if (state.filters.isActive)
                  SliverToBoxAdapter(
                    child: _ActiveFiltersBar(filters: state.filters),
                  ),
                SliverToBoxAdapter(
                  child: _buildFeaturedSection(context, state, isDark),
                ),
                if (state.loadingFeatured && state.featuredPlayers.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primaryGreen),
                    ),
                  )
                else if (state.featuredPlayers.isEmpty && !state.loadingFeatured)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        'No players to show yet.',
                        style:
                            TextStyle(color: AppColors.gray.withOpacity(0.8)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (state.hasActiveQueryOrFilters) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                      child: Row(
                        children: [
                          Text(
                            'Results',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : AppColors.lightText,
                            ),
                          ),
                          if (state.loadingSearch) ...[
                            const SizedBox(width: 12),
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (state.loadingSearch && state.searchResults.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.primaryGreen),
                      ),
                    )
                  else if (!state.loadingSearch && state.searchResults.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          state.query.isNotEmpty
                              ? 'No players match "${state.query}".'
                              : 'No players match the selected filters.',
                          style: TextStyle(
                              color: AppColors.gray.withOpacity(0.85)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index >= state.searchResults.length) {
                            if (state.loadingMore) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primaryGreen,
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox(height: 24);
                          }
                          final p = state.searchResults[index];
                          return _PlayerResultTile(
                            profile: p,
                            onTap: () => _openProfile(context, p.id),
                          );
                        },
                        childCount: state.searchResults.length +
                            (state.hasMoreSearch || state.loadingMore ? 1 : 0),
                      ),
                    ),
                ] else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Text(
                        'Search by name or use filters to find players.',
                        style: TextStyle(
                          color: AppColors.gray.withOpacity(0.75),
                          fontSize: 14,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    bool isDark,
    PlayerSearchState state,
  ) {
    final activeCount = state.filters.activeCount;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                return TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightText),
                  decoration: InputDecoration(
                    hintText: 'Search players…',
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppColors.primaryGreen),
                    filled: true,
                    fillColor: isDark
                        ? Colors.white.withOpacity(0.06)
                        : Colors.black.withOpacity(0.04),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: value.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              _onSearchChanged('');
                            },
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          _FilterButton(
            activeCount: activeCount,
            onTap: () => _openFilters(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(
    BuildContext context,
    PlayerSearchState state,
    bool isDark,
  ) {
    if (state.featuredPlayers.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
          child: Text(
            'Players',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: isDark ? Colors.white : AppColors.lightText,
            ),
          ),
        ),
        SizedBox(
          height: 118,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.featuredPlayers.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final p = state.featuredPlayers[index];
              return _FeaturedAvatar(
                profile: p,
                onTap: () => _openProfile(context, p.id),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openProfile(BuildContext context, String playerId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlayerProfilePage(playerId: playerId),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;
  final bool isDark;

  const _FilterButton({
    required this.activeCount,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 52,
          width: 52,
          decoration: BoxDecoration(
            color: activeCount > 0
                ? AppColors.primaryGreen.withOpacity(0.15)
                : (isDark
                    ? Colors.white.withOpacity(0.06)
                    : Colors.black.withOpacity(0.04)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: activeCount > 0
                  ? AppColors.primaryGreen.withOpacity(0.6)
                  : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Icon(
                Icons.tune_rounded,
                color: AppColors.primaryGreen,
              ),
              if (activeCount > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$activeCount',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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
}

class _ActiveFiltersBar extends StatelessWidget {
  final PlayerSearchFilters filters;
  const _ActiveFiltersBar({required this.filters});

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[];

    void add(String label) {
      chips.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: AppColors.primaryGreen.withOpacity(0.4), width: 1),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.primaryGreen,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ));
    }

    if (filters.position != null && filters.position!.isNotEmpty) {
      add(filters.position!);
    }
    if (filters.strongFoot != null && filters.strongFoot!.isNotEmpty) {
      add('${filters.strongFoot!} foot');
    }
    if (filters.minAge != null || filters.maxAge != null) {
      final lo = filters.minAge?.toString() ?? '–';
      final hi = filters.maxAge?.toString() ?? '–';
      add('Age $lo–$hi');
    }
    if (filters.minHeight != null || filters.maxHeight != null) {
      final lo = filters.minHeight?.toString() ?? '–';
      final hi = filters.maxHeight?.toString() ?? '–';
      add('Height $lo–$hi cm');
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final c in chips) ...[
                    c,
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
          ),
          TextButton(
            onPressed: () => context
                .read<PlayerSearchBloc>()
                .add(const PlayerSearchFiltersCleared()),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'Clear',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final PlayerSearchFilters initial;
  const _FiltersSheet({required this.initial});

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  static const _positions = [
    'Goalkeeper',
    'Defender',
    'Midfielder',
    'Forward',
  ];
  static const _feet = ['Left', 'Right', 'Both'];

  String? _position;
  String? _strongFoot;
  final TextEditingController _minAge = TextEditingController();
  final TextEditingController _maxAge = TextEditingController();
  final TextEditingController _minHeight = TextEditingController();
  final TextEditingController _maxHeight = TextEditingController();

  @override
  void initState() {
    super.initState();
    _position = widget.initial.position;
    _strongFoot = widget.initial.strongFoot;
    _minAge.text = widget.initial.minAge?.toString() ?? '';
    _maxAge.text = widget.initial.maxAge?.toString() ?? '';
    _minHeight.text = widget.initial.minHeight?.toString() ?? '';
    _maxHeight.text = widget.initial.maxHeight?.toString() ?? '';
  }

  @override
  void dispose() {
    _minAge.dispose();
    _maxAge.dispose();
    _minHeight.dispose();
    _maxHeight.dispose();
    super.dispose();
  }

  int? _parseInt(TextEditingController c) {
    final t = c.text.trim();
    if (t.isEmpty) return null;
    return int.tryParse(t);
  }

  void _apply() {
    final result = PlayerSearchFilters(
      position: _position,
      strongFoot: _strongFoot,
      minAge: _parseInt(_minAge),
      maxAge: _parseInt(_maxAge),
      minHeight: _parseInt(_minHeight),
      maxHeight: _parseInt(_maxHeight),
    );
    Navigator.of(context).pop(result);
  }

  void _reset() {
    setState(() {
      _position = null;
      _strongFoot = null;
      _minAge.clear();
      _maxAge.clear();
      _minHeight.clear();
      _maxHeight.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF14141C) : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.lightText;

    return Padding(
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
                Row(
                  children: [
                    Text(
                      'Filter players',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: _reset,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryGreen,
                      ),
                      child: const Text(
                        'Reset',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _SectionLabel('Position', textColor: textColor),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final p in _positions)
                      _ChoiceChip(
                        label: p,
                        selected: _position == p,
                        onTap: () => setState(
                            () => _position = _position == p ? null : p),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionLabel('Strong foot', textColor: textColor),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final f in _feet)
                      _ChoiceChip(
                        label: f,
                        selected: _strongFoot == f,
                        onTap: () => setState(
                            () => _strongFoot = _strongFoot == f ? null : f),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                _SectionLabel('Age', textColor: textColor),
                const SizedBox(height: 8),
                _NumberRangeField(
                  minController: _minAge,
                  maxController: _maxAge,
                  minHint: 'Min',
                  maxHint: 'Max',
                  isDark: isDark,
                ),
                const SizedBox(height: 18),
                _SectionLabel('Height (cm)', textColor: textColor),
                const SizedBox(height: 8),
                _NumberRangeField(
                  minController: _minHeight,
                  maxController: _maxHeight,
                  minHint: 'Min',
                  maxHint: 'Max',
                  isDark: isDark,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _apply,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Apply filters',
                      style: TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textColor;
  const _SectionLabel(this.label, {required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: textColor,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryGreen
              : (isDark
                  ? Colors.white.withOpacity(0.06)
                  : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected
                ? AppColors.primaryGreen
                : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.black
                : (isDark ? Colors.white : AppColors.lightText),
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _NumberRangeField extends StatelessWidget {
  final TextEditingController minController;
  final TextEditingController maxController;
  final String minHint;
  final String maxHint;
  final bool isDark;

  const _NumberRangeField({
    required this.minController,
    required this.maxController,
    required this.minHint,
    required this.maxHint,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _numField(minController, minHint)),
        const SizedBox(width: 12),
        Expanded(child: _numField(maxController, maxHint)),
      ],
    );
  }

  Widget _numField(TextEditingController c, String hint) {
    return TextField(
      controller: c,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: TextStyle(color: isDark ? Colors.white : AppColors.lightText),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.black.withOpacity(0.04),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FeaturedAvatar extends StatelessWidget {
  final PlayerProfile profile;
  final VoidCallback onTap;

  const _FeaturedAvatar({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(profile.profileImage);
    final ok = profile.profileImage.isNotEmpty &&
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.5), width: 2),
              ),
              child: CircleAvatar(
                radius: 34,
                backgroundColor: AppColors.primaryGreen.withOpacity(0.15),
                backgroundImage: ok ? NetworkImage(profile.profileImage) : null,
                child: !ok
                    ? const Icon(Icons.person_rounded,
                        color: AppColors.primaryGreen, size: 32)
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              profile.username,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : AppColors.gray,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              height: 1.15,
            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerResultTile extends StatelessWidget {
  final PlayerProfile profile;
  final VoidCallback onTap;

  const _PlayerResultTile({required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final uri = Uri.tryParse(profile.profileImage);
    final ok = profile.profileImage.isNotEmpty &&
        uri != null &&
        uri.hasScheme &&
        uri.host.isNotEmpty;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.primaryGreen.withOpacity(0.2),
        backgroundImage: ok ? NetworkImage(profile.profileImage) : null,
        child: !ok
            ? const Icon(Icons.person_rounded, color: AppColors.primaryGreen)
            : null,
      ),
      title: Text(
        profile.username,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : AppColors.lightText,
        ),
      ),
      subtitle: Text(
        '${profile.position} · ${profile.age} · ${profile.country}',
        style: TextStyle(color: AppColors.gray.withOpacity(0.9), fontSize: 13),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.gray),
    );
  }
}
