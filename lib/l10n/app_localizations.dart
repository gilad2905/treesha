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

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Treesha'**
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
