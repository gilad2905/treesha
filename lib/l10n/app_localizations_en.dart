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

  @override
  String get zoomCloser => 'Zoom closer for better accuracy 🔎';

  @override
  String get longClickToAdd =>
      'Long-click on the exact position of the tree to add it';

  @override
  String get updateRequired => 'Update Required';

  @override
  String get updateNow => 'Update Now';

  @override
  String get later => 'Later';

  @override
  String get anonymous => 'Anonymous';

  @override
  String currentVersionLabel(String version) {
    return 'Current version: $version';
  }

  @override
  String minVersionLabel(String version) {
    return 'Minimum version: $version';
  }

  @override
  String failedToAddTree(String error) {
    return 'Failed to add tree: $error';
  }

  @override
  String get failedToSaveTree => 'Failed to save tree. Please try again.';

  @override
  String unexpectedError(String error) {
    return 'An unexpected error occurred: $error';
  }

  @override
  String get pleaseWait => 'Please wait for the tree to be saved';

  @override
  String get noFruitTypesAvailable => 'No fruit types available';

  @override
  String get statusFilter => 'Status';

  @override
  String get lastVerifiedAfter => 'Last Verified After';

  @override
  String get noDateFilter => 'No date filter';

  @override
  String get addedAfter => 'Added After';

  @override
  String get showReportedOnly => 'Show Reported Only';

  @override
  String get filterReportedSubtitle => 'Filter trees flagged by users';

  @override
  String get showUnknownFruitsOnly => 'Show Unknown Fruits Only';

  @override
  String get filterUnknownFruitsSubtitle =>
      'Filter fruits not in the official list';

  @override
  String get loginToAddPhotos =>
      'You need to be logged in to add photos or comments';

  @override
  String get postAddedSuccessfully => 'Post added successfully';

  @override
  String get loginToReport => 'You need to be logged in to report';

  @override
  String get deleteTree => 'Delete Tree';

  @override
  String get deleteTreeConfirmation =>
      'Are you sure you want to delete this tree and all its posts? This action cannot be undone.';

  @override
  String get treeDeletedSuccessfully => 'Tree deleted successfully';

  @override
  String get postDeletedSuccessfully => 'Post deleted successfully';

  @override
  String get deleteTreeTooltip => 'Delete tree';

  @override
  String get reportTooltip => 'Report this content';

  @override
  String get loginToVerify => 'You need to be logged in to verify trees';

  @override
  String get loginToUnverify => 'You need to be logged in to unverify trees';

  @override
  String addedDate(String date) {
    return 'Added $date';
  }

  @override
  String lastVerifiedDate(String date) {
    return 'Last verified: $date';
  }

  @override
  String get noPhotosOrComments => 'No photos or comments yet';

  @override
  String get beTheFirstToShare => 'Be the first to share!';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get deletePostConfirmation =>
      'Are you sure you want to delete this post?';

  @override
  String get posting => 'Posting...';

  @override
  String createdBy(String name) {
    return 'Created by $name';
  }
}
