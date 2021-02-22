import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SelectedDate extends ChangeNotifier {
  // int _monthIndex;
  // int _dayIndex;

  DateTime _date;

  SelectedDate([DateTime initialDate]) {
    update(initialDate ?? DateTime.now(), notify: false);
  }

  int get monthIndex => _date.toMonthIndex(); // _monthIndex;
  int get dayIndex => _date.toDayIndex(); //_dayIndex;

  DateTime get date =>
      _date; //DateUtils.addDaysToDate(DateUtilities.min, _dayIndex);
  int get year => date.year;
  int get month => date.month;
  int get day => date.day;

  void update(DateTime date, {bool notify = true}) {
    if (date == null ||
        date.isBefore(DateUtilities.min) ||
        date.trimDay().isAfter(DateUtilities.max))
      throw Exception("Selected date [" + date.dateString() + "] out of range");

    // _dayIndex = date.toDayIndex();
    // _monthIndex = date.toMonthIndex();
    date = date.trimDay();
    if (date != _date) {
      _date = date.trimDay();
      if (notify) notifyListeners();
    }
  }

  void notify() => notifyListeners();
}

class DateTracker extends InheritedNotifier<SelectedDate> {
  final SelectedDate selectedDate;

  DateTracker({@required this.selectedDate, @required Widget child})
      : super(notifier: selectedDate, child: child);

  static SelectedDate of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<DateTracker>()
        .selectedDate;
  }
}

extension DateUtilities on DateTime {
  static final DateTime min = DateTime(1900, 1);
  static final DateTime max = DateTime(2101, 1, 0);
  static final int monthRange = DateUtils.monthDelta(min, max) + 1;
  static final int dayRange = max.difference(min).inDays + 1;
  static final int yearRange = max.year - min.year + 1;

  int toMonthIndex() => DateUtils.monthDelta(min, this.trimMonth());
  int toDayIndex() => this.trimDay().difference(min).inDays;

  static DateTime dayIndexToDate(int dayIndex) =>
      min.add(Duration(days: dayIndex));
  static DateTime monthIndexToDate(int monthIndex) =>
      DateUtils.addMonthsToMonthDate(min, monthIndex);

  DateTime trimDay() => DateTime(this.year, this.month, this.day);
  DateTime trimMonth() => DateTime(this.year, this.month);
  //static final DateFormat _formatter = DateFormat('MMM dd, yyyy');
  String dateString() => DateFormat('MMM dd, yyyy').format(this);
  String timeString() => DateFormat('hh:mm a').format(this);
}

// class DateTracker {
//   DateTime selected = DateTime.now().trimDay();
// }

// class InheritedDateTracker extends InheritedWidget {
//   final DateTracker dateTracker;
//   DateTime get selected => dateTracker.selected;
//   static final DateTime min = DateTime(1900, 1);
//   static final DateTime max = DateTime(2101, 1, 0);
//   static final int monthRange = DateUtils.monthDelta(min, max) + 1;
//   static final int yearRange = max.year - min.year + 1;

//   set selected(DateTime val) {
//     dateTracker.selected = val.trimDay();
//   }

//   static int toMonthIndex(int year, int month) {
//     return DateUtils.monthDelta(min, DateTime(year, month));
//   }

//   static DateTime monthIndexToDate(int index) {
//     return DateUtils.addMonthsToMonthDate(min, index);
//   }

//   DateTime get nextDay =>
//       DateTime(selected.year, selected.month, selected.day + 1);
//   DateTime get previousDay =>
//       DateTime(selected.year, selected.month, selected.day - 1);

//   DateTime get nextMonth => DateTime(selected.year, selected.month + 1);
//   DateTime get previousMonth => DateTime(selected.year, selected.month - 1);

//   InheritedDateTracker({
//     DateTracker dateTracker,
//     Widget child,
//   })  : dateTracker = dateTracker,
//         super(child: child);

//   static InheritedDateTracker of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<InheritedDateTracker>();
//   }

//   @override
//   bool updateShouldNotify(InheritedDateTracker oldWidget) {
//     return oldWidget.selected != selected;
//   }
// }
