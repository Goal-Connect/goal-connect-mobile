import 'package:goal_connect/generated/l10n/app_localizations.dart';

class OnboardingModel {
  final String title;
  final String highlightText;
  final String description;
  final String animationPath;

  OnboardingModel({
    required this.title,
    required this.highlightText,
    required this.description,
    this.animationPath = '',
  });
}

List<OnboardingModel> onboardingPagesFor(AppLocalizations l) => [
      OnboardingModel(
        title: l.onboardingPage1Title,
        highlightText: l.onboardingPage1Highlight,
        description: l.onboardingPage1Description,
      ),
      OnboardingModel(
        title: l.onboardingPage2Title,
        highlightText: l.onboardingPage2Highlight,
        description: l.onboardingPage2Description,
        animationPath: 'assets/animations/scouting_analysis.json',
      ),
      OnboardingModel(
        title: l.onboardingPage3Title,
        highlightText: l.onboardingPage3Highlight,
        description: l.onboardingPage3Description,
        animationPath: 'assets/animations/goal_celebration.json',
      ),
    ];
