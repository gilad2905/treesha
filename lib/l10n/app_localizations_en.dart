// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get fruitTypeOlive => 'Olive';

  @override
  String get fruitTypeAlmond => 'Almond';

  @override
  String get fruitTypeCarobHaruv => 'Carob (Haruv)';

  @override
  String get fruitTypeMulberryWhite => 'Mulberry (White)';

  @override
  String get fruitTypeMulberryBlack => 'Mulberry (Black)';

  @override
  String get fruitTypePear => 'Pear';

  @override
  String get fruitTypeJujubeShizaf => 'Jujube (Shizaf)';

  @override
  String get fruitTypeMedlar => 'Medlar';

  @override
  String get fruitTypeChestnut => 'Chestnut';

  @override
  String get fruitTypePapaya => 'Papaya';

  @override
  String get fruitTypeDragonFruitPitaya => 'Dragon Fruit (Pitaya)';

  @override
  String get fruitTypeJackfruit => 'Jackfruit';

  @override
  String get fruitTypeLongan => 'Longan';

  @override
  String get appTitle => 'Treez';

  @override
  String get signIn => 'Sign In';

  @override
  String get signOut => 'Sign Out';

  @override
  String get addTree => 'Add a New Tree';

  @override
  String get treeName => 'Tree Name';

  @override
  String get fruitType => 'Fruit Type';

  @override
  String get searchFruitType => 'Search for fruit type';

  @override
  String get addImage => 'Add Image';

  @override
  String get noImageSelected => 'No image selected';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get pleaseEnterTreeName => 'Please enter a tree name';

  @override
  String get pleaseEnterFruitType => 'Please enter a fruit type';

  @override
  String get pleaseSelectValidFruit =>
      'Please select a valid fruit type from the list';

  @override
  String get treeAddedSuccessfully => '🌳 Tree added successfully!';

  @override
  String get pleaseSignInToAddTree => 'Please sign in to add a tree';

  @override
  String verificationScore(int score) {
    return 'Verification Score: $score';
  }

  @override
  String get voteUpdated => 'Vote updated! Close and reopen to see changes.';

  @override
  String errorUpvoting(String error) {
    return 'Error upvoting: $error';
  }

  @override
  String errorDownvoting(String error) {
    return 'Error downvoting: $error';
  }

  @override
  String treeNameLabel(String name) {
    return 'Tree Name: $name';
  }

  @override
  String fruitTypeLabel(String type) {
    return 'Fruit Type: $type';
  }

  @override
  String location(double lat, double lng) {
    final intl.NumberFormat latNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String latString = latNumberFormat.format(lat);
    final intl.NumberFormat lngNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String lngString = lngNumberFormat.format(lng);

    return 'Location: Lat $latString, Lng $lngString';
  }

  @override
  String addedOn(String date) {
    return 'Added on: $date';
  }

  @override
  String minimumVerificationScore(int score) {
    return 'Minimum Verification Score: $score';
  }

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get hebrew => 'עברית';

  @override
  String get filters => 'Filters';

  @override
  String get verificationScoreFilter => 'Verification Score';

  @override
  String get moreFiltersComingSoon => 'More filters coming soon...';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusApproved => 'Approved';

  @override
  String get statusRejected => 'Rejected';

  @override
  String get navigate => 'Navigate';

  @override
  String get commentOptional => 'Comment (optional)';

  @override
  String get addCommentHint => 'Add a comment...';

  @override
  String photos(int count) {
    return 'Photos ($count)';
  }

  @override
  String get addPhotos => 'Add Photos';

  @override
  String get reportContent => 'Report Content';

  @override
  String get reportConfirmation =>
      'Are you sure you want to report this tree? Our team will review it.';

  @override
  String get report => 'Report';

  @override
  String get reportSubmitted => 'Report submitted. Thank you!';

  @override
  String get share => 'Share';

  @override
  String shareText(String fruit) {
    return 'Check out this $fruit tree on Treez!';
  }

  @override
  String get addCommentPhotos => 'Add Photos/Comment';
}
