import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_he.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('he'),
  ];

  /// Fruit type: Olive
  ///
  /// In en, this message translates to:
  /// **'Olive'**
  String get fruitTypeOlive;

  /// Fruit type: Almond
  ///
  /// In en, this message translates to:
  /// **'Almond'**
  String get fruitTypeAlmond;

  /// Fruit type: Carob (Haruv)
  ///
  /// In en, this message translates to:
  /// **'Carob (Haruv)'**
  String get fruitTypeCarobHaruv;

  /// Fruit type: Mulberry (White)
  ///
  /// In en, this message translates to:
  /// **'Mulberry (White)'**
  String get fruitTypeMulberryWhite;

  /// Fruit type: Mulberry (Black)
  ///
  /// In en, this message translates to:
  /// **'Mulberry (Black)'**
  String get fruitTypeMulberryBlack;

  /// Fruit type: Pear
  ///
  /// In en, this message translates to:
  /// **'Pear'**
  String get fruitTypePear;

  /// Fruit type: Jujube (Shizaf)
  ///
  /// In en, this message translates to:
  /// **'Jujube (Shizaf)'**
  String get fruitTypeJujubeShizaf;

  /// Fruit type: Medlar
  ///
  /// In en, this message translates to:
  /// **'Medlar'**
  String get fruitTypeMedlar;

  /// Fruit type: Chestnut
  ///
  /// In en, this message translates to:
  /// **'Chestnut'**
  String get fruitTypeChestnut;

  /// Fruit type: Papaya
  ///
  /// In en, this message translates to:
  /// **'Papaya'**
  String get fruitTypePapaya;

  /// Fruit type: Dragon Fruit (Pitaya)
  ///
  /// In en, this message translates to:
  /// **'Dragon Fruit (Pitaya)'**
  String get fruitTypeDragonFruitPitaya;

  /// Fruit type: Jackfruit
  ///
  /// In en, this message translates to:
  /// **'Jackfruit'**
  String get fruitTypeJackfruit;

  /// Fruit type: Longan
  ///
  /// In en, this message translates to:
  /// **'Longan'**
  String get fruitTypeLongan;

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Treez'**
  String get appTitle;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Add tree dialog title
  ///
  /// In en, this message translates to:
  /// **'Add a New Tree'**
  String get addTree;

  /// Tree name input label
  ///
  /// In en, this message translates to:
  /// **'Tree Name'**
  String get treeName;

  /// Fruit type input label
  ///
  /// In en, this message translates to:
  /// **'Fruit Type'**
  String get fruitType;

  /// Fruit type search hint
  ///
  /// In en, this message translates to:
  /// **'Search for fruit type'**
  String get searchFruitType;

  /// Add image button text
  ///
  /// In en, this message translates to:
  /// **'Add Image'**
  String get addImage;

  /// No image selected text
  ///
  /// In en, this message translates to:
  /// **'No image selected'**
  String get noImageSelected;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Tree name validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a tree name'**
  String get pleaseEnterTreeName;

  /// Fruit type validation error
  ///
  /// In en, this message translates to:
  /// **'Please enter a fruit type'**
  String get pleaseEnterFruitType;

  /// Valid fruit selection error
  ///
  /// In en, this message translates to:
  /// **'Please select a valid fruit type from the list'**
  String get pleaseSelectValidFruit;

  /// Success message for tree addition
  ///
  /// In en, this message translates to:
  /// **'🌳 Tree added successfully!'**
  String get treeAddedSuccessfully;

  /// Sign in required message
  ///
  /// In en, this message translates to:
  /// **'Please sign in to add a tree'**
  String get pleaseSignInToAddTree;

  /// Verification score label
  ///
  /// In en, this message translates to:
  /// **'Verification Score: {score}'**
  String verificationScore(int score);

  /// Vote update success message
  ///
  /// In en, this message translates to:
  /// **'Vote updated! Close and reopen to see changes.'**
  String get voteUpdated;

  /// Upvote error message
  ///
  /// In en, this message translates to:
  /// **'Error upvoting: {error}'**
  String errorUpvoting(String error);

  /// Downvote error message
  ///
  /// In en, this message translates to:
  /// **'Error downvoting: {error}'**
  String errorDownvoting(String error);

  /// Tree name display label
  ///
  /// In en, this message translates to:
  /// **'Tree Name: {name}'**
  String treeNameLabel(String name);

  /// Fruit type display label
  ///
  /// In en, this message translates to:
  /// **'Fruit Type: {type}'**
  String fruitTypeLabel(String type);

  /// Location display
  ///
  /// In en, this message translates to:
  /// **'Location: Lat {lat}, Lng {lng}'**
  String location(double lat, double lng);

  /// Date added label
  ///
  /// In en, this message translates to:
  /// **'Added on: {date}'**
  String addedOn(String date);

  /// Minimum verification score filter label
  ///
  /// In en, this message translates to:
  /// **'Minimum Verification Score: {score}'**
  String minimumVerificationScore(int score);

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// Language selection label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Hebrew language name in Hebrew
  ///
  /// In en, this message translates to:
  /// **'עברית'**
  String get hebrew;

  /// Filters dialog title
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Verification score filter label
  ///
  /// In en, this message translates to:
  /// **'Verification Score'**
  String get verificationScoreFilter;

  /// Placeholder text for future filters
  ///
  /// In en, this message translates to:
  /// **'More filters coming soon...'**
  String get moreFiltersComingSoon;

  /// Reset button text
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Apply button text
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Pending status label
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// Approved status label
  ///
  /// In en, this message translates to:
  /// **'Approved'**
  String get statusApproved;

  /// Rejected status label
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get statusRejected;

  /// Navigate button text
  ///
  /// In en, this message translates to:
  /// **'Navigate'**
  String get navigate;

  /// Comment input label
  ///
  /// In en, this message translates to:
  /// **'Comment (optional)'**
  String get commentOptional;

  /// Comment input hint
  ///
  /// In en, this message translates to:
  /// **'Add a comment...'**
  String get addCommentHint;

  /// Photos section title
  ///
  /// In en, this message translates to:
  /// **'Photos ({count})'**
  String photos(int count);

  /// Add photos button text
  ///
  /// In en, this message translates to:
  /// **'Add Photos'**
  String get addPhotos;

  /// Report dialog title
  ///
  /// In en, this message translates to:
  /// **'Report Content'**
  String get reportContent;

  /// Report confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to report this tree? Our team will review it.'**
  String get reportConfirmation;

  /// Report button text
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// Report success message
  ///
  /// In en, this message translates to:
  /// **'Report submitted. Thank you!'**
  String get reportSubmitted;

  /// Share button text
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Text shared on social media
  ///
  /// In en, this message translates to:
  /// **'Check out this {fruit} tree on Treez!'**
  String shareText(String fruit);

  /// Add photos and comment button label
  ///
  /// In en, this message translates to:
  /// **'Add Photos/Comment'**
  String get addCommentPhotos;

  /// Message to zoom in closer for better accuracy
  ///
  /// In en, this message translates to:
  /// **'Zoom closer for better accuracy 🔎'**
  String get zoomCloser;

  /// Instruction to long-click to add a tree
  ///
  /// In en, this message translates to:
  /// **'Long-click on the exact position of the tree to add it'**
  String get longClickToAdd;

  /// Title for update dialog
  ///
  /// In en, this message translates to:
  /// **'Update Required'**
  String get updateRequired;

  /// Button to update the app
  ///
  /// In en, this message translates to:
  /// **'Update Now'**
  String get updateNow;

  /// Button to dismiss update dialog
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// Default username for anonymous users
  ///
  /// In en, this message translates to:
  /// **'Anonymous'**
  String get anonymous;

  /// Label for current version
  ///
  /// In en, this message translates to:
  /// **'Current version: {version}'**
  String currentVersionLabel(String version);

  /// Label for minimum version
  ///
  /// In en, this message translates to:
  /// **'Minimum version: {version}'**
  String minVersionLabel(String version);

  /// Error message when tree addition fails
  ///
  /// In en, this message translates to:
  /// **'Failed to add tree: {error}'**
  String failedToAddTree(String error);

  /// Error message when tree saving fails
  ///
  /// In en, this message translates to:
  /// **'Failed to save tree. Please try again.'**
  String get failedToSaveTree;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred: {error}'**
  String unexpectedError(String error);

  /// Message to wait during saving
  ///
  /// In en, this message translates to:
  /// **'Please wait for the tree to be saved'**
  String get pleaseWait;

  /// Message when no fruit types are found
  ///
  /// In en, this message translates to:
  /// **'No fruit types available'**
  String get noFruitTypesAvailable;

  /// Status filter label
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusFilter;

  /// Last verified after filter label
  ///
  /// In en, this message translates to:
  /// **'Last Verified After'**
  String get lastVerifiedAfter;

  /// Message when no date filter is selected
  ///
  /// In en, this message translates to:
  /// **'No date filter'**
  String get noDateFilter;

  /// Added after filter label
  ///
  /// In en, this message translates to:
  /// **'Added After'**
  String get addedAfter;

  /// Show reported only filter label
  ///
  /// In en, this message translates to:
  /// **'Show Reported Only'**
  String get showReportedOnly;

  /// Subtitle for reported trees filter
  ///
  /// In en, this message translates to:
  /// **'Filter trees flagged by users'**
  String get filterReportedSubtitle;

  /// Show unknown fruits only filter label
  ///
  /// In en, this message translates to:
  /// **'Show Unknown Fruits Only'**
  String get showUnknownFruitsOnly;

  /// Subtitle for unknown fruits filter
  ///
  /// In en, this message translates to:
  /// **'Filter fruits not in the official list'**
  String get filterUnknownFruitsSubtitle;

  /// Message to log in to add photos
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to add photos or comments'**
  String get loginToAddPhotos;

  /// Success message when post is added
  ///
  /// In en, this message translates to:
  /// **'Post added successfully'**
  String get postAddedSuccessfully;

  /// Message to log in to report content
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to report'**
  String get loginToReport;

  /// Delete tree button text
  ///
  /// In en, this message translates to:
  /// **'Delete Tree'**
  String get deleteTree;

  /// Confirmation message for tree deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this tree and all its posts? This action cannot be undone.'**
  String get deleteTreeConfirmation;

  /// Success message when tree is deleted
  ///
  /// In en, this message translates to:
  /// **'Tree deleted successfully'**
  String get treeDeletedSuccessfully;

  /// Success message when post is deleted
  ///
  /// In en, this message translates to:
  /// **'Post deleted successfully'**
  String get postDeletedSuccessfully;

  /// Tooltip for delete tree button
  ///
  /// In en, this message translates to:
  /// **'Delete tree'**
  String get deleteTreeTooltip;

  /// Tooltip for report button
  ///
  /// In en, this message translates to:
  /// **'Report this content'**
  String get reportTooltip;

  /// Message to log in to verify trees
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to verify trees'**
  String get loginToVerify;

  /// Message to log in to unverify trees
  ///
  /// In en, this message translates to:
  /// **'You need to be logged in to unverify trees'**
  String get loginToUnverify;

  /// Label for added date
  ///
  /// In en, this message translates to:
  /// **'Added {date}'**
  String addedDate(String date);

  /// Label for last verified date
  ///
  /// In en, this message translates to:
  /// **'Last verified: {date}'**
  String lastVerifiedDate(String date);

  /// Message when there are no posts
  ///
  /// In en, this message translates to:
  /// **'No photos or comments yet'**
  String get noPhotosOrComments;

  /// Encouragement to add the first post
  ///
  /// In en, this message translates to:
  /// **'Be the first to share!'**
  String get beTheFirstToShare;

  /// Delete post button text
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// Confirmation message for post deletion
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this post?'**
  String get deletePostConfirmation;

  /// Message while posting content
  ///
  /// In en, this message translates to:
  /// **'Posting...'**
  String get posting;
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
      <String>['en', 'he'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'he':
      return AppLocalizationsHe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
