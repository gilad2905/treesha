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
  String get treeNameOptional => 'שם העץ (אופציונלי)';

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
  String get russian => 'רוסית';

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

  @override
  String get zoomCloser => 'אנא התקרב במפה (זום) לדיוק מירבי 🔎';

  @override
  String get longClickToAdd => 'להוספת העץ לחץ לחיצה ארוכה על המיקום המדויק';

  @override
  String get updateRequired => 'נדרש עדכון גרסה';

  @override
  String get updateNow => 'עדכן עכשיו';

  @override
  String get later => 'אחר כך';

  @override
  String get anonymous => 'אנונימי';

  @override
  String currentVersionLabel(String version) {
    return 'גרסה נוכחית: $version';
  }

  @override
  String minVersionLabel(String version) {
    return 'גרסת מינימום: $version';
  }

  @override
  String failedToAddTree(String error) {
    return 'הוספת העץ נכשלה: $error';
  }

  @override
  String get failedToSaveTree => 'שמירת העץ נכשלה. אנא נסה שוב.';

  @override
  String unexpectedError(String error) {
    return 'אירעה שגיאה בלתי צפויה: $error';
  }

  @override
  String get pleaseWait => 'אנא המתן עד לשמירת העץ';

  @override
  String get noFruitTypesAvailable => 'אין סוגי פירות זמינים';

  @override
  String get statusFilter => 'סטטוס';

  @override
  String get lastVerifiedAfter => 'אומת לאחרונה אחרי';

  @override
  String get noDateFilter => 'אין סינון לפי תאריך';

  @override
  String get addedAfter => 'נוסף אחרי';

  @override
  String get showReportedOnly => 'הצג מדווחים בלבד';

  @override
  String get filterReportedSubtitle => 'סנן עצים שדווחו על ידי משתמשים';

  @override
  String get showUnknownFruitsOnly => 'הצג פירות לא ידועים בלבד';

  @override
  String get filterUnknownFruitsSubtitle => 'סנן פירות שאינם ברשימה הרשמית';

  @override
  String get loginToAddPhotos => 'עליך להתחבר כדי להוסיף תמונות או הערות';

  @override
  String get postAddedSuccessfully => 'הפוסט נוסף בהצלחה';

  @override
  String get loginToReport => 'עליך להתחבר כדי לדווח';

  @override
  String get deleteTree => 'מחק עץ';

  @override
  String get deleteTreeConfirmation =>
      'האם אתה בטוח שברצונך למחוק את העץ ואת כל הפוסטים שלו? פעולה זו אינה ניתנת לביטול.';

  @override
  String get treeDeletedSuccessfully => 'העץ נמחק בהצלחה';

  @override
  String get postDeletedSuccessfully => 'הפוסט נמחק בהצלחה';

  @override
  String get deleteTreeTooltip => 'מחק עץ';

  @override
  String get reportTooltip => 'דווח על תוכן זה';

  @override
  String get loginToVerify => 'עליך להתחבר כדי לאמת עצים';

  @override
  String get loginToUnverify => 'עליך להתחבר כדי לבטל אימות עצים';

  @override
  String addedDate(String date) {
    return 'נוסף בתאריך $date';
  }

  @override
  String lastVerifiedDate(String date) {
    return 'אומת לאחרונה: $date';
  }

  @override
  String get noPhotosOrComments => 'אין עדיין תמונות או הערות';

  @override
  String get beTheFirstToShare => 'היה הראשון לשתף!';

  @override
  String get deletePost => 'מחק פוסט';

  @override
  String get deletePostConfirmation =>
      'האם אתה בטוח שברצונך למחוק את הפוסט הזה?';

  @override
  String get blockedUserPost => 'פוסט ממשתמש חסום';

  @override
  String get blockUser => 'חסום משתמש';

  @override
  String get unblockUser => 'בטל חסימת משתמש';

  @override
  String blockUserConfirmation(String name) {
    return 'לחסום את $name? הפוסטים שלהם יוסתרו.';
  }

  @override
  String unblockUserConfirmation(String name) {
    return 'לבטל את חסימת $name? הפוסטים שלהם יוצגו שוב.';
  }

  @override
  String get posting => 'מעלה...';

  @override
  String createdBy(String name) {
    return 'נוסף על ידי $name';
  }

  @override
  String get disclaimerTitle => '🌿 הצהרת ליקוט ושימוש';

  @override
  String get disclaimerSubtitle => 'הודעה חשובה';

  @override
  String get disclaimerAgreement =>
      'אפליקציה זו מספקת מידע המופק על ידי משתמשים לגבי עצים, צמחי תבלין וצמחים אחרים שעשויים להיות אכילים. התוכן באפליקציה זו נועד למטרות מידע בלבד.\n\nבשימוש באפליקציה זו, הינך מאשר ומסכים כי:';

  @override
  String get disclaimerPoint1Title => '🌱 זיהוי צמחים הוא באחריותך.';

  @override
  String get disclaimerPoint1Body =>
      'ודא תמיד באופן עצמאי את זהות כל צמח לפני צריכתו. לצמחי מאכל רבים יש כפילים רעילים.';

  @override
  String get disclaimerPoint2Title =>
      '⚠️ אל תצרוך אף פרי, עשב או צמח אלא אם כן אתה בטוח לחלוטין שהוא בטוח.';

  @override
  String get disclaimerPoint2Body => 'כשיש ספק, אל תאכל.';

  @override
  String get disclaimerPoint3Title => '🏡 כבד רכוש פרטי.';

  @override
  String get disclaimerPoint3Body =>
      'אל תיכנס לשטח פרטי ללא רשות. אתה האחראי הבלעדי לוודא שיש לך גישה חוקית לכל מיקום.';

  @override
  String get disclaimerPoint4Title => '🧪 סיכוני בריאות ובטיחות.';

  @override
  String get disclaimerPoint4Body =>
      'צמחים מסוימים עלולים לגרום לתגובות אלרגיות או להשפעות בריאותיות שליליות. האפליקציה אינה מספקת ייעוץ רפואי.';

  @override
  String get disclaimerPoint5Title => '👥 תוכן גולשים.';

  @override
  String get disclaimerPoint5Body =>
      'מיקומים, תיאורים ומידע על אכילה נשלחים על ידי משתמשים ועשויים להיות לא מדויקים, חלקיים או מיושנים.';

  @override
  String get disclaimerLiability =>
      'בעלי האפליקציה, המפתחים והתורמים אינם נושאים בכל אחריות או חבות לכל פציעה, מחלה, נזק, בעיות משפטיות או אובדן הנובעים מהשימוש באפליקציה זו או מהסתמכות על תוכנה.';

  @override
  String get disclaimerRisk => 'השימוש באחריותך בלבד.';

  @override
  String get iUnderstood => 'הבנתי';
}
