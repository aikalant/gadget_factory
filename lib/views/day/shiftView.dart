import 'package:flutter/material.dart';
import '../../services/shiftTracker.dart';
import '../../services/dateTracker.dart';

class ShiftView extends StatelessWidget {
  final Shift shift;

  ShiftView({this.shift}) : super(key: ObjectKey(shift));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 500),
        child: Card(
            shape: RoundedRectangleBorder(
                side: BorderSide(
                    color: Theme.of(context).primaryColor, width: 3)),
            margin: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
            elevation: 10,
            color: getCardColor(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              child: Column(children: [
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: startRow())),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: endRow())),
                Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(children: gadgetRow())),
              ]),
            )),
      ),
    );
  }

  Color getCardColor(BuildContext context) {
    return Theme.of(context).cardColor;
    // switch (shift.status) {
    //   case ShiftStatus.Completed:
    //     return Colors.grey[600];
    //   case ShiftStatus.Started:
    //     return Colors.yellow[300];
    //   case ShiftStatus.NotStarted:
    //     return Colors.green[300];
    //   default:
    //     return Theme.of(context).primaryColor;
    // }
  }

  List<Widget> startRow() {
    List<Widget> returnList = [];

    returnList
        .add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text("Start Time:"),
      Text(shift.scheduledStartTime.timeString()),
    ]));

    if (shift.status == ShiftStatus.Started ||
        shift.status == ShiftStatus.Completed)
      returnList
          .add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text("Signed In:"),
        Text(shift.signInTime.timeString()),
      ]));
    else
      returnList.add(SizedBox(
          height: 25,
          child: ElevatedButton(
              onPressed: () {
                shift
                    .signIn(shift.scheduledStartTime.add(Duration(minutes: 4)));
              },
              child: Text("Sign In"))));

    return returnList;
  }

  List<Widget> endRow() {
    List<Widget> returnList = [];

    returnList
        .add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      Text("End Time:"),
      Text(shift.scheduledEndTime.timeString()),
    ]));

    if (shift.status == ShiftStatus.Completed)
      returnList
          .add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text("Signed Out:"),
        Text(shift.signOutTime.timeString()),
      ]));
    else if (shift.status == ShiftStatus.Started)
      returnList.add(SizedBox(
          height: 25,
          child: ElevatedButton(
              onPressed: () {
                shift.signOut(
                    shift.scheduledEndTime.subtract(Duration(minutes: 4)));
              },
              child: Text("Sign Out"))));

    return returnList;
  }

  List<Widget> gadgetRow() {
    List<Widget> returnList = [];

    if (shift.status == ShiftStatus.Completed)
      returnList
          .add(Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Text("Gadgets Made:"),
        Text(shift.gadgetsMade.toString()),
      ]));
    return returnList;
  }
}
