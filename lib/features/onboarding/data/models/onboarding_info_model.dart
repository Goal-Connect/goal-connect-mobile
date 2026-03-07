import '../../domain/entities/onboarding_info.dart';

class OnboardingInfoModel extends OnboardingInfo {
  OnboardingInfoModel({required super.isShown});

  factory OnboardingInfoModel.fromJson(Map<String, dynamic> json) {
    return OnboardingInfoModel(isShown: json['isShown'] as bool);
  }

  Map<String, dynamic> toJson() {
    return {'isShown': isShown};
  }
}
