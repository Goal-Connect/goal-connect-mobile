class OnboardingModel {
  final String title;
  final String highlightText;
  final String description;
  final String animationPath;

  OnboardingModel({
    required this.title,
    required this.highlightText,
    required this.description,
    required this.animationPath,
  });
}

final List<OnboardingModel> onboardingPages = [
  OnboardingModel(
    title: "Showcase Your ",
    highlightText: "Talent",
    description:
        "The digital home for Ethiopia's rising stars. Create your profile and let the world see your skills.",
    animationPath: 'assets/animations/football_player.json',
  ),
  OnboardingModel(
    title: "Performance Insights for ",
    highlightText: "Scouting",
    description:
        "Advanced video analysis that breaks down your performance for professional scouts globally.",
    animationPath: 'assets/animations/scouting_analysis.json',
  ),
  OnboardingModel(
    title: "Bridge to your ",
    highlightText: "Dreams",
    description:
        "Connecting local talent directly with academies and international scouts. Your journey starts here.",
    animationPath: 'assets/animations/goal_celebration.json',
  ),
];
