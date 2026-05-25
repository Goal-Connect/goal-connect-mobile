// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Oromo (`om`).
class AppLocalizationsOm extends AppLocalizations {
  AppLocalizationsOm([String locale = 'om']) : super(locale);

  @override
  String get appName => 'Goal Connect';

  @override
  String get appTagline => 'Taphaa bareedaaf jaalalaan hojjetame';

  @override
  String get navHighlights => 'Calaqqee';

  @override
  String get navSearch => 'Barbaadi';

  @override
  String get navSaved => 'Kuufamaa';

  @override
  String get navChat => 'Ergaa';

  @override
  String get navProfile => 'Profaayilii';

  @override
  String get noInternetTitle => 'Walqunnamtii Interneetii Hin Jiru';

  @override
  String get noInternetSubtitle => 'Walqunnamtii kee mirkaneessii ammas yaali';

  @override
  String get commonCancel => 'Haquu';

  @override
  String get commonSave => 'Kuusi';

  @override
  String get commonDelete => 'Balleessi';

  @override
  String get commonRetry => 'Ammas Yaali';

  @override
  String get commonTryAgain => 'Ammas yaali';

  @override
  String get commonReply => 'Deebisi';

  @override
  String get commonReset => 'Haaromsi';

  @override
  String get commonClear => 'Qulqulleessi';

  @override
  String get commonApply => 'Qulqulleessitoota fayyadami';

  @override
  String get commonNext => 'ITTI AANU';

  @override
  String get commonGetStarted => 'JALQABI';

  @override
  String get commonSkip => 'Darbi';

  @override
  String get commonLoading => 'Fe\'amaa jira…';

  @override
  String get onboardingPage1Title => 'Dandeettii Kee ';

  @override
  String get onboardingPage1Highlight => 'Agarsiisi';

  @override
  String get onboardingPage1Description =>
      'Mana dijitaalaa urjiilee Itoophiyaa ol-ka\'aniif. Profaayilii kee uumiitii addunyaan dandeettii kee haa argu.';

  @override
  String get onboardingPage2Title => 'Hubannoo Raawwii ';

  @override
  String get onboardingPage2Highlight => 'Ispoortii Barbaaduuf';

  @override
  String get onboardingPage2Description =>
      'Ispoortii barbaaddotaaf hubannoo raawwii waa\'ee taphataa.';

  @override
  String get onboardingPage3Title => 'Gara Abjuu Keetiitti ';

  @override
  String get onboardingPage3Highlight => 'Riqicha';

  @override
  String get onboardingPage3Description =>
      'Dandeettii naannoo kallattiidhaan akkaadaamiiwwanii fi ispoortii barbaaddota waliin walqabsiisuu. Imala kee asitti jalqaba.';

  @override
  String get loginHeadlineLine1 => 'Urjiilee Dargaggoo Walqabsiisi';

  @override
  String get loginHeadlineLine2Prefix => 'Abjuu ';

  @override
  String get loginHeadlineLine2Highlight => 'Isaaniif';

  @override
  String get loginWelcomeBack => 'Baga deebitee dhufte';

  @override
  String get loginContinueSubtitle => 'Itti fufuuf herrega keetti seeni';

  @override
  String get loginEmailLabel => 'Teessoo Imeelii';

  @override
  String get loginEmailRequired => 'Imeelii barbaachisaa';

  @override
  String get loginEmailInvalid => 'Imeelii sirrii galchi';

  @override
  String get loginPasswordLabel => 'Jecha Iccitii';

  @override
  String get loginPasswordRequired => 'Jecha iccitii barbaachisaa';

  @override
  String get loginForgotPassword => 'Jecha Iccitii Dagattanii?';

  @override
  String get loginButton => 'GARA HERREEGAATTI SEENI';

  @override
  String get loginOr => 'YKN';

  @override
  String get loginCreateScoutAccount => 'Herrega ispoortii barbaaduu uumi';

  @override
  String get scoutRegisterAppBarTitle => 'Herrega ispoortii barbaaduu iyyadhu';

  @override
  String scoutRegisterStepOf(int current, int total) {
    return 'Tarkaanfii $current / $total';
  }

  @override
  String get scoutRegisterStep1Title => 'Odeeffannoo herregaa';

  @override
  String get scoutRegisterStep1Subtitle =>
      'Odeeffannoo bu\'uuraa keessaan haa jalqabnu.';

  @override
  String get scoutRegisterStep2Title => 'Eenyummaa fi mirkanaa\'uu';

  @override
  String get scoutRegisterStep2Subtitle =>
      'Akka ispoortii barbaaduu galmaa\'eetti mirkaneessuuf nu gargaara.';

  @override
  String get scoutRegisterStep3Title => 'Daandii ogummaa';

  @override
  String get scoutRegisterStep3Subtitle =>
      'Waa\'ee hojii ispoortii barbaaduu keetii nutti himi.';

  @override
  String get scoutRegisterReview => 'Sakatta\'i';

  @override
  String get scoutRegisterReviewName => 'Maqaa';

