import 'package:duration/duration.dart'
    hide aMicrosecond, aMillisecond, aSecond, aMinute, anHour, aDay, aWeek;
import 'package:duration/locale.dart';
import 'package:intl/intl.dart';

import '../constants/constants.dart';
import 'num.dart';

// ignore_for_file: non_constant_identifier_names

DateTime get now => DateTime.now();
DateTime get utc =>
    DateTime.fromMillisecondsSinceEpoch(now.millisecondsSinceEpoch, isUtc: true);

extension MyDateTimeExtensions on DateTime {
  int get epoch => millisecondsSinceEpoch;
  int get unix => epoch ~/ 1000;

  bool isBeforeOrAt(DateTime time) => isBefore(time) || isAtSameMomentAs(time);
  bool isAfterOrAt(DateTime time) => isAfter(time) || isAtSameMomentAs(time);
  bool isBetween(DateTime start, DateTime end) =>
      isAtSameMomentAs(start) ||
      isAtSameMomentAs(end) ||
      (start.isBefore(this) && end.isAfter(this));

  DateTime min(DateTime other) => isBefore(other) ? this : other;
  DateTime max(DateTime other) => isAfter(other) ? this : other;

  String get hourId => '$year $month $day $hour';
  String get dateId => '$year $month $day';
  String get weekId => '$year $week';
  String get quarterId => '$year $quarter';
  String get monthId => '$year $month';
  String get yearId => '$year';

  bool get isToday => DateTime.now().dateId == dateId;
  bool get isTomorrow => DateTime.now().add(const Duration(days: 1)).dateId == dateId;
  bool get isYesterday =>
      DateTime.now().subtract(const Duration(days: 1)).dateId == dateId;
  bool get isThisWeek => DateTime.now().weekId == weekId;

  int get dayOfYear => difference(DateTime(year)).inDays;
  int get week {
    final dayOfYear = int.parse(format('D'));
    final week = ((dayOfYear - weekday + 10) / 7).floor();
    return week;
  }

  int get quarter {
    final quarter = int.parse(format('Q').replaceAll('Q', ''));
    return quarter;
  }

  int get lengthOfMonth => endOfMonth.day;
  int get lengthOfYear => endOfYear.difference(startOfYear).inDays;

  Duration get ellapsed => DateTime.now().difference(this);
  Duration get ellapsedForMinute =>
      Duration(seconds: second, milliseconds: millisecond, microseconds: microsecond);
  Duration get ellapsedForHour => Duration(
      minutes: minute,
      seconds: second,
      milliseconds: millisecond,
      microseconds: microsecond);
  Duration get ellapsedForDay => Duration(
      hours: hour,
      minutes: minute,
      seconds: second,
      milliseconds: millisecond,
      microseconds: microsecond);

  DateTime get floorToMinute => subtract(ellapsedForMinute);
  DateTime get floorToHour => subtract(ellapsedForHour);
  DateTime get floorToDay => subtract(ellapsedForDay);

  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  DateTime get startOfWeek {
    final startOfWeek = subtract(Duration(days: weekday - 1));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }

  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  DateTime get startOfMonth => DateTime(year, month);
  DateTime get endOfMonth {
    final beginningNextMonth =
        (month < 12) ? DateTime(year, month + 1, 1) : DateTime(year + 1, 1, 1);
    final lastDayOfMonth = beginningNextMonth.subtract(const Duration(days: 1));

    return DateTime(
        lastDayOfMonth.year, lastDayOfMonth.month, lastDayOfMonth.day, 23, 59, 59);
  }

