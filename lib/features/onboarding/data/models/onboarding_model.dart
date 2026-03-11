class OnboardingModel {
  final String title;
  final String highlightText;
  final String description;
  final String iconPath;

  OnboardingModel({
    required this.title,
    required this.highlightText,
    required this.description,
    required this.iconPath,
  });
}

final List<OnboardingModel> onboardingPages = [
  OnboardingModel(
    title: "Showcase Your ",
    highlightText: "Talent",
    description:
        "The digital home for Ethiopia's rising stars. Create your profile and let the world see your skills.",
    iconPath: "⚽",
  ),
  OnboardingModel(
    title: "Performance Insights for ",
    highlightText: "Scouting",
    description:
        "Advanced video analysis that breaks down your performance for professional scouts globally.",
    iconPath: "📊",
  ),
  OnboardingModel(
    title: "Bridge to your ",
    highlightText: "Dreams",
    description:
        "Connecting local talent directly with academies and international scouts. Your journey starts here.",
    iconPath: "🏆",
  ),
];