  @override
  String get scoutRegisterReviewEmail => 'Imeelii';

  @override
  String get scoutRegisterReviewPhone => 'Bilbila';

  @override
  String get scoutRegisterReviewCountry => 'Biyya';

  @override
  String get scoutRegisterReviewLicence => 'Hayyama';

  @override
  String get scoutRegisterReviewUploaded => 'Ol kaa\'ame';

  @override
  String get scoutRegisterReviewNotUploaded => 'Hin kaa\'amne';

  @override
  String get scoutRegisterContinue => 'Itti fufi';

  @override
  String get scoutRegisterBack => 'Duuba';

  @override
  String scoutRegisterFieldRequired(String field) {
    return '$field barbaachisaa';
  }

  @override
  String get scoutRegisterMinChars => 'Yoo xinnaate qubeewwan 6';

  @override
  String get scoutRegisterEmailInvalid => 'Imeelii sirrii galchi';

  @override
  String get scoutRegisterTitle => 'Galmee ispoortii barbaaduu';

  @override
  String get scoutRegisterSubtitle =>
      'Odeeffannoo kee dhiyeessiitii suuraa hayyama ispoortii barbaaduu kee ifaan ol kaa\'i.';

  @override
  String get scoutRegisterFullName => 'Maqaa guutuu';

  @override
  String get scoutRegisterEmail => 'Imeelii';

  @override
  String get scoutRegisterPassword =>
      'Jecha iccitii (yoo xinnaate qubeewwan 6)';

  @override
  String get scoutRegisterNationalId =>
      'Eenyummeessaa Biyyaalessaa / Lakkoofsa FAN';

  @override
  String get scoutRegisterPhone => 'Lakkoofsa bilbilaa';

  @override
  String get scoutRegisterOrganization => 'Dhaabbata / kilaboo (filannoo)';

  @override
  String get scoutRegisterCountry => 'Biyya';

  @override
  String get scoutRegisterYearsExperience => 'Waggoota muuxannoo (filannoo)';

  @override
  String get scoutRegisterLicencePhoto => 'Suuraa hayyamaa';

  @override
  String get scoutRegisterUploadLicence => 'Suuraa hayyamaa ol kaa\'i';

  @override
  String get scoutRegisterChangeLicence => 'Suuraa hayyamaa jijjiiri';

  @override
  String get scoutRegisterPhotoSelected => 'Suuraan filatame';

  @override
  String get scoutRegisterSubmit => 'IYYADHU';

  @override
  String get highlightsCreateTitle => 'Calaqqee Uumi';

  @override
  String get highlightsCreateSubtitle =>
      'Ispoortii barbaaddotaaf sochii kee gaarii agarsiisi';

  @override
  String get highlightsRecordVideo => 'Viidiyoo Galmeessi';

  @override
  String highlightsRecordVideoSubtitle(int seconds) {
    return 'Kaameraa kee fayyadami · hanga sekondii $seconds';
  }

  @override
  String get highlightsChooseFromGallery => 'Galarii irraa Filadhu';

  @override
  String get highlightsChooseFromGallerySubtitle =>
      'Viidiyoo duraan jiru filadhu';

  @override
  String get highlightsProTipTitle => 'Yaada Beekkamtii';

  @override
  String get highlightsProTipBody =>
      'Kutaalee gadii sekondii 30 godhi, dandeettii tokko qofa calaqqee tokko keessatti agarsiisi.';

  @override
  String highlightsMaxSeconds(int seconds) {
    return 'Olaanaa sekondii $seconds';
  }

  @override
  String get highlightsTapToRecord => 'Galmeessuuf tuqi';

  @override
  String highlightsRecordingProgress(String elapsed, String total) {
    return 'Galmeessuu jira... $elapsed / $total';
  }

  @override
  String get highlightsCameraNotAvailable =>
      'Kaameraan meeshaa kana irratti hin argamu. Maaloo \"Galarii irraa Filadhu\" fayyadami.';

  @override
  String get highlightsCaptionHint => 'Ibsa barreessi...';

  @override
  String get highlightsRetake => 'Ammas Galmeessi';

  @override
  String get highlightsPost => 'Calaqqee Maxxansi';

  @override
  String get highlightsVisibleAfterPosting =>
      'Maxxansaa booda ispoortii barbaaddotaaf ni mul\'ata';

  @override
  String get highlightsUploading => 'Calaqqee ol kaa\'aa jira...';

  @override
  String get highlightsUploadingSubtitle =>
      'Kun yeroo xinnoo fudhachuu danda\'a';

  @override
  String get highlightsTopBarTitle => 'CALAQQEE HAARAA';

  @override
  String get highlightsSignInToUpload => 'Ol kaa\'uuf akka taphataatti seeni.';

  @override
  String get highlightsCouldNotLike => 'Jaalala haaromsuu hin dandeenye';

  @override
  String get highlightsNoHighlightsYet => 'Ammaaf calaqqeen hin jiru';

  @override
  String get videoOptionsTitle => 'Filannoowwan';

  @override
  String get videoOptionsEdit => 'Calaqqee gulaali';

