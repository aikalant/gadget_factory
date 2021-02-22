import 'dart:collection';

import 'package:flutter/material.dart';

class ShiftManager extends ChangeNotifier {
  final List<Shift> _shifts = <Shift>[];
  UnmodifiableListView<Shift> get shifts =>
      UnmodifiableListView<Shift>(_shifts);

  ShiftManager() {
    DateTime now = DateTime.now();
    DateTime yesterday = now.add(Duration(days: -1));
    DateTime tomorrow = now.add(Duration(days: 1));
    _shifts.addAll([
      Shift(this, DateTime(yesterday.year, yesterday.month, yesterday.day, 9),
          DateTime(yesterday.year, yesterday.month, yesterday.day, 17)),
      Shift.completed(
          this,
          DateTime(now.year, now.month, now.day, 2),
          DateTime(now.year, now.month, now.day, 8),
          DateTime(now.year, now.month, now.day, 2, 1),
          DateTime(now.year, now.month, now.day, 7, 59),
          10),
      Shift.started(
          this,
          DateTime(now.year, now.month, now.day, 9),
          DateTime(now.year, now.month, now.day, 17),
          DateTime(now.year, now.month, now.day, 9, 5)),
      Shift(this, DateTime(now.year, now.month, now.day, 18),
          DateTime(now.year, now.month, now.day, 19)),
      Shift(this, DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9),
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17)),
    ]);
  }
  void notify() => notifyListeners();
}

class ShiftTracker extends InheritedNotifier<ShiftManager> {
  final ShiftManager shiftManager;
  ShiftTracker({@required this.shiftManager, @required Widget child})
      : super(notifier: shiftManager, child: child);

  static ShiftManager of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ShiftTracker>()
        .shiftManager;
  }
}

enum ShiftStatus { NotStarted, Started, Completed }

class Shift {
  static const _gracePeriod = Duration(hours: 1);

  final ShiftManager shiftManager;

  ShiftStatus _status;
  ShiftStatus get status => _status;

  DateTime _scheduledStartTime;
  DateTime get scheduledStartTime => _scheduledStartTime;

  DateTime _scheduledEndTime;
  DateTime get scheduledEndTime => _scheduledEndTime;

  DateTime _signInTime;
  DateTime get signInTime => _signInTime;

  DateTime _signOutTime;
  DateTime get signOutTime => _signOutTime;

  int _gadgetsMade;
  int get gadgetsMade => _gadgetsMade;

  Shift(this.shiftManager, this._scheduledStartTime, this._scheduledEndTime)
      : _status = ShiftStatus.NotStarted {
    if (!_validate()) throw new Exception("DateTime Validation Failed");
  }
  Shift.started(this.shiftManager, this._scheduledStartTime,
      this._scheduledEndTime, this._signInTime)
      : _status = ShiftStatus.Started {
    if (!_validate()) throw new Exception("DateTime Validation Failed");
  }
  Shift.completed(
      this.shiftManager,
      this._scheduledStartTime,
      this._scheduledEndTime,
      this._signInTime,
      this._signOutTime,
      this._gadgetsMade)
      : _status = ShiftStatus.Completed {
    if (!_validate()) throw new Exception("DateTime Validation Failed");
  }

  static bool _withinGrace(DateTime time, DateTime target) =>
      time.isAfter(target.subtract(_gracePeriod)) &&
      time.isBefore(target.add(_gracePeriod));
  bool _validate() {
    if (shiftManager == null ||
        _scheduledStartTime == null ||
        _scheduledEndTime == null ||
        !_scheduledStartTime.isBefore(_scheduledEndTime)) return false;

    switch (_status) {
      case ShiftStatus.NotStarted:
        return _signInTime == null &&
            _signOutTime == null &&
            _gadgetsMade == null;
      case ShiftStatus.Started:
        return _signInTime != null &&
            _signOutTime == null &&
            _gadgetsMade == null &&
            _withinGrace(_signInTime, _scheduledStartTime);
      case ShiftStatus.Completed:
        return _signInTime != null &&
            _signOutTime != null &&
            _gadgetsMade >= 0 &&
            _withinGrace(_signInTime, _scheduledStartTime) &&
            _withinGrace(_signOutTime, _scheduledEndTime);
      default:
        return false;
    }
  }

  void signIn(DateTime time) {
    if (time == null) throw Exception("Error Signing In Shift");
    if (_status != ShiftStatus.NotStarted)
      throw Exception("Error Signing In Shift");
    if (!_withinGrace(time, _scheduledStartTime))
      throw Exception("Error Signing In Shift");
    _signInTime = time;
    _status = ShiftStatus.Started;
    shiftManager.notify();
  }

  void signOut(DateTime time, [int gadgetsMade = 0]) {
    if (time == null || gadgetsMade < 0)
      throw Exception("Error Signing Out Shift");
    if (_status != ShiftStatus.Started)
      throw Exception("Error Signing Out Shift");
    if (!_withinGrace(time, _scheduledEndTime))
      throw Exception("Error Signing Out Shift");
    _signOutTime = time;
    _gadgetsMade = gadgetsMade;
    _status = ShiftStatus.Completed;
    shiftManager.notify();
  }
}

// class ShiftTracker extends ChangeNotifier {
//   final List<Shift> _shifts;
//   bool _disposed = false;
//   UnmodifiableListView<Shift> get shifts =>
//       UnmodifiableListView<Shift>(_shifts);

//   ShiftTracker() : _shifts = <Shift>[] {
//     DateTime now = DateTime.now();
//     DateTime yesterday = now.add(Duration(days: -1));
//     DateTime tomorrow = now.add(Duration(days: 1));
//     _shifts.addAll([
//       Shift(this, DateTime(yesterday.year, yesterday.month, yesterday.day, 9),
//           DateTime(yesterday.year, yesterday.month, yesterday.day, 17)),
//       Shift.completed(
//           this,
//           DateTime(now.year, now.month, now.day, 2),
//           DateTime(now.year, now.month, now.day, 8),
//           DateTime(now.year, now.month, now.day, 2, 1),
//           DateTime(now.year, now.month, now.day, 7, 59),
//           10),
//       Shift.started(
//           this,
//           DateTime(now.year, now.month, now.day, 9),
//           DateTime(now.year, now.month, now.day, 17),
//           DateTime(now.year, now.month, now.day, 9, 5)),
//       Shift(this, DateTime(now.year, now.month, now.day, 18),
//           DateTime(now.year, now.month, now.day, 19)),
//       Shift(this, DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9),
//           DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 17)),
//     ]);
//   }

//   @override
//   void dispose() {
//     _disposed = true;
//     super.dispose();
//   }

//   void notify() {
//     if (!_disposed) notifyListeners();
//   }
// }

// class InheritedShiftWidget extends InheritedWidget {
//   final ShiftTracker shiftTracker;

//   InheritedShiftWidget({
//     this.shiftTracker,
//     Widget child,
//   }) : super(child: child);

//   static InheritedShiftWidget of(BuildContext context) {
//     return context.dependOnInheritedWidgetOfExactType<InheritedShiftWidget>();
//   }

//   @override
//   bool updateShouldNotify(InheritedShiftWidget oldWidget) {
//     return true;
//   }
// }