  DateTime get startOfYear => DateTime(year);
  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59);

  int getDifferenceInMonths(DateTime date2) {
    final years = getDifferenceInYears(date2);
    final months = (date2.month - month).abs();
    return (years * 12) + months;
  }

  int getDifferenceInYears(DateTime date2) => (date2.year - year).abs();

  // * FORMATTER EXTENSIONS
  String format(String pattern, {String code}) {
    code ??= Intl.defaultLocale;
    final dateFormat = code != null ? DateFormat(pattern, code) : DateFormat(pattern);
    return dateFormat.format(this);
  }

  DateTime scaleTo(DateTime b, double t) {
    if (t == null || b == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(
      lerpInt(millisecondsSinceEpoch.toDouble(), b.millisecondsSinceEpoch.toDouble(), t),
    );
  }

  /// DAY
  String d() => DateFormat.d().format(this);

  /// ABBR_WEEKDAY
  String E() => DateFormat.E().format(this);

  /// WEEKDAY
  String EEEE() => DateFormat.EEEE().format(this);

  /// ABBR_STANDALONE_MONTH
  String LLL() => DateFormat.LLL().format(this);

  /// STANDALONE_MONTH
  String LLLL() => DateFormat.LLLL().format(this);

  /// NUM_MONTH
  String M() => DateFormat.M().format(this);

  /// NUM_MONTH_DAY
  String Md() => DateFormat.Md().format(this);

  /// NUM_MONTH_WEEKDAY_DAY
  String MEd() => DateFormat.MEd().format(this);

  /// ABBR_MONTH
  String MMM() => DateFormat.MMM().format(this);

  /// ABBR_MONTH_DAY
  String MMMd() => DateFormat.MMMd().format(this);

  /// ABBR_MONTH_WEEKDAY_DAY
  String MMMEd() => DateFormat.MMMEd().format(this);

  /// MONTH
  String MMMM() => DateFormat.MMMM().format(this);

  /// NUM_MONTH
  String MMMMd() => DateFormat.MMMMd().format(this);

  /// MONTH_WEEKDAY_DAY
  String MMMMEEEEd() => DateFormat.MMMMEEEEd().format(this);

  /// ABBR_QUARTER
  String QQQ() => DateFormat.QQQ().format(this);

  /// QUARTER
  String QQQQ() => DateFormat.QQQQ().format(this);

  /// YEAR
  String y() => DateFormat.y().format(this);

  /// YEAR_NUM_MONTH
  String yM() => DateFormat.yM().format(this);

  /// YEAR_NUM_MONTH_DAY
  String yMd() => DateFormat.yMd().format(this);

  /// YEAR_NUM_MONTH_WEEKDAY_DAY
  String yMEd() => DateFormat.yMEd().format(this);

  /// YEAR_ABBR_MONTH
  String yMMM() => DateFormat.yMMM().format(this);

  /// YEAR_ABBR_MONTH_DAY
  String yMMMd() => DateFormat.yMMMd().format(this);

  /// YEAR_MONTH
  String yMMMM() => DateFormat.yMMMM().format(this);

  /// YEAR_MONTH_DAY
  String yMMMMd() => DateFormat.yMMMMd().format(this);

  /// YEAR_MONTH_WEEKDAY_DAY
  String yMMMMEEEEd() => DateFormat.yMMMMEEEEd().format(this);

  /// YEAR_ABBR_QUARTER
  String yQQQ() => DateFormat.yQQQ().format(this);

  /// YEAR_QUARTER
  String yQQQQ() => DateFormat.yQQQQ().format(this);

  /// HOUR24
  String H() => DateFormat.H().format(this);

  /// HOUR24_MINUTE
  String Hm() => DateFormat.Hm().format(this);

  /// HOUR24_MINUTE_SECOND
  String Hms() => DateFormat.Hms().format(this);

  /// HOUR
  String j() => DateFormat.j().format(this);

  /// HOUR_MINUTE
  String jm() => DateFormat.jm().format(this);

  /// HOUR_MINUTE_SECOND
  String jms() => DateFormat.jms().format(this);

  /// HOUR_MINUTE_GENERIC_TZ
  String jmv() => DateFormat.jmv().format(this);

  /// HOUR_MINUTE_TZ
  String jmz() => DateFormat.jmz().format(this);

  /// HOUR_GENERIC_TZ
  String jv() => DateFormat.jv().format(this);

  /// HOUR_TZ
  String jz() => DateFormat.jz().format(this);

  /// MINUTE
  String m() => DateFormat.m().format(this);

  /// MINUTE_SECOND
  String ms() => DateFormat.ms().format(this);

  /// SECOND
  String s() => DateFormat.s().format(this);
}

extension IntTimeExtensions on int {
  Duration get millis => aMillisecond * this;
  Duration get seconds => aSecond * this;
  Duration get minutes => aMinute * this;
  Duration get hours => anHour * this;
  Duration get days => aDay * this;
  Duration get weeks => aWeek * this;
}

extension MyDurationExtensions on Duration {
  String format({
    bool abbreviated = true,
    String conjunction,
    String spacer,
    String delimiter,
    bool first = false,
    DurationTersity tersity = DurationTersity.minute,
  }) {
    return prettyDuration(
      this,
      abbreviated: abbreviated,
      conjunction: conjunction,
      spacer: spacer,
      delimiter: delimiter,
      tersity: tersity,
      locale: DurationLocale.fromLanguageCode(Intl.defaultLocale),
    );
  }
}
