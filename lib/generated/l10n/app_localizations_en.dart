// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Goal Connect';

  @override
  String get appTagline => 'Made with passion for the beautiful game';

  @override
  String get navHighlights => 'Highlights';

  @override
  String get navSearch => 'Search';

  @override
  String get navSaved => 'Saved';

  @override
  String get navChat => 'Chat';

  @override
  String get navProfile => 'Profile';

  @override
  String get noInternetTitle => 'No Internet Connection';

  @override
  String get noInternetSubtitle => 'Check your connection and try again';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonSave => 'Save';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonRetry => 'Retry';

  @override
  String get commonTryAgain => 'Try again';

  @override
  String get commonReply => 'Reply';

  @override
  String get commonReset => 'Reset';

  @override
  String get commonClear => 'Clear';

  @override
  String get commonApply => 'Apply filters';

  @override
  String get commonNext => 'NEXT';

  @override
  String get commonGetStarted => 'GET STARTED';

  @override
  String get commonSkip => 'Skip';

  @override
  String get commonLoading => 'Loading…';

  @override
  String get onboardingPage1Title => 'Showcase Your ';

  @override
  String get onboardingPage1Highlight => 'Talent';

  @override
  String get onboardingPage1Description =>
      'The digital home for Ethiopia\'s rising stars. Create your profile and let the world see your skills.';

  @override
  String get onboardingPage2Title => 'Performance Insights for ';

  @override
  String get onboardingPage2Highlight => 'Scouting';

  @override
  String get onboardingPage2Description =>
      'Advanced video analysis that breaks down your performance for professional scouts globally.';

  @override
  String get onboardingPage3Title => 'Bridge to your ';

  @override
  String get onboardingPage3Highlight => 'Dreams';

  @override
  String get onboardingPage3Description =>
      'Connecting local talent directly with academies and international scouts. Your journey starts here.';

  @override
  String get loginHeadlineLine1 => 'Connect Young Stars';

  @override
  String get loginHeadlineLine2Prefix => 'With Their ';

  @override
  String get loginHeadlineLine2Highlight => 'Dreams';

  @override
  String get loginWelcomeBack => 'Welcome back';

  @override
  String get loginContinueSubtitle => 'Sign in to continue to your account';

  @override
  String get loginEmailLabel => 'Email Address';

  @override
  String get loginEmailRequired => 'Email is required';

  @override
  String get loginEmailInvalid => 'Enter a valid email';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginPasswordRequired => 'Password is required';

  @override
  String get loginForgotPassword => 'Forgot Password?';

  @override
  String get loginButton => 'LOGIN TO ACCOUNT';

  @override
  String get loginOr => 'OR';

  @override
  String get loginCreateScoutAccount => 'Create scout account';

  @override
  String get scoutRegisterAppBarTitle => 'Create scout account';

  @override
  String scoutRegisterStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get scoutRegisterStep1Title => 'Account details';

  @override
  String get scoutRegisterStep1Subtitle => 'Let\'s start with your basic info.';

  @override
  String get scoutRegisterStep2Title => 'Identity & verification';

  @override
  String get scoutRegisterStep2Subtitle =>
      'Helps us verify you as a registered scout.';

  @override
  String get scoutRegisterStep3Title => 'Professional background';

  @override
  String get scoutRegisterStep3Subtitle => 'Tell us about your scouting work.';

  @override
  String get scoutRegisterReview => 'Review';

  @override
  String get scoutRegisterReviewName => 'Name';

  @override
  String get scoutRegisterReviewEmail => 'Email';

  @override
  String get scoutRegisterReviewPhone => 'Phone';

  @override
  String get scoutRegisterReviewCountry => 'Country';

  @override
  String get scoutRegisterReviewLicence => 'Licence';

  @override
  String get scoutRegisterReviewUploaded => 'Uploaded';

  @override
  String get scoutRegisterReviewNotUploaded => 'Not uploaded';

  @override
  String get scoutRegisterContinue => 'Continue';

  @override
  String get scoutRegisterBack => 'Back';

  @override
  String scoutRegisterFieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get scoutRegisterMinChars => 'At least 6 characters';

  @override
  String get scoutRegisterEmailInvalid => 'Enter a valid email';

  @override
  String get scoutRegisterTitle => 'Scout registration';

  @override
  String get scoutRegisterSubtitle =>
      'Provide your details and upload a clear photo of your scouting licence.';

  @override
  String get scoutRegisterFullName => 'Full name';

  @override
  String get scoutRegisterEmail => 'Email';

  @override
  String get scoutRegisterPassword => 'Password (min 6 characters)';

  @override
  String get scoutRegisterNationalId => 'National ID / FAN number';

  @override
  String get scoutRegisterPhone => 'Phone number';

  @override
  String get scoutRegisterOrganization => 'Organization / club (optional)';

  @override
  String get scoutRegisterCountry => 'Country';

  @override
  String get scoutRegisterYearsExperience => 'Years of experience (optional)';

  @override
  String get scoutRegisterLicencePhoto => 'Licence photo';

  @override
  String get scoutRegisterUploadLicence => 'Upload licence photo';

  @override
  String get scoutRegisterChangeLicence => 'Change licence photo';

  @override
  String get scoutRegisterPhotoSelected => 'Photo selected';

  @override
  String get scoutRegisterSubmit => 'CREATE SCOUT ACCOUNT';

  @override
  String get highlightsCreateTitle => 'Create Highlight';

  @override
  String get highlightsCreateSubtitle => 'Show scouts your best moves';

  @override
  String get highlightsRecordVideo => 'Record Video';

  @override
  String highlightsRecordVideoSubtitle(int seconds) {
    return 'Use your camera · up to ${seconds}s';
  }

  @override
  String get highlightsChooseFromGallery => 'Choose from Gallery';

  @override
  String get highlightsChooseFromGallerySubtitle =>
      'Pick an existing video clip';

  @override
  String get highlightsProTipTitle => 'Pro Tip';

  @override
  String get highlightsProTipBody =>
      'Keep clips under 30s and showcase one skill per highlight.';

  @override
  String highlightsMaxSeconds(int seconds) {
    return 'Max ${seconds}s';
  }

  @override
  String get highlightsTapToRecord => 'Tap to record';

  @override
  String highlightsRecordingProgress(String elapsed, String total) {
    return 'Recording... $elapsed / $total';
  }

  @override
  String get highlightsCameraNotAvailable =>
      'Camera not available on this device. Please use \"Choose from Gallery\" instead.';

  @override
  String get highlightsCaptionHint => 'Write a caption...';

  @override
  String get highlightsRetake => 'Retake';

  @override
  String get highlightsPost => 'Post Highlight';

  @override
  String get highlightsVisibleAfterPosting => 'Visible to scouts after posting';

  @override
  String get highlightsUploading => 'Uploading highlight...';

  @override
  String get highlightsUploadingSubtitle => 'This may take a moment';

  @override
  String get highlightsTopBarTitle => 'NEW HIGHLIGHT';

  @override
  String get highlightsSignInToUpload => 'Sign in as a player to upload.';

  @override
  String get highlightsCouldNotLike => 'Could not update like';

  @override
  String get highlightsNoHighlightsYet => 'No highlights yet';

  @override
  String get videoOptionsTitle => 'Options';

  @override
  String get videoOptionsEdit => 'Edit highlight';

  @override
  String get videoOptionsEditSubtitle =>
      'Title, description, privacy, drill type';

  @override
  String get videoOptionsDelete => 'Delete video';

  @override
  String get videoOptionsDeleteSubtitle => 'Remove from Goal Connect';

  @override
  String get videoOptionsSave => 'Save Video';

  @override
  String get videoOptionsSaveSubtitle => 'Add to your saved collection';

  @override
  String get videoOptionsCopyLink => 'Copy Link';

  @override
  String get videoOptionsCopyLinkSubtitle => 'Share via link';

  @override
  String get videoOptionsDownload => 'Download';

  @override
  String get videoOptionsDownloadSubtitle => 'Save to device';

  @override
  String get videoOptionsNotInterested => 'Not Interested';

  @override
  String get videoOptionsNotInterestedSubtitle => 'See fewer posts like this';

  @override
  String videoOptionsUnfollow(String username) {
    return 'Unfollow @$username';
  }

  @override
  String get videoOptionsUnfollowSubtitle => 'Stop seeing their highlights';

  @override
  String get videoOptionsReport => 'Report';

  @override
  String get videoOptionsReportSubtitle => 'Report this highlight';

  @override
  String videoOptionsBlock(String username) {
    return 'Block @$username';
  }

  @override
  String get videoOptionsBlockSubtitle =>
      'They won\'t be able to see your profile';

  @override
  String videoOptionsUnfollowed(String username) {
    return 'Unfollowed @$username';
  }

  @override
  String videoOptionsBlocked(String username) {
    return 'Blocked @$username';
  }

  @override
  String get videoOptionsLinkCopied => 'Link copied';

  @override
  String get videoOptionsVideoSaved => 'Video saved';

  @override
  String get videoOptionsShowFewer => 'We\'ll show fewer like this';

  @override
  String get videoOptionsReportSubmitted => 'Report submitted';

  @override
  String get videoEditTitle => 'Edit highlight';

  @override
  String get videoEditFieldTitle => 'Title';

  @override
  String get videoEditFieldDescription => 'Description';

  @override
  String get videoEditFieldPrivacy => 'Privacy';

  @override
  String get videoEditPrivacyPublic => 'public';

  @override
  String get videoEditPrivacyPrivate => 'private';

  @override
  String get videoEditFieldDrillType => 'Drill type';

  @override
  String get videoEditCouldNotUpdate => 'Could not update video';

  @override
  String get videoEditUpdated => 'Video updated';

  @override
  String get videoDeleteTitle => 'Delete video?';

  @override
  String get videoDeleteMessage =>
      'Are you sure you want to delete this video from Goal Connect?';

  @override
  String get videoDeleteCouldNotDelete => 'Could not delete video';

  @override
  String get videoDeleted => 'Video deleted';

  @override
  String get downloadNotSupportedOnWeb => 'Download not supported on web';

  @override
  String get downloadInProgress => 'Downloading video...';

  @override
  String get downloadSavedToFolder => 'Video saved to GoalConnect folder';

  @override
  String get downloadFailed => 'Download failed. Please try again.';

  @override
  String get downloadUnavailable => 'Video unavailable';

  @override
  String get downloadSavedToGallery => 'Saved to your gallery';

  @override
  String get downloadCouldNotDownload => 'Could not download video';

  @override
  String get downloadLabel => 'Download';

  @override
  String get reportSheetTitle => 'Report Highlight';

  @override
  String get reportSheetQuestion => 'Why are you reporting this highlight?';

  @override
  String get reportSheetSubmit => 'Submit Report';

  @override
  String get reportReasonSpam => 'Spam or misleading';

  @override
  String get reportReasonInappropriate => 'Inappropriate content';

  @override
  String get reportReasonHarassment => 'Harassment or bullying';

  @override
  String get reportReasonViolence => 'Violence or dangerous acts';

  @override
  String get reportReasonFake => 'Fake or edited highlight';

  @override
  String get reportReasonIp => 'Intellectual property violation';

  @override
  String get reportReasonOther => 'Other';

  @override
  String get reportSubmitFailed => 'Could not submit report. Please try again.';

  @override
  String get commentsTitle => 'Comments';

  @override
  String get commentsAddHint => 'Add a comment…';

  @override
  String get commentsReplyHint => 'Write a reply…';

  @override
  String commentsReplyingTo(String username) {
    return 'Replying to @$username';
  }

  @override
  String get commentsEmptyTitle => 'No comments yet';

  @override
  String get commentsEmptySubtitle => 'Be the first to share your thoughts!';

  @override
  String get commentsJustNow => 'just now';

  @override
  String get saveActionSave => 'Save';

  @override
  String get saveActionSaved => 'Saved';

  @override
  String get saveActionPending => '…';

  @override
  String get chatListTitle => 'Messages';

  @override
  String get chatListSubtitle => 'Scouts reach out here';

  @override
  String get chatListSearchHint => 'Search conversations...';

  @override
  String get chatListLoading => 'Loading conversations...';

  @override
  String get chatListConnectionIssue => 'Connection issue';

  @override
  String get chatListNoResults => 'No results found';

  @override
  String get chatListTryDifferentSearch => 'Try a different search term';

  @override
  String get chatListEmptyTitle => 'No conversations yet';

  @override
  String get chatListEmptySubtitle =>
      'When scouts message you,\nthey\'ll appear here';

  @override
  String get chatConversationActiveNow => 'Active now';

  @override
  String get chatConversationInputHint => 'Type a message…';

  @override
  String get chatConversationStartTitle => 'Start a conversation';

  @override
  String chatConversationStartSubtitle(String name) {
    return 'Say hello to $name!';
  }

  @override
  String get chatConversationUnableToLoad => 'Unable to load messages';

  @override
  String get chatDateToday => 'Today';

  @override
  String get chatDateYesterday => 'Yesterday';

  @override
  String get chatTimeNow => 'now';

  @override
  String chatTimeMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String chatTimeHours(int hours) {
    return '${hours}h';
  }

  @override
  String chatTimeDays(int days) {
    return '${days}d';
  }

  @override
  String chatTimeWeeks(int weeks) {
    return '${weeks}w';
  }

  @override
  String get searchTitle => 'Search';

  @override
  String get searchPlayersHint => 'Search players…';

  @override
  String get searchNoPlayersToShow => 'No players to show yet.';

  @override
  String get searchEmptyHint =>
      'Search by name or use filters to find players.';

  @override
  String get searchResults => 'Results';

  @override
  String searchNoMatchQuery(String query) {
    return 'No players match \"$query\".';
  }

  @override
  String get searchNoMatchFilters => 'No players match the selected filters.';

  @override
  String get searchPlayersSection => 'Players';

  @override
  String get filtersTitle => 'Filter players';

  @override
  String get filtersPosition => 'Position';

  @override
  String get filtersStrongFoot => 'Strong foot';

  @override
  String get filtersAge => 'Age';

  @override
  String get filtersHeightCm => 'Height (cm)';

  @override
  String get filtersMin => 'Min';

  @override
  String get filtersMax => 'Max';

  @override
  String get filtersPositionGoalkeeper => 'Goalkeeper';

  @override
  String get filtersPositionDefender => 'Defender';

  @override
  String get filtersPositionMidfielder => 'Midfielder';

  @override
  String get filtersPositionForward => 'Forward';

  @override
  String get filtersFootLeft => 'Left';

  @override
  String get filtersFootRight => 'Right';

  @override
  String get filtersFootBoth => 'Both';

  @override
  String filtersChipFoot(String foot) {
    return '$foot foot';
  }

  @override
  String filtersChipAge(String min, String max) {
    return 'Age $min–$max';
  }

  @override
  String filtersChipHeight(String min, String max) {
    return 'Height $min–$max cm';
  }

  @override
  String get savedPlayersTitle => 'Saved players';

  @override
  String get savedPlayersEmptyTitle => 'No saved players yet';

  @override
  String get savedPlayersEmptySubtitle =>
      'Bookmark players from search to keep them here for quick access.';

  @override
  String get savedPlayersRemoveTooltip => 'Remove from saved';

  @override
  String get playerProfileVideos => 'Videos';

  @override
  String get playerProfileGoals => 'Goals';

  @override
  String get playerProfileAssists => 'Assists';

  @override
  String get playerProfileMatches => 'Matches';

  @override
  String get playerProfileHighlights => 'Highlights';

  @override
  String get playerProfileFollowers => 'Followers';

  @override
  String get playerProfileFollowing => 'Following';

  @override
  String get playerProfileLikes => 'Likes';

  @override
  String get playerProfilePlayerInfo => 'Player Info';

  @override
  String get playerProfileAge => 'Age';

  @override
  String get playerProfileHeight => 'Height';

  @override
  String get playerProfileWeight => 'Weight';

  @override
  String get playerProfileFoot => 'Foot';

  @override
  String get playerProfileJersey => 'Jersey';

  @override
  String get playerProfilePosition => 'Position';

  @override
  String get playerProfileSecondary => 'Secondary';

  @override
  String get playerProfileNationality => 'Nationality';

  @override
  String get playerProfileDob => 'DOB';

  @override
  String get playerProfileCurrentClub => 'Current Club';

  @override
  String get playerProfilePlayingStyle => 'Playing style';

  @override
  String get playerProfileClubHistory => 'Club history';

  @override
  String get playerProfileDisciplinary => 'Disciplinary record';

  @override
  String get playerProfileYellowCards => 'Yellow cards';

  @override
  String get playerProfileRedCards => 'Red cards';

  @override
  String get playerProfileAbilityStats => 'Ability Stats';

  @override
  String playerProfileOverall(int value) {
    return 'OVR $value';
  }

  @override
  String get playerProfilePace => 'Pace';

  @override
  String get playerProfileShooting => 'Shooting';

  @override
  String get playerProfilePassing => 'Passing';

  @override
  String get playerProfileDribbling => 'Dribbling';

  @override
  String get playerProfileDefending => 'Defending';

  @override
  String get playerProfilePhysical => 'Physical';

  @override
  String get playerProfileMatchRecord => 'Match Record';

  @override
  String get currentUserProfileUserInfo => 'User Information';

  @override
  String get currentUserProfileEmail => 'Email';

  @override
  String get currentUserProfileRole => 'Role';

  @override
  String get currentUserProfileName => 'Name';

  @override
  String get currentUserProfileOrganization => 'Organization';

  @override
  String get currentUserProfilePhone => 'Phone';

  @override
  String get currentUserProfileCountry => 'Country';

  @override
  String get currentUserProfileScoutingPreferences => 'Scouting preferences';

  @override
  String get currentUserProfileNoPreferences => 'No preferences set yet';

  @override
  String get currentUserProfileAgeRange => 'Age range';

  @override
  String currentUserProfileAgeRangeValue(String lo, String hi) {
    return '$lo – $hi yrs';
  }

  @override
  String get currentUserProfilePositions => 'Positions';

  @override
  String get currentUserProfileRegions => 'Regions';

  @override
  String get currentUserProfileSaved => 'Saved';

  @override
  String get currentUserProfileRecentlyViewed => 'Recently viewed';

  @override
  String get currentUserProfileDocuments => 'Documents';

  @override
  String get currentUserProfileDetails => 'Player Details';

  @override
  String get currentUserProfileStrongFoot => 'Strong foot';

  @override
  String get currentUserProfileDateOfBirth => 'Date of birth';

  @override
  String get currentUserProfileAvailability => 'Availability';

  @override
  String get currentUserProfileVerification => 'Verification';

  @override
  String get currentUserProfileMinutes => 'Minutes';

  @override
  String get currentUserProfileYourHighlights => 'Your Highlights';

  @override
  String get currentUserProfileRadarGoals => 'GOALS';

  @override
  String get currentUserProfileRadarAssists => 'ASSISTS';

  @override
  String get currentUserProfileRadarMatches => 'MATCHES';

  @override
  String get currentUserProfileRadarMinutes => 'MINUTES';

  @override
  String get currentUserProfileRadarHeight => 'HEIGHT';

  @override
  String get currentUserProfileRadarDiscipline => 'DISCIPLINE';

  @override
  String get currentUserProfileCardYellow => 'Yellow';

  @override
  String get currentUserProfileCardRed => 'Red';

  @override
  String get settingsAppVersion => 'v1.0.0';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsSubtitle => 'Customise your GoalConnect experience';

  @override
  String get settingsDiscovery => 'Discovery';

  @override
  String get settingsScoutPreferences => 'Scouting preferences';

  @override
  String get settingsScoutPreferencesActive => 'Active';

  @override
  String get settingsScoutPreferencesInactive => 'Not set';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsUpdatePassword => 'Update password';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageAmharic => 'አማርኛ';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsTermsOfService => 'Terms of Service';

  @override
  String get settingsHelpSupport => 'Help & Support';

  @override
  String get settingsAbout => 'About GoalConnect';

  @override
  String get settingsAboutBody =>
      'GoalConnect is a platform that connects Ethiopian footballers with scouts, academies, and clubs across the country. Players can share match highlights, showcase their stats and playing style, and grow a profile that scouts can discover. Scouts can filter talent by position, region, and age, save players they like, and reach out directly through in-app chat. Our goal is simple: open more doors for the next generation of football talent.';

  @override
  String get settingsAboutClose => 'Close';

  @override
  String get settingsSignOut => 'Sign Out';

  @override
  String get settingsBrand => 'GoalConnect';

  @override
  String get settingsProfileSampleUsername => 'EthioStar_10';

  @override
  String get settingsProfileSamplePosition => 'FORWARD';

  @override
  String get settingsProfileSampleCountry => 'Ethiopia';

  @override
  String get updatePasswordTitle => 'Update password';

  @override
  String get updatePasswordSubtitle => 'You\'ll stay signed in on this device.';

  @override
  String get updatePasswordCurrent => 'Current password';

  @override
  String get updatePasswordNew => 'New password';

  @override
  String get updatePasswordConfirm => 'Confirm new password';

  @override
  String get updatePasswordEnterCurrent => 'Enter your current password';

  @override
  String get updatePasswordMinChars => 'At least 6 characters';

  @override
  String get updatePasswordMismatch => 'Passwords do not match';

  @override
  String get updatePasswordSuccess => 'Password updated successfully';

  @override
  String get updatePasswordFailure => 'Could not update password';

  @override
  String get scoutPreferencesTitle => 'Scouting preferences';

  @override
  String get scoutPreferencesSubtitle =>
      'Pick what you want to see in your highlights feed. All fields are optional — leave any blank to skip that filter.';

  @override
  String get scoutPreferencesPositions => 'Positions';

  @override
  String get scoutPreferencesRegions => 'Regions';

  @override
  String get scoutPreferencesRegionHint => 'e.g. Addis Ababa';

  @override
  String get scoutPreferencesRegionAdd => 'Add';

  @override
  String get scoutPreferencesAgeRange => 'Age range';

  @override
  String get scoutPreferencesAgeMin => 'Min age';

  @override
  String get scoutPreferencesAgeMax => 'Max age';

  @override
  String get scoutPreferencesSave => 'Save preferences';

  @override
  String get scoutPreferencesClear => 'Clear preferences';

  @override
  String get scoutPreferencesSaved => 'Preferences saved';

  @override
  String get scoutPreferencesCleared => 'Preferences cleared';
}
