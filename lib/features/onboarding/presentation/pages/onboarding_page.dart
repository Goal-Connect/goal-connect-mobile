import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/features/onboarding/data/models/onboarding_model.dart';
import 'package:goal_connect/generated/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:goal_connect/app.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import '../bloc/onboarding_bloc.dart';
import '../bloc/onboarding_event.dart';
import '../bloc/onboarding_state.dart';
import '../widgets/fancy_background.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  double _pageOffset = 0;

  late final AnimationController _glowController;

  static const List<Color> _accents = [
    AppColors.primaryGreen,
    AppColors.accentGold,
    Color(0xFFFF5C5C),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageScroll);
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  void _onPageScroll() {
    if (!mounted) return;
    setState(() {
      _pageOffset = _pageController.page ?? _currentPage.toDouble();
    });
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  Color _accentForOffset(double offset) {
    final clamped = offset.clamp(0, _accents.length - 1).toDouble();
    final lower = clamped.floor();
    final upper = (lower + 1).clamp(0, _accents.length - 1).toInt();
    final t = clamped - lower;
    return Color.lerp(_accents[lower], _accents[upper], t) ?? _accents[lower];
  }

  @override
  Widget build(BuildContext context) {
    final pages = onboardingPagesFor(AppLocalizations.of(context));
    final accent = _accentForOffset(_pageOffset);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const FancyBackground(),
          _AccentHalo(accent: accent, animation: _glowController),
          BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingCompleted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainPage()),
                );
              }
            },
            child: SafeArea(
              child: Column(
                children: [
                  _buildTopBar(pages, accent),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: pages.length,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemBuilder: (context, index) =>
                          _buildSlide(pages[index], index, accent),
                    ),
                  ),
                  _buildBottomControls(context, pages, accent),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(List<OnboardingModel> pages, Color accent) {
    final l = AppLocalizations.of(context);
    final isLast = _currentPage == pages.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) =>
                FadeTransition(opacity: anim, child: child),
            child: isLast
                ? const SizedBox(key: ValueKey('empty-skip'), width: 64)
                : TextButton(
                    key: const ValueKey('skip'),
                    onPressed: () => _pageController.animateToPage(
                      pages.length - 1,
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      l.commonSkip,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: accent.withOpacity(0.35)),
            ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_currentPage + 1}'.padLeft(2, '0'),
                    style: TextStyle(
                      color: accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: ' / ${pages.length.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingModel page, int index, Color accent) {
    final relative = _pageOffset - index;
    final fade = (1 - relative.abs()).clamp(0.0, 1.0);
    final titleTranslate = relative * 28;
    final descTranslate = relative * 60;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 2),
          if (page.animationPath.isNotEmpty)
            _ArtworkStage(
              accent: accent,
              animationPath: page.animationPath,
              parallax: relative,
            )
          else
            _BadgeArtwork(accent: accent, parallax: relative),
          const SizedBox(height: 36),
          Opacity(
            opacity: fade,
            child: Transform.translate(
              offset: Offset(-titleTranslate, 0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: page.title,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.6,
                    height: 1.1,
                  ),
                  children: [
                    TextSpan(
                      text: page.highlightText,
                      style: TextStyle(
                        color: accent,
                        shadows: [
                          Shadow(
                            color: accent.withOpacity(0.5),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Opacity(
            opacity: fade,
            child: Transform.translate(
              offset: Offset(descTranslate, 0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                      ),
                    ),
                    child: Text(
                      page.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildBottomControls(
    BuildContext context,
    List<OnboardingModel> pages,
    Color accent,
  ) {
    final l = AppLocalizations.of(context);
    final isLast = _currentPage == pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Column(
        children: [
          _PageIndicator(
            count: pages.length,
            offset: _pageOffset,
            accent: accent,
          ),
          const SizedBox(height: 22),
          _CtaButton(
            accent: accent,
            label: isLast ? l.commonGetStarted : l.commonNext,
            onTap: () {
              if (!isLast) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              } else {
                context.read<OnboardingBloc>().add(MarkOnboardingShown());
              }
            },
          ),
        ],
      ),
    );
  }
}

class _AccentHalo extends StatelessWidget {
  final Color accent;
  final Animation<double> animation;
  const _AccentHalo({required this.accent, required this.animation});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            final t = animation.value;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -0.4 - t * 0.05),
                  radius: 0.95 + t * 0.05,
                  colors: [
                    accent.withOpacity(0.30 + t * 0.05),
                    accent.withOpacity(0.10),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ArtworkStage extends StatelessWidget {
  final Color accent;
  final String animationPath;
  final double parallax;
  const _ArtworkStage({
    required this.accent,
    required this.animationPath,
    required this.parallax,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.7;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  accent.withOpacity(0.22),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withOpacity(0.35),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withOpacity(0.25),
                  blurRadius: 30,
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: Offset(parallax * -18, 0),
            child: Lottie.asset(
              animationPath,
              width: size * 0.7,
              height: size * 0.7,
              fit: BoxFit.contain,
              errorBuilder: (context, error, _) => Text(
                '⚽',
                style: TextStyle(fontSize: size * 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeArtwork extends StatelessWidget {
  final Color accent;
  final double parallax;
  const _BadgeArtwork({required this.accent, required this.parallax});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width * 0.55;
    return Transform.translate(
      offset: Offset(parallax * -14, 0),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              accent.withOpacity(0.35),
              accent.withOpacity(0.08),
              Colors.transparent,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.45),
              blurRadius: 40,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.sports_soccer_rounded,
            size: size * 0.55,
            color: Colors.white,
            shadows: [
              Shadow(color: accent.withOpacity(0.6), blurRadius: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int count;
  final double offset;
  final Color accent;
  const _PageIndicator({
    required this.count,
    required this.offset,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final distance = (offset - i).abs().clamp(0.0, 1.0);
        final width = 8 + (1 - distance) * 28;
        final color = Color.lerp(
          Colors.white24,
          accent,
          1 - distance,
        )!;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            height: 6,
            width: width,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              boxShadow: distance < 0.5
                  ? [
                      BoxShadow(
                        color: accent.withOpacity(0.5 * (1 - distance)),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}

class _CtaButton extends StatefulWidget {
  final Color accent;
  final String label;
  final VoidCallback onTap;
  const _CtaButton({
    required this.accent,
    required this.label,
    required this.onTap,
  });

  @override
  State<_CtaButton> createState() => _CtaButtonState();
}

class _CtaButtonState extends State<_CtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          width: double.infinity,
          height: 58,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.accent,
                Color.lerp(widget.accent, Colors.white, 0.25) ?? widget.accent,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: widget.accent.withOpacity(0.45),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: const SizedBox(),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.label,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.15),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.black,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
