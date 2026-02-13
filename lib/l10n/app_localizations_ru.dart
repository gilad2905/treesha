// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get fruitTypeOlive => 'Олива';

  @override
  String get fruitTypeAlmond => 'Миндаль';

  @override
  String get fruitTypeCarobHaruv => 'Рожковое дерево (Харув)';

  @override
  String get fruitTypeMulberryWhite => 'Шелковица (Белая)';

  @override
  String get fruitTypeMulberryBlack => 'Шелковица (Черная)';

  @override
  String get fruitTypePear => 'Груша';

  @override
  String get fruitTypeJujubeShizaf => 'Унаби (Шизаф)';

  @override
  String get fruitTypeMedlar => 'Мушмула';

  @override
  String get fruitTypeChestnut => 'Каштан';

  @override
  String get fruitTypePapaya => 'Папайя';

  @override
  String get fruitTypeDragonFruitPitaya => 'Питайя (Драконий фрукт)';

  @override
  String get fruitTypeJackfruit => 'Джекфрут';

  @override
  String get fruitTypeLongan => 'Лонган';

  @override
  String get appTitle => 'Treez';

  @override
  String get signIn => 'Войти';

  @override
  String get signOut => 'Выйти';

  @override
  String get addTree => 'Добавить дерево';

  @override
  String get treeName => 'Название дерева';

  @override
  String get treeNameOptional => 'Название дерева (опционально)';

  @override
  String get fruitType => 'Тип фрукта';

  @override
  String get searchFruitType => 'Поиск типа фрукта';

  @override
  String get addImage => 'Добавить фото';

  @override
  String get noImageSelected => 'Фото не выбрано';

  @override
  String get cancel => 'Отмена';

  @override
  String get add => 'Добавить';

  @override
  String get pleaseEnterTreeName => 'Введите название дерева';

  @override
  String get pleaseEnterFruitType => 'Введите тип фрукта';

  @override
  String get pleaseSelectValidFruit => 'Выберите тип фрукта из списка';

  @override
  String get treeAddedSuccessfully => '🌳 Дерево успешно добавлено!';

  @override
  String get pleaseSignInToAddTree => 'Войдите, чтобы добавить дерево';

  @override
  String verificationScore(int score) {
    return 'Рейтинг проверки: $score';
  }

  @override
  String get voteUpdated =>
      'Голос обновлен! Переоткройте, чтобы увидеть изменения.';

  @override
  String errorUpvoting(String error) {
    return 'Ошибка голосования ЗА: $error';
  }

  @override
  String errorDownvoting(String error) {
    return 'Ошибка голосования ПРОТИВ: $error';
  }

  @override
  String treeNameLabel(String name) {
    return 'Название: $name';
  }

  @override
  String fruitTypeLabel(String type) {
    return 'Тип фрукта: $type';
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

    return 'Локация: Шир. $latString, Долг. $lngString';
  }

  @override
  String addedOn(String date) {
    return 'Добавлено: $date';
  }

  @override
  String minimumVerificationScore(int score) {
    return 'Мин. рейтинг проверки: $score';
  }

  @override
  String get somethingWentWrong => 'Что-то пошло не так';

  @override
  String get language => 'Язык';

  @override
  String get english => 'English';

  @override
  String get hebrew => 'עברית';

  @override
  String get russian => 'Русский';

  @override
  String get filters => 'Фильтры';

  @override
  String get verificationScoreFilter => 'Рейтинг проверки';

  @override
  String get moreFiltersComingSoon => 'Другие фильтры скоро появятся...';

  @override
  String get reset => 'Сбросить';

  @override
  String get apply => 'Применить';

  @override
  String get statusPending => 'Ожидает';

  @override
  String get statusApproved => 'Одобрено';

  @override
  String get statusRejected => 'Отклонено';

  @override
  String get navigate => 'Маршрут';

  @override
  String get commentOptional => 'Комментарий (опционально)';

  @override
  String get addCommentHint => 'Добавить комментарий...';

  @override
  String photos(int count) {
    return 'Фото ($count)';
  }

  @override
  String get addPhotos => 'Добавить фото';

  @override
  String get reportContent => 'Пожаловаться';

  @override
  String get reportConfirmation =>
      'Вы уверены, что хотите пожаловаться? Мы проверим это дерево.';

  @override
  String get report => 'Пожаловаться';

  @override
  String get reportSubmitted => 'Жалоба отправлена. Спасибо!';

  @override
  String get share => 'Поделиться';

  @override
  String shareText(String fruit) {
    return 'Посмотрите на это дерево ($fruit) в приложении Treez!';
  }

  @override
  String get addCommentPhotos => 'Добавить фото/комментарий';

  @override
  String get zoomCloser => 'Приблизьте карту для точности 🔎';

  @override
  String get longClickToAdd =>
      'Удерживайте палец на месте дерева, чтобы добавить его';

  @override
  String get updateRequired => 'Требуется обновление';

  @override
  String get updateNow => 'Обновить сейчас';

  @override
  String get later => 'Позже';

  @override
  String get anonymous => 'Аноним';

  @override
  String currentVersionLabel(String version) {
    return 'Текущая версия: $version';
  }

  @override
  String minVersionLabel(String version) {
    return 'Мин. версия: $version';
  }

  @override
  String failedToAddTree(String error) {
    return 'Не удалось добавить дерево: $error';
  }

  @override
  String get failedToSaveTree =>
      'Не удалось сохранить дерево. Попробуйте еще раз.';

  @override
  String unexpectedError(String error) {
    return 'Произошла непредвиденная ошибка: $error';
  }

  @override
  String get pleaseWait => 'Пожалуйста, подождите, пока дерево сохраняется';

  @override
  String get noFruitTypesAvailable => 'Типы фруктов не найдены';

  @override
  String get statusFilter => 'Статус';

  @override
  String get lastVerifiedAfter => 'Проверено после';

  @override
  String get noDateFilter => 'Без фильтра по дате';

  @override
  String get addedAfter => 'Добавлено после';

  @override
  String get showReportedOnly => 'Только с жалобами';

  @override
  String get filterReportedSubtitle =>
      'Показать деревья, на которые жаловались';

  @override
  String get showUnknownFruitsOnly => 'Только неизвестные фрукты';

  @override
  String get filterUnknownFruitsSubtitle => 'Показать фрукты не из списка';

  @override
  String get loginToAddPhotos => 'Войдите, чтобы добавить фото или комментарии';

  @override
  String get postAddedSuccessfully => 'Комментарий успешно добавлен';

  @override
  String get loginToReport => 'Войдите, чтобы пожаловаться';

  @override
  String get deleteTree => 'Удалить дерево';

  @override
  String get deleteTreeConfirmation =>
      'Вы уверены, что хотите удалить дерево и все записи? Это действие необратимо.';

  @override
  String get treeDeletedSuccessfully => 'Дерево удалено';

  @override
  String get postDeletedSuccessfully => 'Запись удалена';

  @override
  String get deleteTreeTooltip => 'Удалить дерево';

  @override
  String get reportTooltip => 'Пожаловаться';

  @override
  String get loginToVerify => 'Войдите, чтобы подтверждать деревья';

  @override
  String get loginToUnverify => 'Войдите, чтобы отклонять деревья';

  @override
  String addedDate(String date) {
    return 'Добавлено $date';
  }

  @override
  String lastVerifiedDate(String date) {
    return 'Проверено: $date';
  }

  @override
  String get noPhotosOrComments => 'Фото и комментариев пока нет';

  @override
  String get beTheFirstToShare => 'Будьте первым!';

  @override
  String get deletePost => 'Удалить запись';

  @override
  String get deletePostConfirmation =>
      'Вы уверены, что хотите удалить эту запись?';

  @override
  String get posting => 'Публикация...';

  @override
  String createdBy(String name) {
    return 'Добавил: $name';
  }

  @override
  String get disclaimerTitle =>
      '🌿 Отказ от ответственности при сборе и использовании';

  @override
  String get disclaimerSubtitle => 'Важное примечание';

  @override
  String get disclaimerAgreement =>
      'Это приложение предоставляет созданную пользователями информацию о деревьях, травах и других растениях, которые могут быть съедобными. Контент в этом приложении предназначен только для информационных целей.\n\nИспользуя это приложение, вы подтверждаете и соглашаетесь с тем, что:';

  @override
  String get disclaimerPoint1Title =>
      '🌱 Идентификация растений — это ваша ответственность.';

  @override
  String get disclaimerPoint1Body =>
      'Всегда самостоятельно проверяйте идентичность любого растения перед его употреблением. У многих съедобных растений есть ядовитые двойники.';

  @override
  String get disclaimerPoint2Title =>
      '⚠️ Не употребляйте никакие фрукты, травы или растения, если вы не уверены на 100% в их безопасности.';

  @override
  String get disclaimerPoint2Body => 'Если сомневаетесь — не ешьте.';

  @override
  String get disclaimerPoint3Title => '🏡 Уважайте частную собственность.';

  @override
  String get disclaimerPoint3Body =>
      'Не заходите на частную территорию без разрешения. Вы несете единоличную ответственность за обеспечение законного доступа к любому месту.';

  @override
  String get disclaimerPoint4Title => '🧪 Риски для здоровья и безопасности.';

  @override
  String get disclaimerPoint4Body =>
      'Некоторые растения могут вызывать аллергические реакции или неблагоприятные последствия для здоровья. Приложение не дает медицинских консультаций.';

  @override
  String get disclaimerPoint5Title => '👥 Пользовательский контент.';

  @override
  String get disclaimerPoint5Body =>
      'Местоположения, описания и информация о съедобности предоставляются пользователями и могут быть неточными, неполными или устаревшими.';

  @override
  String get disclaimerLiability =>
      'Владельцы приложения, разработчики и участники не несут никакой ответственности за любые травмы, болезни, ущерб, юридические проблемы или убытки, возникшие в результате использования этого приложения или доверия к его контенту.';

  @override
  String get disclaimerRisk => 'Используйте на свой страх и риск.';

  @override
  String get iUnderstood => 'Я понимаю';
}
