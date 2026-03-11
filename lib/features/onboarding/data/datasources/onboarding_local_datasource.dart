import 'package:shared_preferences/shared_preferences.dart';
import '../models/onboarding_info_model.dart';

abstract class OnboardingLocalDataSource {
  Future<OnboardingInfoModel> getOnboardingStatus();
  Future<void> setOnboardingShown();
}

class OnboardingLocalDataSourceImpl implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const keyIsShown = 'onboarding_shown';

  OnboardingLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<OnboardingInfoModel> getOnboardingStatus() async {
    final isShown = sharedPreferences.getBool(keyIsShown) ?? false;
    return OnboardingInfoModel(isShown: isShown);
  }

  @override
  Future<void> setOnboardingShown() async {
    await sharedPreferences.setBool(keyIsShown, true);
  }
}
