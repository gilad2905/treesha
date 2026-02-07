// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get fruitTypeOlive => 'זית';

  @override
  String get fruitTypeAlmond => 'שקד';

  @override
  String get fruitTypeCarobHaruv => 'חרוב';

  @override
  String get fruitTypeMulberryWhite => 'תות עץ (לבן)';

  @override
  String get fruitTypeMulberryBlack => 'תות עץ (שחור)';

  @override
  String get fruitTypePear => 'אגס';

  @override
  String get fruitTypeJujubeShizaf => 'שיזף';

  @override
  String get fruitTypeMedlar => 'שסק אירופי (מדלר)';

  @override
  String get fruitTypeChestnut => 'ערמון';

  @override
  String get fruitTypePapaya => 'פפאיה';

  @override
  String get fruitTypeDragonFruitPitaya => 'פרי הדרקון (פיטאיה)';

  @override
  String get fruitTypeJackfruit => 'ג\'קפרוט';

  @override
  String get fruitTypeLongan => 'לונגן';

  @override
  String get appTitle => 'טריז';

  @override
  String get signIn => 'התחבר';

  @override
  String get signOut => 'התנתק';

  @override
  String get addTree => 'הוסף עץ חדש';

  @override
  String get treeName => 'שם העץ';

  @override
  String get fruitType => 'סוג הפרי';

  @override
  String get searchFruitType => 'חפש סוג פרי';

  @override
  String get addImage => 'הוסף תמונה';

  @override
  String get noImageSelected => 'לא נבחרה תמונה';

  @override
  String get cancel => 'ביטול';

  @override
  String get add => 'הוסף';

  @override
  String get pleaseEnterTreeName => 'אנא הזן שם עץ';

  @override
  String get pleaseEnterFruitType => 'אנא הזן סוג פרי';

  @override
  String get pleaseSelectValidFruit => 'אנא בחר סוג פרי תקין מהרשימה';

  @override
  String get treeAddedSuccessfully => '🌳 העץ נוסף בהצלחה!';

  @override
  String get pleaseSignInToAddTree => 'אנא התחבר כדי להוסיף עץ';

  @override
  String verificationScore(int score) {
    return 'ציון אימות: $score';
  }

  @override
  String get voteUpdated => 'ההצבעה עודכנה! סגור ופתח מחדש כדי לראות שינויים.';

  @override
  String errorUpvoting(String error) {
    return 'שגיאה בהצבעה בעד: $error';
  }

  @override
  String errorDownvoting(String error) {
    return 'שגיאה בהצבעה נגד: $error';
  }

  @override
  String treeNameLabel(String name) {
    return 'שם העץ: $name';
  }

  @override
  String fruitTypeLabel(String type) {
    return 'סוג הפרי: $type';
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

    return 'מיקום: קו רוחב $latString, קו אורך $lngString';
  }

  @override
  String addedOn(String date) {
    return 'נוסף בתאריך: $date';
  }

  @override
  String minimumVerificationScore(int score) {
    return 'ציון אימות מינימלי: $score';
  }

  @override
  String get somethingWentWrong => 'משהו השתבש';

  @override
  String get language => 'שפה';

  @override
  String get english => 'English';

  @override
  String get hebrew => 'עברית';

  @override
  String get filters => 'מסננים';

  @override
  String get verificationScoreFilter => 'ציון אימות';

  @override
  String get moreFiltersComingSoon => 'מסננים נוספים בקרוב...';

  @override
  String get reset => 'איפוס';

  @override
  String get apply => 'החל';

  @override
  String get statusPending => 'ממתין לאישור';

  @override
  String get statusApproved => 'מאושר';

  @override
  String get statusRejected => 'נדחה';

  @override
  String get navigate => 'ניווט';

  @override
  String get commentOptional => 'הערה (אופציונלי)';

  @override
  String get addCommentHint => 'הוסף הערה...';

  @override
  String photos(int count) {
    return 'תמונות ($count)';
  }

  @override
  String get addPhotos => 'הוסף תמונות';

  @override
  String get reportContent => 'דווח על תוכן';

  @override
  String get reportConfirmation =>
      'האם אתה בטוח שברצונך לדווח על עץ זה? הצוות שלנו יבדוק אותו.';

  @override
  String get report => 'דווח';

  @override
  String get reportSubmitted => 'הדיווח נשלח. תודה!';

  @override
  String get share => 'שתף';

  @override
  String shareText(String fruit) {
    return 'תראו את עץ ה$fruit הזה ב-Treez!';
  }

  @override
  String get addCommentPhotos => 'הוסף תמונות/הערה';
}
