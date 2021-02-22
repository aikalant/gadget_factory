import 'package:flutter/material.dart';
import '../../services/shiftTracker.dart';
import '../../services/dateTracker.dart';
import 'shiftView.dart';

class DayView extends StatefulWidget {
  final String title;

  DayView({this.title});

  @override
  State<StatefulWidget> createState() {
    return DayViewState();
  }
}

class DayViewState extends State<DayView> {
  //DateTime day;
  SelectedDate selectedDate;
  List<Shift> shiftsOfTheDay;

  void changeDay(DateTime newDay) {
    selectedDate.update(newDay, notify: true);
  }

  @override
  Widget build(BuildContext context) {
    //day = day ?? widget.initialDay;

    selectedDate = DateTracker.of(context);
    shiftsOfTheDay = ShiftTracker.of(context)
        .shifts
        .where((shift) => selectedDate.date
            .isAtSameMomentAs(shift.scheduledStartTime.trimDay()))
        .toList();
    shiftsOfTheDay
        .sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));

    return Hero(
      tag: selectedDate.date.trimDay().toString(),
      // flightShuttleBuilder: (BuildContext flightContext,
      //         Animation<double> animation,
      //         HeroFlightDirection flightDirection,
      //         BuildContext fromHeroContext,
      //         BuildContext toHeroContext) =>
      //     Material(
      //         color: Theme.of(context).cardColor, child: toHeroContext.widget),
      child: Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.arrow_left_rounded),
                        color: Theme.of(context).primaryColor,
                        splashColor: Theme.of(context).accentColor,
                        splashRadius: 25.0,
                        iconSize: 50,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        onPressed: () {
                          changeDay(
                              selectedDate.date.subtract(Duration(days: 1)));
                        },
                      ),
                      SizedBox(
                          width: 120,
                          child: ElevatedButton(
                              onPressed: () {
                                showDatePicker(
                                        context: context,
                                        initialDate: selectedDate.date,
                                        firstDate: DateUtilities.min,
                                        lastDate: DateUtilities.max)
                                    .then((value) => changeDay(value));
                              },
                              child: Text(selectedDate.date.dateString()))),
                      IconButton(
                        icon: Icon(Icons.arrow_right_rounded),
                        color: Theme.of(context).primaryColor,
                        splashColor: Theme.of(context).accentColor,
                        splashRadius: 25.0,
                        iconSize: 50,
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        onPressed: () {
                          changeDay(selectedDate.date.add(Duration(days: 1)));
                        },
                      ),
                    ]),
              ),
              Expanded(
                child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    children: shiftsOfTheDay
                        .map<ShiftView>((shift) => ShiftView(shift: shift))
                        .toList()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
