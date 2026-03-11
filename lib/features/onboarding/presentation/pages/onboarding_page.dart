import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goal_connect/core/theme/app_colors.dart';
import 'package:goal_connect/features/onboarding/data/models/onboarding_model.dart';
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
      body: Stack(
        children: [
          const FancyBackground(),
          BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) =>
                          setState(() => _currentPage = index),
                      itemCount: onboardingPages.length,
                      itemBuilder: (context, index) =>
                          _buildSlide(onboardingPages[index]),
                    ),
                  ),
                  _buildBottomControls(context),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSlide(OnboardingModel page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) => Transform.scale(
              scale: value,
              child: Container(
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryGreen.withOpacity(0.1),
                  border: Border.all(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  page.iconPath,
                  style: const TextStyle(fontSize: 80),
                ),
              ),
            ),
          ),
          const SizedBox(height: 50),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: page.title,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              children: [
                TextSpan(
                  text: page.highlightText,
                  style: const TextStyle(color: AppColors.accentGold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: List.generate(
              onboardingPages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 8),
                height: 8,
                width: _currentPage == index ? 24 : 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primaryGreen
                      : Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          FloatingActionButton.extended(
            backgroundColor: AppColors.primaryGreen,
            onPressed: () {
              if (_currentPage < onboardingPages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOutCubic,
                );
              } else {
                context.read<OnboardingBloc>().add(MarkOnboardingShown());
              }
            },
            label: Text(
              _currentPage == onboardingPages.length - 1
                  ? "GET STARTED"
                  : "NEXT",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            icon: const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
