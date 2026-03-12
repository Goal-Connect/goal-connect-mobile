import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/features/onboarding/data/models/onboarding_model.dart';
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

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const FancyBackground(),

          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _flagBit(const Color(0xFF009C3B)),
                _flagBit(AppColors.accentGold),
                _flagBit(const Color(0xFFDA291C)),
              ],
            ),
          ),

          BlocListener<OnboardingBloc, OnboardingState>(
            listener: (context, state) {
              if (state is OnboardingCompleted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const MainPage()),
                );
              }
            },
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardingPages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) =>
                        _buildSlide(onboardingPages[index]),
                  ),
                ),
                _buildBottomControls(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _flagBit(Color c) => Container(
    width: 40,
    height: 4,
    color: c,
    margin: const EdgeInsets.symmetric(horizontal: 2),
  );

  Widget _buildSlide(OnboardingModel page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Lottie.asset(
            page.animationPath,

            errorBuilder: (context, error, stackTrace) =>
                Center(child: Text("⚽", style: TextStyle(fontSize: 100))),
          ),
        ),

        const SizedBox(height: 20),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: page.title,
              style: const TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
              children: [
                TextSpan(
                  text: page.highlightText,
                  style: const TextStyle(color: AppColors.accentGold),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 25),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  border: Border.all(color: Colors.white10),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  page.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(30, 0, 30, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              onboardingPages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 6,
                width: _currentPage == index ? 32 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primaryGreen
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    if (_currentPage == index)
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.4),
                        blurRadius: 10,
                      ),
                  ],
                ),
              ),
            ),
          ),

          GestureDetector(
            onTap: () {
              if (_currentPage < onboardingPages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutQuart,
                );
              } else {
                context.read<OnboardingBloc>().add(MarkOnboardingShown());
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Text(
                    _currentPage == onboardingPages.length - 1
                        ? "GET STARTED"
                        : "NEXT",
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
