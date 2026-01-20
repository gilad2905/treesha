// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hebrew (`he`).
class AppLocalizationsHe extends AppLocalizations {
  AppLocalizationsHe([String locale = 'he']) : super(locale);

  @override
  String get appTitle => 'טרישה';

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
}