  @override
  String get videoOptionsEditSubtitle =>
      'Mata-duree, ibsa, dhuunfaa, gosa shaakalii';

  @override
  String get videoOptionsDelete => 'Viidiyoo balleessi';

  @override
  String get videoOptionsDeleteSubtitle => 'Goal Connect irraa haqi';

  @override
  String get videoOptionsSave => 'Taphataa Kuusi';

  @override
  String get videoOptionsSaveSubtitle =>
      'Taphataa kana tarree kuufame keessatti dabali';

  @override
  String get videoOptionsCopyLink => 'Linkii fudhi';

  @override
  String get videoOptionsCopyLinkSubtitle => 'Linkiin qoodi';

  @override
  String get videoOptionsDownload => 'Buufadhu';

  @override
  String get videoOptionsDownloadSubtitle => 'Meeshaa irratti kuusi';

  @override
  String get videoOptionsNotInterested => 'Fedha Hin Qabu';

  @override
  String get videoOptionsNotInterestedSubtitle =>
      'Maxxansoota akkasii xinnoo arguu';

  @override
  String videoOptionsUnfollow(String username) {
    return '@$username hordofuu dhiisi';
  }

  @override
  String get videoOptionsUnfollowSubtitle => 'Calaqqee isaanii arguu dhaabi';

  @override
  String get videoOptionsReport => 'Gabaasi';

  @override
  String get videoOptionsReportSubtitle => 'Calaqqee kana gabaasi';

  @override
  String videoOptionsBlock(String username) {
    return '@$username ugguri';
  }

  @override
  String get videoOptionsBlockSubtitle => 'Profaayilii kee arguu hin danda\'an';

  @override
  String videoOptionsUnfollowed(String username) {
    return '@$username hin hordofamne';
  }

  @override
  String videoOptionsBlocked(String username) {
    return '@$username uggurame';
  }

  @override
  String get videoOptionsLinkCopied => 'Linkiin fudhatame';

  @override
  String get videoOptionsVideoSaved => 'Taphataan kuufame';

  @override
  String get videoOptionsShowFewer => 'Akkasii xinnoo siif agarsiisna';

  @override
  String get videoOptionsReportSubmitted => 'Gabaasni dhiyaate';

  @override
  String get videoEditTitle => 'Calaqqee gulaali';

  @override
  String get videoEditFieldTitle => 'Mata-duree';

  @override
  String get videoEditFieldDescription => 'Ibsa';

  @override
  String get videoEditFieldPrivacy => 'Dhuunfaa';

  @override
  String get videoEditPrivacyPublic => 'ifaa';

  @override
  String get videoEditPrivacyPrivate => 'dhuunfaa';

  @override
  String get videoEditFieldDrillType => 'Gosa shaakalii';

  @override
  String get videoEditCouldNotUpdate => 'Viidiyoo haaromsuu hin dandeenye';

  @override
  String get videoEditUpdated => 'Viidiyoon haaromfame';

  @override
  String get videoDeleteTitle => 'Viidiyoo balleessuu?';

  @override
  String get videoDeleteMessage =>
      'Viidiyoo kana Goal Connect irraa balleessuuf mirkanaa\'ee jirtaa?';

  @override
  String get videoDeleteCouldNotDelete => 'Viidiyoo balleessuu hin dandeenye';

  @override
  String get videoDeleted => 'Viidiyoon ballaa\'e';

  @override
  String get downloadNotSupportedOnWeb =>
      'Buufamuu marsariitii irratti hin deeggaramne';

  @override
  String get downloadInProgress => 'Viidiyoo buufachaa jira...';

  @override
  String get downloadSavedToFolder =>
      'Viidiyoon faayilii GoalConnect keessatti kuufame';

  @override
  String get downloadFailed => 'Buufachuun hin milkoofne. Maaloo ammas yaali.';

  @override
  String get downloadUnavailable => 'Viidiyoon hin argamu';

  @override
  String get downloadSavedToGallery => 'Galarii kee keessatti kuufame';

  @override
  String get downloadCouldNotDownload => 'Viidiyoo buufachuu hin dandeenye';

  @override
  String get downloadLabel => 'Buufadhu';

  @override
  String get reportSheetTitle => 'Calaqqee Gabaasi';

  @override
  String get reportSheetQuestion => 'Maaliif calaqqee kana gabaasaa jirta?';

  @override
  String get reportSheetSubmit => 'Gabaasa Galchi';

  @override
  String get reportReasonSpam => 'Sipaamii ykn dogoggorsuu';

  @override
  String get reportReasonInappropriate => 'Qabiyyee hin malle';

  @override
  String get reportReasonHarassment => 'Rakkisuu ykn doorsisa';

  @override
  String get reportReasonViolence => 'Jeequmsa ykn gocha balaa qabu';

  @override
  String get reportReasonFake => 'Calaqqee sobaa ykn gulaalame';

  @override
  String get reportReasonIp => 'Sarbamuu mirga qabiyyee';

  @override
  String get reportReasonOther => 'Kan biraa';

