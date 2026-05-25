import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('om'),
  ];

  /// Application name shown to the user.
  ///
  /// In en, this message translates to:
  /// **'Goal Connect'**
  String get appName;

  /// Marketing tagline shown in the settings footer.
  ///
  /// In en, this message translates to:
  /// **'Made with passion for the beautiful game'**
  String get appTagline;

  /// No description provided for @navHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get navHighlights;

  /// No description provided for @navSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get navSearch;

  /// No description provided for @navSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get navSaved;

  /// No description provided for @navChat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @noInternetTitle.
  ///
  /// In en, this message translates to:
  /// **'No Internet Connection'**
  String get noInternetTitle;

  /// No description provided for @noInternetSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Check your connection and try again'**
  String get noInternetSubtitle;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get commonRetry;

  /// No description provided for @commonTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get commonTryAgain;

  /// No description provided for @commonReply.
  ///
  /// In en, this message translates to:
  /// **'Reply'**
  String get commonReply;

  /// No description provided for @commonReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get commonReset;

  /// No description provided for @commonClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get commonClear;

  /// No description provided for @commonApply.
  ///
  /// In en, this message translates to:
  /// **'Apply filters'**
  String get commonApply;

  /// No description provided for @commonNext.
  ///
  /// In en, this message translates to:
  /// **'NEXT'**
  String get commonNext;

  /// No description provided for @commonGetStarted.
  ///
  /// In en, this message translates to:
  /// **'GET STARTED'**
  String get commonGetStarted;

  /// No description provided for @commonSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get commonSkip;

  /// No description provided for @commonLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get commonLoading;

  /// No description provided for @onboardingPage1Title.
  ///
  /// In en, this message translates to:
  /// **'Showcase Your '**
  String get onboardingPage1Title;

  /// No description provided for @onboardingPage1Highlight.
  ///
  /// In en, this message translates to:
  /// **'Talent'**
  String get onboardingPage1Highlight;

  /// No description provided for @onboardingPage1Description.
  ///
  /// In en, this message translates to:
  /// **'The digital home for Ethiopia\'s rising stars. Create your profile and let the world see your skills.'**
  String get onboardingPage1Description;

  /// No description provided for @onboardingPage2Title.
  ///
  /// In en, this message translates to:
  /// **'Performance Insights for '**
  String get onboardingPage2Title;

  /// No description provided for @onboardingPage2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Scouting'**
  String get onboardingPage2Highlight;

  /// No description provided for @onboardingPage2Description.
  ///
  /// In en, this message translates to:
  /// **'Performance insights for scouts about the player.'**
  String get onboardingPage2Description;

  /// No description provided for @onboardingPage3Title.
  ///
  /// In en, this message translates to:
  /// **'Bridge to your '**
  String get onboardingPage3Title;

  /// No description provided for @onboardingPage3Highlight.
  ///
  /// In en, this message translates to:
  /// **'Dreams'**
  String get onboardingPage3Highlight;

  /// No description provided for @onboardingPage3Description.
  ///
  /// In en, this message translates to:
  /// **'Connecting local talent directly with academies and scouts. Your journey starts here.'**
  String get onboardingPage3Description;

  /// No description provided for @loginHeadlineLine1.
  ///
  /// In en, this message translates to:
  /// **'Connect Young Stars'**
  String get loginHeadlineLine1;

  /// No description provided for @loginHeadlineLine2Prefix.
  ///
  /// In en, this message translates to:
  /// **'With Their '**
  String get loginHeadlineLine2Prefix;

  /// No description provided for @loginHeadlineLine2Highlight.
  ///
  /// In en, this message translates to:
  /// **'Dreams'**
  String get loginHeadlineLine2Highlight;

  /// No description provided for @loginWelcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginWelcomeBack;

  /// No description provided for @loginContinueSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to your account'**
  String get loginContinueSubtitle;

  /// No description provided for @loginEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get loginEmailLabel;

  /// No description provided for @loginEmailRequired.
  ///
  /// In en, this message translates to:
  /// **'Email is required'**
  String get loginEmailRequired;

  /// No description provided for @loginEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get loginEmailInvalid;

  /// No description provided for @loginPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get loginPasswordLabel;

  /// No description provided for @loginPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get loginPasswordRequired;

  /// No description provided for @loginForgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'LOGIN TO ACCOUNT'**
  String get loginButton;

  /// No description provided for @loginOr.
  ///
  /// In en, this message translates to:
  /// **'OR'**
  String get loginOr;

  /// No description provided for @loginCreateScoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Apply for the scout'**
  String get loginCreateScoutAccount;

  /// No description provided for @scoutRegisterAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply for scout account'**
  String get scoutRegisterAppBarTitle;

  /// No description provided for @scoutRegisterStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String scoutRegisterStepOf(int current, int total);

  /// No description provided for @scoutRegisterStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get scoutRegisterStep1Title;

  /// No description provided for @scoutRegisterStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s start with your basic info.'**
  String get scoutRegisterStep1Subtitle;

  /// No description provided for @scoutRegisterStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Identity & verification'**
  String get scoutRegisterStep2Title;

  /// No description provided for @scoutRegisterStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps us verify you as a registered scout.'**
  String get scoutRegisterStep2Subtitle;

  /// No description provided for @scoutRegisterStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Professional background'**
  String get scoutRegisterStep3Title;

  /// No description provided for @scoutRegisterStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your scouting work.'**
  String get scoutRegisterStep3Subtitle;

  /// No description provided for @scoutRegisterReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get scoutRegisterReview;

  /// No description provided for @scoutRegisterReviewName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get scoutRegisterReviewName;

  /// No description provided for @scoutRegisterReviewEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get scoutRegisterReviewEmail;

  /// No description provided for @scoutRegisterReviewPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get scoutRegisterReviewPhone;

  /// No description provided for @scoutRegisterReviewCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get scoutRegisterReviewCountry;

  /// No description provided for @scoutRegisterReviewLicence.
  ///
  /// In en, this message translates to:
  /// **'Licence'**
  String get scoutRegisterReviewLicence;

  /// No description provided for @scoutRegisterReviewUploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get scoutRegisterReviewUploaded;

  /// No description provided for @scoutRegisterReviewNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Not uploaded'**
  String get scoutRegisterReviewNotUploaded;

  /// No description provided for @scoutRegisterContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get scoutRegisterContinue;

  /// No description provided for @scoutRegisterBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get scoutRegisterBack;

  /// No description provided for @scoutRegisterFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String scoutRegisterFieldRequired(String field);

  /// No description provided for @scoutRegisterMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get scoutRegisterMinChars;

  /// No description provided for @scoutRegisterEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get scoutRegisterEmailInvalid;

  /// No description provided for @scoutRegisterTitle.
  ///
  /// In en, this message translates to:
  /// **'Scout registration'**
  String get scoutRegisterTitle;

  /// No description provided for @scoutRegisterSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Provide your details and upload a clear photo of your scouting licence.'**
  String get scoutRegisterSubtitle;

  /// No description provided for @scoutRegisterFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get scoutRegisterFullName;

  /// No description provided for @scoutRegisterEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get scoutRegisterEmail;

  /// No description provided for @scoutRegisterPassword.
  ///
  /// In en, this message translates to:
  /// **'Password (min 6 characters)'**
  String get scoutRegisterPassword;

  /// No description provided for @scoutRegisterNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID / FAN number'**
  String get scoutRegisterNationalId;

  /// No description provided for @scoutRegisterPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get scoutRegisterPhone;

  /// No description provided for @scoutRegisterOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization / club (optional)'**
  String get scoutRegisterOrganization;

  /// No description provided for @scoutRegisterCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get scoutRegisterCountry;

  /// No description provided for @scoutRegisterYearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience (optional)'**
  String get scoutRegisterYearsExperience;

  /// No description provided for @scoutRegisterLicencePhoto.
  ///
  /// In en, this message translates to:
  /// **'Licence photo'**
  String get scoutRegisterLicencePhoto;

  /// No description provided for @scoutRegisterUploadLicence.
  ///
  /// In en, this message translates to:
  /// **'Upload licence photo'**
  String get scoutRegisterUploadLicence;

  /// No description provided for @scoutRegisterChangeLicence.
  ///
  /// In en, this message translates to:
  /// **'Change licence photo'**
  String get scoutRegisterChangeLicence;

  /// No description provided for @scoutRegisterPhotoSelected.
  ///
  /// In en, this message translates to:
  /// **'Photo selected'**
  String get scoutRegisterPhotoSelected;

  /// No description provided for @scoutRegisterSubmit.
  ///
  /// In en, this message translates to:
  /// **'APPLY'**
  String get scoutRegisterSubmit;

  /// No description provided for @highlightsCreateTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Highlight'**
  String get highlightsCreateTitle;

  /// No description provided for @highlightsCreateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Show scouts your best moves'**
  String get highlightsCreateSubtitle;

  /// No description provided for @highlightsRecordVideo.
  ///
  /// In en, this message translates to:
  /// **'Record Video'**
  String get highlightsRecordVideo;

  /// No description provided for @highlightsRecordVideoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use your camera · up to {seconds}s'**
  String highlightsRecordVideoSubtitle(int seconds);

  /// No description provided for @highlightsChooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get highlightsChooseFromGallery;

  /// No description provided for @highlightsChooseFromGallerySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick an existing video clip'**
  String get highlightsChooseFromGallerySubtitle;

  /// No description provided for @highlightsProTipTitle.
  ///
  /// In en, this message translates to:
  /// **'Pro Tip'**
  String get highlightsProTipTitle;

  /// No description provided for @highlightsProTipBody.
  ///
  /// In en, this message translates to:
  /// **'Keep clips under 30s and showcase one skill per highlight.'**
  String get highlightsProTipBody;

  /// No description provided for @highlightsMaxSeconds.
  ///
  /// In en, this message translates to:
  /// **'Max {seconds}s'**
  String highlightsMaxSeconds(int seconds);

  /// No description provided for @highlightsTapToRecord.
  ///
  /// In en, this message translates to:
  /// **'Tap to record'**
  String get highlightsTapToRecord;

  /// No description provided for @highlightsRecordingProgress.
  ///
  /// In en, this message translates to:
  /// **'Recording... {elapsed} / {total}'**
  String highlightsRecordingProgress(String elapsed, String total);

  /// No description provided for @highlightsCameraNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Camera not available on this device. Please use \"Choose from Gallery\" instead.'**
  String get highlightsCameraNotAvailable;

  /// No description provided for @highlightsCaptionHint.
  ///
  /// In en, this message translates to:
  /// **'Write a caption...'**
  String get highlightsCaptionHint;

  /// No description provided for @highlightsRetake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get highlightsRetake;

  /// No description provided for @highlightsPost.
  ///
  /// In en, this message translates to:
  /// **'Post Highlight'**
  String get highlightsPost;

  /// No description provided for @highlightsVisibleAfterPosting.
  ///
  /// In en, this message translates to:
  /// **'Visible to scouts after posting'**
  String get highlightsVisibleAfterPosting;

  /// No description provided for @highlightsUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading highlight...'**
  String get highlightsUploading;

  /// No description provided for @highlightsUploadingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This may take a moment'**
  String get highlightsUploadingSubtitle;

  /// No description provided for @highlightsTopBarTitle.
  ///
  /// In en, this message translates to:
  /// **'NEW HIGHLIGHT'**
  String get highlightsTopBarTitle;

  /// No description provided for @highlightsSignInToUpload.
  ///
  /// In en, this message translates to:
  /// **'Sign in as a player to upload.'**
  String get highlightsSignInToUpload;

  /// No description provided for @highlightsCouldNotLike.
  ///
  /// In en, this message translates to:
  /// **'Could not update like'**
  String get highlightsCouldNotLike;

  /// No description provided for @highlightsNoHighlightsYet.
  ///
  /// In en, this message translates to:
  /// **'No highlights yet'**
  String get highlightsNoHighlightsYet;

  /// No description provided for @videoOptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get videoOptionsTitle;

  /// No description provided for @videoOptionsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit highlight'**
  String get videoOptionsEdit;

  /// No description provided for @videoOptionsEditSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Title, description, privacy, drill type'**
  String get videoOptionsEditSubtitle;

  /// No description provided for @videoOptionsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete video'**
  String get videoOptionsDelete;

  /// No description provided for @videoOptionsDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove from Goal Connect'**
  String get videoOptionsDeleteSubtitle;

  /// No description provided for @videoOptionsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Player'**
  String get videoOptionsSave;

  /// No description provided for @videoOptionsSaveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add this player to your saved list'**
  String get videoOptionsSaveSubtitle;

  /// No description provided for @videoOptionsCopyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get videoOptionsCopyLink;

  /// No description provided for @videoOptionsCopyLinkSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Share via link'**
  String get videoOptionsCopyLinkSubtitle;

  /// No description provided for @videoOptionsDownload.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get videoOptionsDownload;

  /// No description provided for @videoOptionsDownloadSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save to device'**
  String get videoOptionsDownloadSubtitle;

  /// No description provided for @videoOptionsNotInterested.
  ///
  /// In en, this message translates to:
  /// **'Not Interested'**
  String get videoOptionsNotInterested;

  /// No description provided for @videoOptionsNotInterestedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'See fewer posts like this'**
  String get videoOptionsNotInterestedSubtitle;

  /// No description provided for @videoOptionsUnfollow.
  ///
  /// In en, this message translates to:
  /// **'Unfollow @{username}'**
  String videoOptionsUnfollow(String username);

  /// No description provided for @videoOptionsUnfollowSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stop seeing their highlights'**
  String get videoOptionsUnfollowSubtitle;

  /// No description provided for @videoOptionsReport.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get videoOptionsReport;

  /// No description provided for @videoOptionsReportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Report this highlight'**
  String get videoOptionsReportSubtitle;

  /// No description provided for @videoOptionsBlock.
  ///
  /// In en, this message translates to:
  /// **'Block @{username}'**
  String videoOptionsBlock(String username);

  /// No description provided for @videoOptionsBlockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They won\'t be able to see your profile'**
  String get videoOptionsBlockSubtitle;

  /// No description provided for @videoOptionsUnfollowed.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed @{username}'**
  String videoOptionsUnfollowed(String username);

  /// No description provided for @videoOptionsBlocked.
  ///
  /// In en, this message translates to:
  /// **'Blocked @{username}'**
  String videoOptionsBlocked(String username);

  /// No description provided for @videoOptionsLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Link copied'**
  String get videoOptionsLinkCopied;

  /// No description provided for @videoOptionsVideoSaved.
  ///
  /// In en, this message translates to:
  /// **'Player saved'**
  String get videoOptionsVideoSaved;

  /// No description provided for @videoOptionsShowFewer.
  ///
  /// In en, this message translates to:
  /// **'We\'ll show fewer like this'**
  String get videoOptionsShowFewer;

  /// No description provided for @videoOptionsReportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted'**
  String get videoOptionsReportSubmitted;

  /// No description provided for @videoEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit highlight'**
  String get videoEditTitle;

  /// No description provided for @videoEditFieldTitle.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get videoEditFieldTitle;

  /// No description provided for @videoEditFieldDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get videoEditFieldDescription;

  /// No description provided for @videoEditFieldPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get videoEditFieldPrivacy;

  /// No description provided for @videoEditPrivacyPublic.
  ///
  /// In en, this message translates to:
  /// **'public'**
  String get videoEditPrivacyPublic;

  /// No description provided for @videoEditPrivacyPrivate.
  ///
  /// In en, this message translates to:
  /// **'private'**
  String get videoEditPrivacyPrivate;

  /// No description provided for @videoEditFieldDrillType.
  ///
  /// In en, this message translates to:
  /// **'Drill type'**
  String get videoEditFieldDrillType;

  /// No description provided for @videoEditCouldNotUpdate.
  ///
  /// In en, this message translates to:
  /// **'Could not update video'**
  String get videoEditCouldNotUpdate;

  /// No description provided for @videoEditUpdated.
  ///
  /// In en, this message translates to:
  /// **'Video updated'**
  String get videoEditUpdated;

  /// No description provided for @videoDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete video?'**
  String get videoDeleteTitle;

  /// No description provided for @videoDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this video from Goal Connect?'**
  String get videoDeleteMessage;

  /// No description provided for @videoDeleteCouldNotDelete.
  ///
  /// In en, this message translates to:
  /// **'Could not delete video'**
  String get videoDeleteCouldNotDelete;

  /// No description provided for @videoDeleted.
  ///
  /// In en, this message translates to:
  /// **'Video deleted'**
  String get videoDeleted;

  /// No description provided for @downloadNotSupportedOnWeb.
  ///
  /// In en, this message translates to:
  /// **'Download not supported on web'**
  String get downloadNotSupportedOnWeb;

  /// No description provided for @downloadInProgress.
  ///
  /// In en, this message translates to:
  /// **'Downloading video...'**
  String get downloadInProgress;

  /// No description provided for @downloadSavedToFolder.
  ///
  /// In en, this message translates to:
  /// **'Video saved to GoalConnect folder'**
  String get downloadSavedToFolder;

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed. Please try again.'**
  String get downloadFailed;

  /// No description provided for @downloadUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Video unavailable'**
  String get downloadUnavailable;

  /// No description provided for @downloadSavedToGallery.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery'**
  String get downloadSavedToGallery;

  /// No description provided for @downloadCouldNotDownload.
  ///
  /// In en, this message translates to:
  /// **'Could not download video'**
  String get downloadCouldNotDownload;

  /// No description provided for @downloadLabel.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get downloadLabel;

  /// No description provided for @reportSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Report Highlight'**
  String get reportSheetTitle;

  /// No description provided for @reportSheetQuestion.
  ///
  /// In en, this message translates to:
  /// **'Why are you reporting this highlight?'**
  String get reportSheetQuestion;

  /// No description provided for @reportSheetSubmit.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get reportSheetSubmit;

  /// No description provided for @reportReasonSpam.
  ///
  /// In en, this message translates to:
  /// **'Spam or misleading'**
  String get reportReasonSpam;

  /// No description provided for @reportReasonInappropriate.
  ///
  /// In en, this message translates to:
  /// **'Inappropriate content'**
  String get reportReasonInappropriate;

  /// No description provided for @reportReasonHarassment.
  ///
  /// In en, this message translates to:
  /// **'Harassment or bullying'**
  String get reportReasonHarassment;

  /// No description provided for @reportReasonViolence.
  ///
  /// In en, this message translates to:
  /// **'Violence or dangerous acts'**
  String get reportReasonViolence;

  /// No description provided for @reportReasonFake.
  ///
  /// In en, this message translates to:
  /// **'Fake or edited highlight'**
  String get reportReasonFake;

  /// No description provided for @reportReasonIp.
  ///
  /// In en, this message translates to:
  /// **'Intellectual property violation'**
  String get reportReasonIp;

  /// No description provided for @reportReasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get reportReasonOther;

  /// No description provided for @reportSubmitFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not submit report. Please try again.'**
  String get reportSubmitFailed;

  /// No description provided for @commentsTitle.
  ///
  /// In en, this message translates to:
  /// **'Comments'**
  String get commentsTitle;

  /// No description provided for @commentsAddHint.
  ///
  /// In en, this message translates to:
  /// **'Add a comment…'**
  String get commentsAddHint;

  /// No description provided for @commentsReplyHint.
  ///
  /// In en, this message translates to:
  /// **'Write a reply…'**
  String get commentsReplyHint;

  /// No description provided for @commentsReplyingTo.
  ///
  /// In en, this message translates to:
  /// **'Replying to @{username}'**
  String commentsReplyingTo(String username);

  /// No description provided for @commentsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No comments yet'**
  String get commentsEmptyTitle;

  /// No description provided for @commentsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Be the first to share your thoughts!'**
  String get commentsEmptySubtitle;

  /// No description provided for @commentsJustNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get commentsJustNow;

  /// No description provided for @saveActionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveActionSave;

  /// No description provided for @saveActionSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get saveActionSaved;

  /// No description provided for @saveActionPending.
  ///
  /// In en, this message translates to:
  /// **'…'**
  String get saveActionPending;

  /// No description provided for @chatListTitle.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get chatListTitle;

  /// No description provided for @chatListSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scouts reach out here'**
  String get chatListSubtitle;

  /// No description provided for @chatListSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search conversations...'**
  String get chatListSearchHint;

  /// No description provided for @chatListLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading conversations...'**
  String get chatListLoading;

  /// No description provided for @chatListConnectionIssue.
  ///
  /// In en, this message translates to:
  /// **'Connection issue'**
  String get chatListConnectionIssue;

  /// No description provided for @chatListNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get chatListNoResults;

  /// No description provided for @chatListTryDifferentSearch.
  ///
  /// In en, this message translates to:
  /// **'Try a different search term'**
  String get chatListTryDifferentSearch;

  /// No description provided for @chatListEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No conversations yet'**
  String get chatListEmptyTitle;

  /// No description provided for @chatListEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'When scouts message you,\nthey\'ll appear here'**
  String get chatListEmptySubtitle;

  /// No description provided for @chatConversationActiveNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get chatConversationActiveNow;

  /// No description provided for @chatConversationInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatConversationInputHint;

  /// No description provided for @chatMessageActionCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get chatMessageActionCopy;

  /// No description provided for @chatMessageActionEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get chatMessageActionEdit;

  /// No description provided for @chatMessageActionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get chatMessageActionDelete;

  /// No description provided for @chatMessageCopied.
  ///
  /// In en, this message translates to:
  /// **'Message copied'**
  String get chatMessageCopied;

  /// No description provided for @chatMessageEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get chatMessageEditTitle;

  /// No description provided for @chatMessageDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete message'**
  String get chatMessageDeleteTitle;

  /// No description provided for @chatMessageDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'This message will be removed for everyone in this conversation.'**
  String get chatMessageDeleteConfirm;

  /// No description provided for @chatConversationStartTitle.
  ///
  /// In en, this message translates to:
  /// **'Start a conversation'**
  String get chatConversationStartTitle;

  /// No description provided for @chatConversationStartSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Say hello to {name}!'**
  String chatConversationStartSubtitle(String name);

  /// No description provided for @chatConversationUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load messages'**
  String get chatConversationUnableToLoad;

  /// No description provided for @chatDateToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get chatDateToday;

  /// No description provided for @chatDateYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get chatDateYesterday;

  /// No description provided for @chatTimeNow.
  ///
  /// In en, this message translates to:
  /// **'now'**
  String get chatTimeNow;

  /// No description provided for @chatTimeMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String chatTimeMinutes(int minutes);

  /// No description provided for @chatTimeHours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String chatTimeHours(int hours);

  /// No description provided for @chatTimeDays.
  ///
  /// In en, this message translates to:
  /// **'{days}d'**
  String chatTimeDays(int days);

  /// No description provided for @chatTimeWeeks.
  ///
  /// In en, this message translates to:
  /// **'{weeks}w'**
  String chatTimeWeeks(int weeks);

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchPlayersHint.
  ///
  /// In en, this message translates to:
  /// **'Search players…'**
  String get searchPlayersHint;

  /// No description provided for @searchNoPlayersToShow.
  ///
  /// In en, this message translates to:
  /// **'No players to show yet.'**
  String get searchNoPlayersToShow;

  /// No description provided for @searchEmptyHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or use filters to find players.'**
  String get searchEmptyHint;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Results'**
  String get searchResults;

  /// No description provided for @searchNoMatchQuery.
  ///
  /// In en, this message translates to:
  /// **'No players match \"{query}\".'**
  String searchNoMatchQuery(String query);

  /// No description provided for @searchNoMatchFilters.
  ///
  /// In en, this message translates to:
  /// **'No players match the selected filters.'**
  String get searchNoMatchFilters;

  /// No description provided for @searchPlayersSection.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get searchPlayersSection;

  /// No description provided for @searchTabPlayers.
  ///
  /// In en, this message translates to:
  /// **'Players'**
  String get searchTabPlayers;

  /// No description provided for @searchTabAcademies.
  ///
  /// In en, this message translates to:
  /// **'Academies'**
  String get searchTabAcademies;

  /// No description provided for @academiesSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search academies…'**
  String get academiesSearchHint;

  /// No description provided for @academiesNoResults.
  ///
  /// In en, this message translates to:
  /// **'No academies match your search.'**
  String get academiesNoResults;

  /// No description provided for @academiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No approved academies yet.'**
  String get academiesEmpty;

  /// No description provided for @academiesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not load academies. Tap to retry.'**
  String get academiesLoadFailed;

  /// No description provided for @academiesPlayersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No players yet} =1{1 player} other{{count} players}}'**
  String academiesPlayersCount(int count);

  /// No description provided for @academiesMessage.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get academiesMessage;

  /// No description provided for @academiesChatUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This academy has no contactable owner yet.'**
  String get academiesChatUnavailable;

  /// No description provided for @academiesRegionAll.
  ///
  /// In en, this message translates to:
  /// **'All regions'**
  String get academiesRegionAll;

  /// No description provided for @academiesRegionFilterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter by region'**
  String get academiesRegionFilterTitle;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filter players'**
  String get filtersTitle;

  /// No description provided for @filtersPosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get filtersPosition;

  /// No description provided for @filtersStrongFoot.
  ///
  /// In en, this message translates to:
  /// **'Strong foot'**
  String get filtersStrongFoot;

  /// No description provided for @filtersAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get filtersAge;

  /// No description provided for @filtersHeightCm.
  ///
  /// In en, this message translates to:
  /// **'Height (cm)'**
  String get filtersHeightCm;

  /// No description provided for @filtersMin.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get filtersMin;

  /// No description provided for @filtersMax.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get filtersMax;

  /// No description provided for @filtersPositionGoalkeeper.
  ///
  /// In en, this message translates to:
  /// **'Goalkeeper'**
  String get filtersPositionGoalkeeper;

  /// No description provided for @filtersPositionDefender.
  ///
  /// In en, this message translates to:
  /// **'Defender'**
  String get filtersPositionDefender;

  /// No description provided for @filtersPositionMidfielder.
  ///
  /// In en, this message translates to:
  /// **'Midfielder'**
  String get filtersPositionMidfielder;

  /// No description provided for @filtersPositionForward.
  ///
  /// In en, this message translates to:
  /// **'Forward'**
  String get filtersPositionForward;

  /// No description provided for @filtersFootLeft.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get filtersFootLeft;

  /// No description provided for @filtersFootRight.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get filtersFootRight;

  /// No description provided for @filtersFootBoth.
  ///
  /// In en, this message translates to:
  /// **'Both'**
  String get filtersFootBoth;

  /// No description provided for @filtersChipFoot.
  ///
  /// In en, this message translates to:
  /// **'{foot} foot'**
  String filtersChipFoot(String foot);

  /// No description provided for @filtersChipAge.
  ///
  /// In en, this message translates to:
  /// **'Age {min}–{max}'**
  String filtersChipAge(String min, String max);

  /// No description provided for @filtersChipHeight.
  ///
  /// In en, this message translates to:
  /// **'Height {min}–{max} cm'**
  String filtersChipHeight(String min, String max);

  /// No description provided for @savedPlayersTitle.
  ///
  /// In en, this message translates to:
  /// **'Saved players'**
  String get savedPlayersTitle;

  /// No description provided for @savedPlayersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Players you\'re tracking'**
  String get savedPlayersSubtitle;

  /// No description provided for @savedPlayersCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 saved} other{{count} saved}}'**
  String savedPlayersCount(int count);

  /// No description provided for @savedPlayersEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No saved players yet'**
  String get savedPlayersEmptyTitle;

  /// No description provided for @savedPlayersEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Bookmark players from search to keep them here for quick access.'**
  String get savedPlayersEmptySubtitle;

  /// No description provided for @savedPlayersRemoveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove from saved'**
  String get savedPlayersRemoveTooltip;

  /// No description provided for @savedPlayersStatHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get savedPlayersStatHighlights;

  /// No description provided for @savedPlayersStatFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get savedPlayersStatFollowers;

  /// No description provided for @savedPlayersStatLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get savedPlayersStatLikes;

  /// No description provided for @playerProfileVideos.
  ///
  /// In en, this message translates to:
  /// **'Videos'**
  String get playerProfileVideos;

  /// No description provided for @playerProfileGoals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get playerProfileGoals;

  /// No description provided for @playerProfileAssists.
  ///
  /// In en, this message translates to:
  /// **'Assists'**
  String get playerProfileAssists;

  /// No description provided for @playerProfileMatches.
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get playerProfileMatches;

  /// No description provided for @playerProfileHighlights.
  ///
  /// In en, this message translates to:
  /// **'Highlights'**
  String get playerProfileHighlights;

  /// No description provided for @playerProfileFollowers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get playerProfileFollowers;

  /// No description provided for @playerProfileFollowing.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get playerProfileFollowing;

  /// No description provided for @playerProfileLikes.
  ///
  /// In en, this message translates to:
  /// **'Likes'**
  String get playerProfileLikes;

  /// No description provided for @playerProfilePlayerInfo.
  ///
  /// In en, this message translates to:
  /// **'Player Info'**
  String get playerProfilePlayerInfo;

  /// No description provided for @playerProfileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get playerProfileAge;

  /// No description provided for @playerProfileHeight.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get playerProfileHeight;

  /// No description provided for @playerProfileWeight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get playerProfileWeight;

  /// No description provided for @playerProfileFoot.
  ///
  /// In en, this message translates to:
  /// **'Foot'**
  String get playerProfileFoot;

  /// No description provided for @playerProfileJersey.
  ///
  /// In en, this message translates to:
  /// **'Jersey'**
  String get playerProfileJersey;

  /// No description provided for @playerProfilePosition.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get playerProfilePosition;

  /// No description provided for @playerProfileSecondary.
  ///
  /// In en, this message translates to:
  /// **'Secondary'**
  String get playerProfileSecondary;

  /// No description provided for @playerProfileNationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get playerProfileNationality;

  /// No description provided for @playerProfileDob.
  ///
  /// In en, this message translates to:
  /// **'DOB'**
  String get playerProfileDob;

  /// No description provided for @playerProfileCurrentClub.
  ///
  /// In en, this message translates to:
  /// **'Current Club'**
  String get playerProfileCurrentClub;

  /// No description provided for @playerProfilePlayingStyle.
  ///
  /// In en, this message translates to:
  /// **'Playing style'**
  String get playerProfilePlayingStyle;

  /// No description provided for @playerProfileClubHistory.
  ///
  /// In en, this message translates to:
  /// **'Club history'**
  String get playerProfileClubHistory;

  /// No description provided for @playerProfileDisciplinary.
  ///
  /// In en, this message translates to:
  /// **'Disciplinary record'**
  String get playerProfileDisciplinary;

  /// No description provided for @playerProfileYellowCards.
  ///
  /// In en, this message translates to:
  /// **'Yellow cards'**
  String get playerProfileYellowCards;

  /// No description provided for @playerProfileRedCards.
  ///
  /// In en, this message translates to:
  /// **'Red cards'**
  String get playerProfileRedCards;

  /// No description provided for @playerProfileAbilityStats.
  ///
  /// In en, this message translates to:
  /// **'Ability Stats'**
  String get playerProfileAbilityStats;

  /// No description provided for @playerProfileOverall.
  ///
  /// In en, this message translates to:
  /// **'OVR {value}'**
  String playerProfileOverall(int value);

  /// No description provided for @playerProfilePace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get playerProfilePace;

  /// No description provided for @playerProfileShooting.
  ///
  /// In en, this message translates to:
  /// **'Shooting'**
  String get playerProfileShooting;

  /// No description provided for @playerProfilePassing.
  ///
  /// In en, this message translates to:
  /// **'Passing'**
  String get playerProfilePassing;

  /// No description provided for @playerProfileDribbling.
  ///
  /// In en, this message translates to:
  /// **'Dribbling'**
  String get playerProfileDribbling;

  /// No description provided for @playerProfileDefending.
  ///
  /// In en, this message translates to:
  /// **'Defending'**
  String get playerProfileDefending;

  /// No description provided for @playerProfilePhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get playerProfilePhysical;

  /// No description provided for @playerProfileMatchRecord.
  ///
  /// In en, this message translates to:
  /// **'Match Record'**
  String get playerProfileMatchRecord;

  /// No description provided for @currentUserProfileUserInfo.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get currentUserProfileUserInfo;

  /// No description provided for @currentUserProfileEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get currentUserProfileEmail;

  /// No description provided for @currentUserProfileRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get currentUserProfileRole;

  /// No description provided for @currentUserProfileName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get currentUserProfileName;

  /// No description provided for @currentUserProfileOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get currentUserProfileOrganization;

  /// No description provided for @currentUserProfilePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get currentUserProfilePhone;

  /// No description provided for @currentUserProfileCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get currentUserProfileCountry;

  /// No description provided for @currentUserProfileScoutingPreferences.
  ///
  /// In en, this message translates to:
  /// **'Scouting preferences'**
  String get currentUserProfileScoutingPreferences;

  /// No description provided for @currentUserProfileNoPreferences.
  ///
  /// In en, this message translates to:
  /// **'No preferences set yet'**
  String get currentUserProfileNoPreferences;

  /// No description provided for @currentUserProfileAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get currentUserProfileAgeRange;

  /// No description provided for @currentUserProfileAgeRangeValue.
  ///
  /// In en, this message translates to:
  /// **'{lo} – {hi} yrs'**
  String currentUserProfileAgeRangeValue(String lo, String hi);

  /// No description provided for @currentUserProfilePositions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get currentUserProfilePositions;

  /// No description provided for @currentUserProfileRegions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get currentUserProfileRegions;

  /// No description provided for @currentUserProfileSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get currentUserProfileSaved;

  /// No description provided for @currentUserProfileRecentlyViewed.
  ///
  /// In en, this message translates to:
  /// **'Recently viewed'**
  String get currentUserProfileRecentlyViewed;

  /// No description provided for @currentUserProfileDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get currentUserProfileDocuments;

  /// No description provided for @currentUserProfileDetails.
  ///
  /// In en, this message translates to:
  /// **'Player Details'**
  String get currentUserProfileDetails;

  /// No description provided for @currentUserProfileStrongFoot.
  ///
  /// In en, this message translates to:
  /// **'Strong foot'**
  String get currentUserProfileStrongFoot;

  /// No description provided for @currentUserProfileDateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of birth'**
  String get currentUserProfileDateOfBirth;

  /// No description provided for @currentUserProfileAvailability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get currentUserProfileAvailability;

  /// No description provided for @currentUserProfileVerification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get currentUserProfileVerification;

  /// No description provided for @currentUserProfileMinutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get currentUserProfileMinutes;

  /// No description provided for @currentUserProfileYourHighlights.
  ///
  /// In en, this message translates to:
  /// **'Your Highlights'**
  String get currentUserProfileYourHighlights;

  /// No description provided for @currentUserProfileRadarGoals.
  ///
  /// In en, this message translates to:
  /// **'GOALS'**
  String get currentUserProfileRadarGoals;

  /// No description provided for @currentUserProfileRadarAssists.
  ///
  /// In en, this message translates to:
  /// **'ASSISTS'**
  String get currentUserProfileRadarAssists;

  /// No description provided for @currentUserProfileRadarMatches.
  ///
  /// In en, this message translates to:
  /// **'MATCHES'**
  String get currentUserProfileRadarMatches;

  /// No description provided for @currentUserProfileRadarMinutes.
  ///
  /// In en, this message translates to:
  /// **'MINUTES'**
  String get currentUserProfileRadarMinutes;

  /// No description provided for @currentUserProfileRadarHeight.
  ///
  /// In en, this message translates to:
  /// **'HEIGHT'**
  String get currentUserProfileRadarHeight;

  /// No description provided for @currentUserProfileRadarDiscipline.
  ///
  /// In en, this message translates to:
  /// **'DISCIPLINE'**
  String get currentUserProfileRadarDiscipline;

  /// No description provided for @currentUserProfileCardYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get currentUserProfileCardYellow;

  /// No description provided for @currentUserProfileCardRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get currentUserProfileCardRed;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'v1.0.0'**
  String get settingsAppVersion;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customise your GoalConnect experience'**
  String get settingsSubtitle;

  /// No description provided for @settingsDiscovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get settingsDiscovery;

  /// No description provided for @settingsScoutPreferences.
  ///
  /// In en, this message translates to:
  /// **'Scouting preferences'**
  String get settingsScoutPreferences;

  /// No description provided for @settingsScoutPreferencesActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get settingsScoutPreferencesActive;

  /// No description provided for @settingsScoutPreferencesInactive.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get settingsScoutPreferencesInactive;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsSecurity.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get settingsSecurity;

  /// No description provided for @settingsUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get settingsUpdatePassword;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingsLanguageEnglish;

  /// No description provided for @settingsLanguageAmharic.
  ///
  /// In en, this message translates to:
  /// **'አማርኛ'**
  String get settingsLanguageAmharic;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacyPolicyDescription.
  ///
  /// In en, this message translates to:
  /// **'How we collect, use, and protect your data.'**
  String get settingsPrivacyPolicyDescription;

  /// No description provided for @settingsPrivacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'Goal Connect respects your privacy.\n\nWhat we collect\nWe collect the information you provide when you create an account (name, email, role, profile photo), the content you upload (highlight videos, captions, messages), and basic usage data needed to keep the service running.\n\nHow we use it\nYour information is used to operate Goal Connect: to show your profile and highlights to other users, to deliver messages between players and scouts, to power personalized scouting feeds, and to keep the platform safe.\n\nSharing\nWe do not sell your personal data. Player profiles and highlights are visible to other authenticated users by design. Direct messages are visible only to the participants.\n\nYour choices\nYou can edit or delete your highlights and messages, update your profile, or request account deletion from the app. Sign out anytime to stop sharing further activity.\n\nContact\nFor privacy questions or data requests, contact the Goal Connect team via the address listed in About.'**
  String get settingsPrivacyPolicyBody;

  /// No description provided for @settingsTermsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTermsOfService;

  /// No description provided for @settingsTermsOfServiceDescription.
  ///
  /// In en, this message translates to:
  /// **'The rules and conditions for using the app.'**
  String get settingsTermsOfServiceDescription;

  /// No description provided for @settingsTermsOfServiceBody.
  ///
  /// In en, this message translates to:
  /// **'Welcome to Goal Connect.\n\nUsing the app\nGoal Connect connects football players with scouts and academies. You must be old enough to consent to processing of your data in your country. Keep your login credentials private.\n\nYour content\nYou keep ownership of the highlights, photos, and messages you upload. By uploading you grant Goal Connect a limited license to host, display, and deliver that content to other users of the platform as part of the normal operation of the app.\n\nAcceptable use\nDo not upload content you do not have the right to share. Do not harass, impersonate, or attempt to deceive scouts, academies, or other players. Do not abuse the messaging system. We may remove content or suspend accounts that violate these rules.\n\nLiability\nGoal Connect provides the platform as-is. We do not guarantee a tryout, contract, or signing of any kind. Goal Connect is not responsible for off-platform interactions between users.\n\nChanges\nWe may update these terms as the product evolves. Continued use of the app after an update means you accept the updated terms.'**
  String get settingsTermsOfServiceBody;

  /// No description provided for @settingsHelpSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get settingsHelpSupport;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About GoalConnect'**
  String get settingsAbout;

  /// No description provided for @settingsAboutBody.
  ///
  /// In en, this message translates to:
  /// **'GoalConnect is a platform that connects Ethiopian footballers with scouts, academies, and clubs across the country. Players can share match highlights, showcase their stats and playing style, and grow a profile that scouts can discover. Scouts can filter talent by position, region, and age, save players they like, and reach out directly through in-app chat. Our goal is simple: open more doors for the next generation of football talent.'**
  String get settingsAboutBody;

  /// No description provided for @settingsAboutClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsAboutClose;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get settingsSignOut;

  /// No description provided for @settingsBrand.
  ///
  /// In en, this message translates to:
  /// **'GoalConnect'**
  String get settingsBrand;

  /// No description provided for @settingsProfileSampleUsername.
  ///
  /// In en, this message translates to:
  /// **'EthioStar_10'**
  String get settingsProfileSampleUsername;

  /// No description provided for @settingsProfileSamplePosition.
  ///
  /// In en, this message translates to:
  /// **'FORWARD'**
  String get settingsProfileSamplePosition;

  /// No description provided for @settingsProfileSampleCountry.
  ///
  /// In en, this message translates to:
  /// **'Ethiopia'**
  String get settingsProfileSampleCountry;

  /// No description provided for @updatePasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Update password'**
  String get updatePasswordTitle;

  /// No description provided for @updatePasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You\'ll stay signed in on this device.'**
  String get updatePasswordSubtitle;

  /// No description provided for @updatePasswordCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get updatePasswordCurrent;

  /// No description provided for @updatePasswordNew.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get updatePasswordNew;

  /// No description provided for @updatePasswordConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get updatePasswordConfirm;

  /// No description provided for @updatePasswordEnterCurrent.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password'**
  String get updatePasswordEnterCurrent;

  /// No description provided for @updatePasswordMinChars.
  ///
  /// In en, this message translates to:
  /// **'At least 6 characters'**
  String get updatePasswordMinChars;

  /// No description provided for @updatePasswordMismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get updatePasswordMismatch;

  /// No description provided for @updatePasswordSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get updatePasswordSuccess;

  /// No description provided for @updatePasswordFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not update password'**
  String get updatePasswordFailure;

  /// No description provided for @scoutPreferencesTitle.
  ///
  /// In en, this message translates to:
  /// **'Scouting preferences'**
  String get scoutPreferencesTitle;

  /// No description provided for @scoutPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick what you want to see in your highlights feed. All fields are optional — leave any blank to skip that filter.'**
  String get scoutPreferencesSubtitle;

  /// No description provided for @scoutPreferencesPositions.
  ///
  /// In en, this message translates to:
  /// **'Positions'**
  String get scoutPreferencesPositions;

  /// No description provided for @scoutPreferencesRegions.
  ///
  /// In en, this message translates to:
  /// **'Regions'**
  String get scoutPreferencesRegions;

  /// No description provided for @scoutPreferencesRegionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Addis Ababa'**
  String get scoutPreferencesRegionHint;

  /// No description provided for @scoutPreferencesRegionAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get scoutPreferencesRegionAdd;

  /// No description provided for @scoutPreferencesAgeRange.
  ///
  /// In en, this message translates to:
  /// **'Age range'**
  String get scoutPreferencesAgeRange;

  /// No description provided for @scoutPreferencesAgeMin.
  ///
  /// In en, this message translates to:
  /// **'Min age'**
  String get scoutPreferencesAgeMin;

  /// No description provided for @scoutPreferencesAgeMax.
  ///
  /// In en, this message translates to:
  /// **'Max age'**
  String get scoutPreferencesAgeMax;

  /// No description provided for @scoutPreferencesSave.
  ///
  /// In en, this message translates to:
  /// **'Save preferences'**
  String get scoutPreferencesSave;

  /// No description provided for @scoutPreferencesClear.
  ///
  /// In en, this message translates to:
  /// **'Clear preferences'**
  String get scoutPreferencesClear;

  /// No description provided for @scoutPreferencesSaved.
  ///
  /// In en, this message translates to:
  /// **'Preferences saved'**
  String get scoutPreferencesSaved;

  /// No description provided for @scoutPreferencesCleared.
  ///
  /// In en, this message translates to:
  /// **'Preferences cleared'**
  String get scoutPreferencesCleared;

  /// No description provided for @loginApplyAsPlayer.
  ///
  /// In en, this message translates to:
  /// **'Apply for the player'**
  String get loginApplyAsPlayer;

  /// No description provided for @playerAppAppBarTitle.
  ///
  /// In en, this message translates to:
  /// **'Apply as a player'**
  String get playerAppAppBarTitle;

  /// No description provided for @playerAppStepOf.
  ///
  /// In en, this message translates to:
  /// **'Step {current} of {total}'**
  String playerAppStepOf(int current, int total);

  /// No description provided for @playerAppStep1Title.
  ///
  /// In en, this message translates to:
  /// **'About you'**
  String get playerAppStep1Title;

  /// No description provided for @playerAppStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tell us who you are so the academy can identify you.'**
  String get playerAppStep1Subtitle;

  /// No description provided for @playerAppStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Where you live'**
  String get playerAppStep2Title;

  /// No description provided for @playerAppStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Helps scouts and academies reach you for trials.'**
  String get playerAppStep2Subtitle;

  /// No description provided for @playerAppStep3Title.
  ///
  /// In en, this message translates to:
  /// **'Your football info'**
  String get playerAppStep3Title;

  /// No description provided for @playerAppStep3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your positions and the academy you\'re applying to.'**
  String get playerAppStep3Subtitle;

  /// No description provided for @playerAppFullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get playerAppFullName;

  /// No description provided for @playerAppEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get playerAppEmail;

  /// No description provided for @playerAppNationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID / FAN number'**
  String get playerAppNationalId;

  /// No description provided for @playerAppAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get playerAppAge;

  /// No description provided for @playerAppPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get playerAppPhone;

  /// No description provided for @playerAppAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get playerAppAddress;

  /// No description provided for @playerAppRegion.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get playerAppRegion;

  /// No description provided for @playerAppCountry.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get playerAppCountry;

  /// No description provided for @playerAppPrimaryPosition.
  ///
  /// In en, this message translates to:
  /// **'Primary position'**
  String get playerAppPrimaryPosition;

  /// No description provided for @playerAppSecondaryPosition.
  ///
  /// In en, this message translates to:
  /// **'Secondary position (optional)'**
  String get playerAppSecondaryPosition;

  /// No description provided for @playerAppAcademy.
  ///
  /// In en, this message translates to:
  /// **'Academy you\'re applying to'**
  String get playerAppAcademy;

  /// No description provided for @playerAppAcademyPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Tap to choose an academy'**
  String get playerAppAcademyPlaceholder;

  /// No description provided for @playerAppAcademySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or region'**
  String get playerAppAcademySearchHint;

  /// No description provided for @playerAppAcademyEmpty.
  ///
  /// In en, this message translates to:
  /// **'No academies match your search.'**
  String get playerAppAcademyEmpty;

  /// No description provided for @playerAppAcademiesLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading academies…'**
  String get playerAppAcademiesLoading;

  /// No description provided for @playerAppAcademiesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Could not load academies.'**
  String get playerAppAcademiesEmpty;

  /// No description provided for @playerAppAdditionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Anything else? (optional)'**
  String get playerAppAdditionalInfo;

  /// No description provided for @playerAppAdditionalInfoHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. previous clubs, achievements, jersey preference'**
  String get playerAppAdditionalInfoHint;

  /// No description provided for @playerAppContinue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get playerAppContinue;

  /// No description provided for @playerAppBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get playerAppBack;

  /// No description provided for @playerAppSubmit.
  ///
  /// In en, this message translates to:
  /// **'SUBMIT APPLICATION'**
  String get playerAppSubmit;

  /// No description provided for @playerAppRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get playerAppRetry;

  /// No description provided for @playerAppFieldRequired.
  ///
  /// In en, this message translates to:
  /// **'{field} is required'**
  String playerAppFieldRequired(String field);

  /// No description provided for @playerAppEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get playerAppEmailInvalid;

  /// No description provided for @playerAppAgeInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid age'**
  String get playerAppAgeInvalid;

  /// No description provided for @playerAppAgeOutOfRange.
  ///
  /// In en, this message translates to:
  /// **'Age must be between 10 and 60'**
  String get playerAppAgeOutOfRange;

  /// No description provided for @playerAppErrorPickPrimary.
  ///
  /// In en, this message translates to:
  /// **'Please pick a primary position.'**
  String get playerAppErrorPickPrimary;

  /// No description provided for @playerAppErrorPickAcademy.
  ///
  /// In en, this message translates to:
  /// **'Please pick an academy.'**
  String get playerAppErrorPickAcademy;

  /// No description provided for @playerAppErrorPositionsMustDiffer.
  ///
  /// In en, this message translates to:
  /// **'Secondary position must differ from primary.'**
  String get playerAppErrorPositionsMustDiffer;

  /// No description provided for @playerAppSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Application submitted'**
  String get playerAppSubmittedTitle;

  /// No description provided for @playerAppSubmittedBody.
  ///
  /// In en, this message translates to:
  /// **'Thanks! We\'ll review your application and reach out to {email} once it\'s approved.'**
  String playerAppSubmittedBody(String email);

  /// No description provided for @playerAppSubmittedClose.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get playerAppSubmittedClose;

  /// No description provided for @announcementsTitle.
  ///
  /// In en, this message translates to:
  /// **'Announcements'**
  String get announcementsTitle;

  /// No description provided for @announcementsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load announcements'**
  String get announcementsLoadError;

  /// No description provided for @announcementsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get announcementsRetry;

  /// No description provided for @announcementsUntitled.
  ///
  /// In en, this message translates to:
  /// **'Announcement'**
  String get announcementsUntitled;

  /// No description provided for @announcementsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet'**
  String get announcementsEmptyTitle;

  /// No description provided for @announcementsEmptyBody.
  ///
  /// In en, this message translates to:
  /// **'Important updates from Goal Connect will show up on this page.'**
  String get announcementsEmptyBody;

  /// No description provided for @announcementsDismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get announcementsDismiss;

  /// No description provided for @announcementsMarkAsRead.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get announcementsMarkAsRead;

  /// No description provided for @aiPerformanceTitle.
  ///
  /// In en, this message translates to:
  /// **'AI performance'**
  String get aiPerformanceTitle;

  /// No description provided for @aiPerformanceBadge.
  ///
  /// In en, this message translates to:
  /// **'LIVE'**
  String get aiPerformanceBadge;

  /// No description provided for @aiPerformanceDistance.
  ///
  /// In en, this message translates to:
  /// **'Distance covered'**
  String get aiPerformanceDistance;

  /// No description provided for @aiPerformanceDistanceUnit.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get aiPerformanceDistanceUnit;

  /// No description provided for @aiPerformanceTopSpeed.
  ///
  /// In en, this message translates to:
  /// **'Top speed'**
  String get aiPerformanceTopSpeed;

  /// No description provided for @aiPerformanceSpeedUnit.
  ///
  /// In en, this message translates to:
  /// **'km/h'**
  String get aiPerformanceSpeedUnit;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'om'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'om':
      return AppLocalizationsOm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
