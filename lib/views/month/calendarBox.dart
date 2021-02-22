import 'package:flutter/material.dart';
import '../../services/shiftTracker.dart';
import '../../services/dateTracker.dart';

class CalendarBox extends StatelessWidget {
  // final int idx;
  // final int month;
  // final int year;
  final DateTime date;
  final int month;

  CalendarBox({@required int idx, @required DateTime date})
      : this.month = date.month,
        this.date = _getDate(idx, date);

  static DateTime _getDate(int idx, DateTime date) {
    int offset = date.trimMonth().weekday % 7;
    return DateTime(date.year, date.month, idx - offset);
  }

  @override
  Widget build(BuildContext context) {
    bool hasShifts = ShiftTracker.of(context)
        .shifts
        .any((element) => element.scheduledStartTime.trimDay() == date);

    // Color backgroundColor = DateTime.now().trimDay() == date
    //     ? Theme.of(context).focusColor
    //     : date.month == month
    //         ? Theme.of(context).cardColor
    //         : Theme.of(context).disabledColor;

    return GestureDetector(
      onTapUp: (details) {
        DateTracker.of(context).update(date, notify: false);
        Navigator.pushNamed(
          context,
          '/day',
        );
        // Navigator.push(context, MaterialPageRoute(builder: (context) {
        //   return Container(color: Colors.black);
        //   // return InheritedShiftWidget(
        //   //     shiftTracker: shiftTracker, child: DayView(initialDay: date));
        // }));
      },
      child: Hero(
        tag: date.trimDay().toString(),
        // flightShuttleBuilder: (BuildContext flightContext,
        //         Animation<double> animation,
        //         HeroFlightDirection flightDirection,
        //         BuildContext fromHeroContext,
        //         BuildContext toHeroContext) =>
        //     Material(
        //         color: Theme.of(context).backgroundColor,
        //         child: toHeroContext.widget),
        child: Card(
            margin: EdgeInsets.all(3),
            elevation: 5,
            color: DateTime.now().trimDay() == date
                ? Theme.of(context).focusColor
                : date.month == month
                    ? Theme.of(context).cardColor
                    : Theme.of(context).disabledColor,
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Theme.of(context).primaryColor, width: 1.5),
                borderRadius: BorderRadius.circular(5.0)),
            child: Stack(
              children: [
                Padding(
                    padding: EdgeInsets.only(top: 2, left: 3),
                    child: Text(date.day.toString())),
                Align(
                    alignment: Alignment.bottomRight,
                    child: hasShifts
                        ? FractionallySizedBox(
                            widthFactor: 0.4,
                            heightFactor: 0.4,
                            child: Container(
                                color: Theme.of(context).primaryColor))
                        : null),
              ],
            )),
      ),
    );
  }
}