  @override
  String get reportSubmitFailed =>
      'Gabaasa ergu hin dandeenye. Maaloo irra deebi\'ii yaali.';

  @override
  String get commentsTitle => 'Yaadota';

  @override
  String get commentsAddHint => 'Yaada dabali…';

  @override
  String get commentsReplyHint => 'Deebii barreessi…';

  @override
  String commentsReplyingTo(String username) {
    return '@${username}f deebisaa jira';
  }

  @override
  String get commentsEmptyTitle => 'Ammaaf yaadni hin jiru';

  @override
  String get commentsEmptySubtitle => 'Yaada kee qooduuf jalqabaa ta\'i!';

  @override
  String get commentsJustNow => 'amma';

  @override
  String get saveActionSave => 'Kuusi';

  @override
  String get saveActionSaved => 'Kuufame';

  @override
  String get saveActionPending => '…';

  @override
  String get chatListTitle => 'Ergaawwan';

  @override
  String get chatListSubtitle => 'Ispoortii barbaaddonni asitti si qunnamu';

  @override
  String get chatListSearchHint => 'Mariiwwan barbaadi...';

  @override
  String get chatListLoading => 'Mariiwwan fe\'amaa jiru...';

  @override
  String get chatListConnectionIssue => 'Rakkoo walqunnamtii';

  @override
  String get chatListNoResults => 'Bu\'aa hin argamne';

  @override
  String get chatListTryDifferentSearch => 'Jecha barbaachaa biraa yaali';

  @override
  String get chatListEmptyTitle => 'Ammaaf mariin hin jiru';

  @override
  String get chatListEmptySubtitle =>
      'Yeroo ispoortii barbaaddonni ergaa sii ergan,\nasitti ni mul\'atu';

  @override
  String get chatConversationActiveNow => 'Amma sochii keessa jira';

  @override
  String get chatConversationInputHint => 'Ergaa barreessi…';

  @override
  String get chatMessageActionCopy => 'Garagalchi';

  @override
  String get chatMessageActionEdit => 'Sirreessi';

  @override
  String get chatMessageActionDelete => 'Haqi';

  @override
  String get chatMessageCopied => 'Ergaan garagalfameera';

  @override
  String get chatMessageEditTitle => 'Ergaa sirreessi';

  @override
  String get chatMessageDeleteTitle => 'Ergaa haqi';

  @override
  String get chatMessageDeleteConfirm =>
      'Ergaan kun haasaa kana keessaa nama hundaaf ni haqama.';

  @override
  String get chatConversationStartTitle => 'Mari\'achuu jalqabi';

  @override
  String chatConversationStartSubtitle(String name) {
    return '${name}f nagaa jedhi!';
  }

  @override
  String get chatConversationUnableToLoad => 'Ergaawwan fe\'uu hin dandeenye';

  @override
  String get chatDateToday => 'Har\'a';

  @override
  String get chatDateYesterday => 'Kaleessa';

  @override
  String get chatTimeNow => 'amma';

  @override
  String chatTimeMinutes(int minutes) {
    return 'daq $minutes';
  }

  @override
  String chatTimeHours(int hours) {
    return 'sa $hours';
  }

  @override
  String chatTimeDays(int days) {
    return 'guy $days';
  }

  @override
  String chatTimeWeeks(int weeks) {
    return 'tor $weeks';
  }

  @override
  String get searchTitle => 'Barbaadi';

  @override
  String get searchPlayersHint => 'Taphattoota barbaadi…';

  @override
  String get searchNoPlayersToShow => 'Ammaaf taphataan agarsiifamu hin jiru.';

  @override
  String get searchEmptyHint =>
      'Taphattoota argachuuf maqaadhaan barbaadi ykn qulqulleessitoota fayyadami.';

  @override
  String get searchResults => 'Bu\'aawwan';

  @override
  String searchNoMatchQuery(String query) {
    return 'Taphataan \"$query\" waliin walsimu hin jiru.';
  }

  @override
  String get searchNoMatchFilters =>
      'Taphataan qulqulleessitoota filataman waliin walsimu hin jiru.';

  @override
  String get searchPlayersSection => 'Taphattoota';

  @override
  String get searchTabPlayers => 'Taphattoota';

  @override
  String get searchTabAcademies => 'Akkaadaamiiwwan';

  @override
  String get academiesSearchHint => 'Akkaadaamiiwwan barbaadi…';

  @override
  String get academiesNoResults =>
      'Akkaadaamiin barbaada kee waliin walqabatu hin jiru.';

  @override
  String get academiesEmpty =>
      'Hanga ammaatti akkaadaamiin mirkanaa\'e hin jiru.';

  @override
  String get academiesLoadFailed =>
      'Akkaadaamiiwwan fe\'uun hin danda\'amne. Irra deebi\'iiti yaali.';

  @override
  String academiesPlayersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Taphattoota $count',
      one: 'Taphataa 1',
      zero: 'Hanga ammaatti taphataan hin jiru',
    );
    return '$_temp0';
  }

  @override
  String get academiesMessage => 'Ergaa ergi';

  @override
  String get academiesChatUnavailable =>
      'Akkaadaamiin kun ammaaf abbaa qunnamamuu hin qabu.';

  @override
  String get academiesRegionAll => 'Naannolee hunda';

  @override
  String get academiesRegionFilterTitle => 'Naannoodhaan calali';

  @override
  String get filtersTitle => 'Taphattoota qulqulleessi';

  @override
  String get filtersPosition => 'Iddoo';

  @override
  String get filtersStrongFoot => 'Miila cimaa';

  @override
  String get filtersAge => 'Umrii';

  @override
  String get filtersHeightCm => 'Dheerina (sm)';

  @override
  String get filtersMin => 'Xiqqaa';

  @override
  String get filtersMax => 'Olaanaa';

  @override
  String get filtersPositionGoalkeeper => 'Eegduu Goolii';

  @override
  String get filtersPositionDefender => 'Ittisaa';

  @override
  String get filtersPositionMidfielder => 'Gidduu';

  @override
  String get filtersPositionForward => 'Lolaa';

  @override
  String get filtersFootLeft => 'Bitaa';

  @override
  String get filtersFootRight => 'Mirga';

  @override
  String get filtersFootBoth => 'Lamaanuu';

  @override
  String filtersChipFoot(String foot) {
    return 'miila $foot';
  }

  @override
  String filtersChipAge(String min, String max) {
    return 'Umrii $min–$max';
  }

  @override
  String filtersChipHeight(String min, String max) {
    return 'Dheerina $min–$max sm';
  }

  @override
  String get savedPlayersTitle => 'Taphattoota kuufaman';

  @override
  String get savedPlayersSubtitle => 'Taphattoota hordofaa jirtu';

  @override
  String savedPlayersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count kuufaman',
      one: '1 kuufame',
    );
    return '$_temp0';
  }

  @override
  String get savedPlayersEmptyTitle => 'Ammaaf taphataan kuufame hin jiru';

  @override
  String get savedPlayersEmptySubtitle =>
      'Daddaffiidhaan argachuuf barbaaduu irraa taphattoota mallatteessi.';

  @override
  String get savedPlayersRemoveTooltip => 'Kuufamaa irraa haqi';

  @override
  String get savedPlayersStatHighlights => 'Calaqqeewwan';

  @override
  String get savedPlayersStatFollowers => 'Hordoftoota';

  @override
  String get savedPlayersStatLikes => 'Jaalalaa';

  @override
  String get playerProfileVideos => 'Viidiyoowwan';

  @override
  String get playerProfileGoals => 'Goolii';

  @override
  String get playerProfileAssists => 'Gargaarsa';

  @override
  String get playerProfileMatches => 'Walitti Qabamuu';

  @override
  String get playerProfileHighlights => 'Calaqqeewwan';

  @override
  String get playerProfileFollowers => 'Hordoftoota';

  @override
  String get playerProfileFollowing => 'Hordofamaa';

  @override
  String get playerProfileLikes => 'Jaalala';

  @override
  String get playerProfilePlayerInfo => 'Odeeffannoo Taphataa';

  @override
  String get playerProfileAge => 'Umrii';

  @override
  String get playerProfileHeight => 'Dheerina';

  @override
  String get playerProfileWeight => 'Ulfaatina';

  @override
  String get playerProfileFoot => 'Miila';

  @override
  String get playerProfileJersey => 'Jarsii';

  @override
  String get playerProfilePosition => 'Iddoo';

  @override
  String get playerProfileSecondary => 'Lammaffaa';

  @override
  String get playerProfileNationality => 'Lammummaa';

  @override
  String get playerProfileDob => 'Guyyaa Dhalootaa';

  @override
  String get playerProfileCurrentClub => 'Kilaboo Ammaa';

  @override
  String get playerProfilePlayingStyle => 'Tooftaa taphachuu';

  @override
  String get playerProfileClubHistory => 'Seenaa kilaboo';

  @override
  String get playerProfileDisciplinary => 'Galmee qajeelfama';

  @override
  String get playerProfileYellowCards => 'Kaardiiwwan keelloo';

  @override
  String get playerProfileRedCards => 'Kaardiiwwan diimaa';

  @override
  String get playerProfileAbilityStats => 'Istaatistiksii Dandeettii';

  @override
  String playerProfileOverall(int value) {
    return 'Walumaagala $value';
  }

  @override
  String get playerProfilePace => 'Saffisa';

  @override
  String get playerProfileShooting => 'Rukutuu';

  @override
  String get playerProfilePassing => 'Dabarsuu';

  @override
  String get playerProfileDribbling => 'Diriibilii';

  @override
  String get playerProfileDefending => 'Ittisuu';

  @override
  String get playerProfilePhysical => 'Qaamaa';

  @override
  String get playerProfileMatchRecord => 'Galmee Walitti Qabamuu';

  @override
  String get currentUserProfileUserInfo => 'Odeeffannoo Fayyadamaa';

  @override
  String get currentUserProfileEmail => 'Imeelii';

  @override
  String get currentUserProfileRole => 'Gahee';

  @override
  String get currentUserProfileName => 'Maqaa';

  @override
  String get currentUserProfileOrganization => 'Dhaabbata';

  @override
  String get currentUserProfilePhone => 'Bilbila';

  @override
  String get currentUserProfileCountry => 'Biyya';

  @override
  String get currentUserProfileScoutingPreferences =>
      'Filannoowwan ispoortii barbaaduu';

  @override
  String get currentUserProfileNoPreferences => 'Ammaaf filannoon hin qabamne';

  @override
  String get currentUserProfileAgeRange => 'Hangii umrii';

  @override
  String currentUserProfileAgeRangeValue(String lo, String hi) {
    return '$lo – $hi waggoota';
  }

  @override
  String get currentUserProfilePositions => 'Iddoowwan';

  @override
  String get currentUserProfileRegions => 'Naannoowwan';

  @override
  String get currentUserProfileSaved => 'Kuufame';

  @override
  String get currentUserProfileRecentlyViewed => 'Dhiyeenyatti ilaalaman';

  @override
  String get currentUserProfileDocuments => 'Galmeewwan';

  @override
  String get currentUserProfileDetails => 'Ibsoota Taphataa';

  @override
  String get currentUserProfileStrongFoot => 'Miila cimaa';

  @override
  String get currentUserProfileDateOfBirth => 'Guyyaa dhalootaa';

  @override
  String get currentUserProfileAvailability => 'Argamuu';

  @override
  String get currentUserProfileVerification => 'Mirkanaa\'uu';

  @override
  String get currentUserProfileMinutes => 'Daqiiqaawwan';

  @override
  String get currentUserProfileYourHighlights => 'Calaqqeewwan Kee';

  @override
  String get currentUserProfileRadarGoals => 'GOOLII';

  @override
  String get currentUserProfileRadarAssists => 'GARGAARSA';

  @override
  String get currentUserProfileRadarMatches => 'WALITTI QABAMUU';

  @override
  String get currentUserProfileRadarMinutes => 'DAQIIQAA';

  @override
  String get currentUserProfileRadarHeight => 'DHEERINA';

  @override
  String get currentUserProfileRadarDiscipline => 'QAJEELFAMA';

  @override
  String get currentUserProfileCardYellow => 'Keelloo';

  @override
  String get currentUserProfileCardRed => 'Diimaa';

  @override
  String get settingsAppVersion => 'v1.0.0';

  @override
  String get settingsTitle => 'Sajoo';

  @override
  String get settingsSubtitle => 'Muuxannoo GoalConnect kee qopheessi';

  @override
  String get settingsDiscovery => 'Argachuu';

  @override
  String get settingsScoutPreferences => 'Filannoo skouutii';

  @override
  String get settingsScoutPreferencesActive => 'Hojjeta';

  @override
  String get settingsScoutPreferencesInactive => 'Hin qopheeffamne';

  @override
  String get settingsAppearance => 'Mul\'achuu';

  @override
  String get settingsThemeLight => 'Ifaa';

  @override
  String get settingsThemeDark => 'Dukkana';

  @override
  String get settingsThemeSystem => 'Sirna';

  @override
  String get settingsSecurity => 'Nageenya';

  @override
  String get settingsUpdatePassword => 'Jecha iccitii haaromsi';

  @override
  String get settingsAccount => 'Herrega';

  @override
  String get settingsLanguage => 'Afaan';

  @override
  String get settingsLanguageEnglish => 'English';

  @override
  String get settingsLanguageAmharic => 'አማርኛ';

  @override
  String get settingsPrivacyPolicy => 'Imaammata Dhuunfaa';

  @override
  String get settingsPrivacyPolicyDescription =>
      'Akkaataa odeeffannoo kee itti walitti qabnu, itti fayyadamnuu fi itti eegnu.';

  @override
  String get settingsPrivacyPolicyBody =>
      'Goal Connect dhuunfaa kee ni kabaja.\n\nMaal akka walitti qabnu\nYeroo akkaawuntii uumtu odeeffannoo nuuf kennitu (maqaa, imeelii, gahee, suuraa profaayilii), waan ol kaaftu (viidiyoo agarsiisaa, ibsa gabaabaa, ergaa) fi odeeffannoo fayyadamaa bu’uuraa tajaajilicha geggeessuuf nu barbaachisu ni walitti qabna.\n\nAkkamitti itti fayyadamna\nOdeeffannoon kee Goal Connect geggeessuuf, profaayilii fi agarsiisawwan kee fayyadamtoota biroof mul’isuuf, ergaa taphattootaa fi scoutota gidduutti dabarsuuf, feeda scouting dhuunfaa hojjechiisuuf fi platform nageenya isaa eeguuf hojiirra oola.\n\nWaliin qoodu\nOdeeffannoo dhuunfaa kee hin gurgurru. Profaayilii fi agarsiisawwan taphattootaa fayyadamtoota galmaa’an biroof ni mul’atu. Ergaawwan kallattii nama lamaan keessa jiraniif qofa mul’atu.\n\nFilannoowwan kee\nAgarsiisawwan kee fi ergaawwan kee gulaaluu yookin haquu, profaayilii kee haaromsuu yookin akkaawuntiin kee akka haqamu gaafachuu ni dandeessa.\n\nNu qunnamuu\nGaaffii dhuunfaaf qaama nu qunnamuu kutaa Waa’ee jalatti tarreeffame fayyadami.';

  @override
  String get settingsTermsOfService => 'Haalota Tajaajilaa';

  @override
  String get settingsTermsOfServiceDescription =>
      'Seerotaa fi haalota appii kana itti fayyadamuuf barbaachisan.';

  @override
  String get settingsTermsOfServiceBody =>
      'Baga gara Goal Connect dhufte.\n\nAppii fayyadamuu\nGoal Connect taphattoota kubbaa miilaa scoutota fi akkaadaamiiwwan waliin walqunnamsiisa. Biyya kee keessatti odeeffannoon kee akka qophaa’u eeyyamuuf umurii gaheessa qabaachuu qabda. Odeeffannoo seensa kee dhoksaadhaan eegi.\n\nWaan kee\nAgarsiisawwan, suuraawwan fi ergaawwan ol kaaftu kan kee taʼanii itti fufu. Goal Connect waan kana qabachuuf, mul’isuuf fi fayyadamtoota biroof dhiyeessuuf hayyama murtaaʼaa nuuf kennita.\n\nFayyadama fudhatamu\nWaan mirga qoodu hin qabne hin ol kaaʼin. Scoutota, akkaadaamiiwwan yookin taphattoota biroo hin rakkisin, fakkeessitee hin dhiyaatin, ergaa hin sobsiisin. Sirna ergaa hin badisiisin. Akkaawuntiiwwan seerota kana cabsan keessaa qabiyyee haquu yookin akkaawuntii ugguruu dandeenya.\n\nItti gaafatamummaa\nGoal Connect platform akkuma jirutti dhiyeessa. Yaaliis taʼe walii galtee yookin mallattoo waliigaltee dhugaa hin waadaa galu. Walqunnamtii fayyadamtootaa platform alaa keessatti hin gaafatamnu.\n\nJijjiirama\nMaddi yeroo guddatuu ka’u haalota kana haaromsuu dandeenya. Erga haaromsame booda appiicha itti fufte fayyadamuu jechuun haalota haaromsame fudhattee jechuudha.';

  @override
  String get settingsHelpSupport => 'Gargaarsa fi Deeggarsa';

  @override
  String get settingsAbout => 'Waa\'ee GoalConnect';

  @override
  String get settingsAboutBody =>
      'GoalConnect platformii kubbaa miilaa Itoophiyaa skaawutoota, akkaadaamii fi kilaboota biyya keessaa waliin walqunnamsiisuuf hojjetamedha. Taphattoonni qabxiilee tapha isaanii qooduu, istaatistiksii fi haala tapha isaanii agarsiisuu, akkasumas pirofaayilii skaawutoonni argachuu danda\'an ijaaruu danda\'u. Skaawutoonni dabareedhaan, naannoodhaan fi umuriidhaan dandeettii filachuu, taphattoota jaalatan kuusuu, akkasumas chaatii appii keessaatiin kallattiidhaan dubbisuu danda\'u. Galmi keenya salphaadha: dhaloota itti aanaaf carraa kubbaa miilaa caalaa banuu.';

  @override
  String get settingsAboutClose => 'Cufi';

  @override
  String get settingsSignOut => 'Ba\'i';

  @override
  String get settingsBrand => 'GoalConnect';

  @override
  String get settingsProfileSampleUsername => 'EthioStar_10';

  @override
  String get settingsProfileSamplePosition => 'LOLAA';

  @override
  String get settingsProfileSampleCountry => 'Itoophiyaa';

  @override
  String get updatePasswordTitle => 'Jecha iccitii haaromsi';

  @override
  String get updatePasswordSubtitle => 'Meeshaa kana irratti seentee turta.';

  @override
  String get updatePasswordCurrent => 'Jecha iccitii ammaa';

  @override
  String get updatePasswordNew => 'Jecha iccitii haaraa';

  @override
  String get updatePasswordConfirm => 'Jecha iccitii haaraa mirkaneessi';

  @override
  String get updatePasswordEnterCurrent => 'Jecha iccitii ammaa kee galchi';

  @override
  String get updatePasswordMinChars => 'Yoo xinnaate qubeewwan 6';

  @override
  String get updatePasswordMismatch => 'Jecha iccitii walhin simu';

  @override
  String get updatePasswordSuccess => 'Jecha iccitii milkaa\'inaan haaromfame';

  @override
  String get updatePasswordFailure => 'Jecha iccitii haaromsuu hin dandeenye';

  @override
  String get scoutPreferencesTitle => 'Filannoo skouutii';

  @override
  String get scoutPreferencesSubtitle =>
      'Maal akka feedii kee keessatti agartu fili. Dirreewwan hundi filannoo dha — duwwaa dhiisuun walitti hidhamiinsa sana dabarsa.';

  @override
  String get scoutPreferencesPositions => 'Iddoowwan';

  @override
  String get scoutPreferencesRegions => 'Naannoowwan';

  @override
  String get scoutPreferencesRegionHint => 'fkn. Finfinnee';

  @override
  String get scoutPreferencesRegionAdd => 'Dabali';

  @override
  String get scoutPreferencesAgeRange => 'Daangaa umurii';

  @override
  String get scoutPreferencesAgeMin => 'Xiqqaa';

  @override
  String get scoutPreferencesAgeMax => 'Guddaa';

  @override
  String get scoutPreferencesSave => 'Filannoo olkaa\'i';

  @override
  String get scoutPreferencesClear => 'Filannoo haqi';

  @override
  String get scoutPreferencesSaved => 'Filannoon olkaa\'ame';

  @override
  String get scoutPreferencesCleared => 'Filannoon haqame';

  @override
  String get loginApplyAsPlayer => 'Apply for the player';

  @override
  String get playerAppAppBarTitle => 'Apply as a player';

  @override
  String playerAppStepOf(int current, int total) {
    return 'Step $current of $total';
  }

  @override
  String get playerAppStep1Title => 'About you';

  @override
  String get playerAppStep1Subtitle =>
      'Tell us who you are so the academy can identify you.';

  @override
  String get playerAppStep2Title => 'Where you live';

  @override
  String get playerAppStep2Subtitle =>
      'Helps scouts and academies reach you for trials.';

  @override
  String get playerAppStep3Title => 'Your football info';

  @override
  String get playerAppStep3Subtitle =>
      'Pick your positions and the academy you\'re applying to.';

  @override
  String get playerAppFullName => 'Full name';

  @override
  String get playerAppEmail => 'Email';

  @override
  String get playerAppNationalId => 'National ID / FAN number';

  @override
  String get playerAppAge => 'Age';

  @override
  String get playerAppPhone => 'Phone number';

  @override
  String get playerAppAddress => 'Address';

  @override
  String get playerAppRegion => 'Region';

  @override
  String get playerAppCountry => 'Country';

  @override
  String get playerAppPrimaryPosition => 'Primary position';

  @override
  String get playerAppSecondaryPosition => 'Secondary position (optional)';

  @override
  String get playerAppAcademy => 'Academy you\'re applying to';

  @override
  String get playerAppAcademyPlaceholder => 'Tap to choose an academy';

  @override
  String get playerAppAcademySearchHint => 'Search by name or region';

  @override
  String get playerAppAcademyEmpty => 'No academies match your search.';

  @override
  String get playerAppAcademiesLoading => 'Loading academies…';

  @override
  String get playerAppAcademiesEmpty => 'Could not load academies.';

  @override
  String get playerAppAdditionalInfo => 'Anything else? (optional)';

  @override
  String get playerAppAdditionalInfoHint =>
      'e.g. previous clubs, achievements, jersey preference';

  @override
  String get playerAppContinue => 'Continue';

  @override
  String get playerAppBack => 'Back';

  @override
  String get playerAppSubmit => 'SUBMIT APPLICATION';

  @override
  String get playerAppRetry => 'Retry';

  @override
  String playerAppFieldRequired(String field) {
    return '$field is required';
  }

  @override
  String get playerAppEmailInvalid => 'Enter a valid email';

  @override
  String get playerAppAgeInvalid => 'Enter a valid age';

  @override
  String get playerAppAgeOutOfRange => 'Age must be between 10 and 60';

  @override
  String get playerAppErrorPickPrimary => 'Please pick a primary position.';

  @override
  String get playerAppErrorPickAcademy => 'Please pick an academy.';

  @override
  String get playerAppErrorPositionsMustDiffer =>
      'Secondary position must differ from primary.';

  @override
  String get playerAppSubmittedTitle => 'Application submitted';

  @override
  String playerAppSubmittedBody(String email) {
    return 'Thanks! We\'ll review your application and reach out to $email once it\'s approved.';
  }

  @override
  String get playerAppSubmittedClose => 'Got it';

  @override
  String get announcementsTitle => 'Announcements';

  @override
  String get announcementsLoadError => 'Could not load announcements';

  @override
  String get announcementsRetry => 'Retry';

  @override
  String get announcementsUntitled => 'Announcement';

  @override
  String get announcementsEmptyTitle => 'Nothing here yet';

  @override
  String get announcementsEmptyBody =>
      'Important updates from Goal Connect will show up on this page.';

  @override
  String get announcementsDismiss => 'Dismiss';

  @override
  String get announcementsMarkAsRead => 'Mark as read';

  @override
  String get aiPerformanceTitle => 'AI performance';

  @override
  String get aiPerformanceBadge => 'LIVE';

  @override
  String get aiPerformanceDistance => 'Distance covered';

  @override
  String get aiPerformanceDistanceUnit => 'm';

  @override
  String get aiPerformanceTopSpeed => 'Top speed';

  @override
  String get aiPerformanceSpeedUnit => 'km/h';
}
