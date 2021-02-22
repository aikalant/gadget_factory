import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'calendarBox.dart';
import '../../services/dateTracker.dart';

class MonthView extends StatefulWidget {
  final String title;
  MonthView({this.title});
  @override
  State<StatefulWidget> createState() {
    return MonthViewState();
  }
}

class MonthViewState extends State<MonthView> {
  ValueNotifier<int> monthIndex = ValueNotifier(0);
  SelectedDate selectedDate;
  PageController pageController;
  // int get month => _dateTracker.selected.month;
  // int get year => _dateTracker.selected.year;
  //List<Shift> shiftsOfTheMonth;

  //this function is called from the selector, not the pageview. It will consequentially call changeFromPageView
  void changeFromSelector({int year, int month}) {
    int newIndex =
        DateTime(year ?? selectedDate.year, month ?? selectedDate.month)
            .toMonthIndex();

    if (newIndex != monthIndex.value) {
      if ((newIndex - monthIndex.value).abs() <= 5)
        pageController.animateToPage(newIndex,
            duration: Duration(milliseconds: 1000),
            curve: Curves.fastLinearToSlowEaseIn);
      else
        pageController.jumpToPage(newIndex);
    }
  }

  //this function is called from the pageview, but also from the selector after changeFromSelector() is processed
  void changeFromPageView(int newIndex) {
    selectedDate.update(DateUtilities.monthIndexToDate(newIndex),
        notify: false); //dont notify because we don't want the page to stop
    if (newIndex != monthIndex.value) monthIndex.value = newIndex;
  }

  @override
  Widget build(BuildContext context) {
    selectedDate = DateTracker.of(context);
    pageController = null;
    monthIndex.value = selectedDate.monthIndex;
    // shiftsOfTheMonth = ShiftTracker.of(context)
    //     .shifts
    //     .where((shift) =>
    //         selectedDate.year == shift.scheduledStartTime.year &&
    //         selectedDate.month == shift.scheduledStartTime.month)
    //     .toList();
    // shiftsOfTheMonth
    //     .sort((a, b) => a.scheduledStartTime.compareTo(b.scheduledStartTime));

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: ValueListenableBuilder(
                  builder: (BuildContext context, int value, Widget child) {
                    return Row(
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
                              changeFromSelector(month: selectedDate.month - 1);
                            },
                          ),
                          SizedBox(
                              height: 50,
                              child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Card(
                                        elevation: 15,
                                        child: DropdownButton<int>(
                                            value: selectedDate.month,
                                            iconSize: 0,
                                            icon: Container(),
                                            underline: Container(),
                                            onChanged: (int newValue) {
                                              changeFromSelector(
                                                  month: newValue);
                                            },
                                            items: List<
                                                    DropdownMenuItem<
                                                        int>>.generate(
                                                12,
                                                (index) => DropdownMenuItem<
                                                        int>(
                                                    key: ObjectKey(index),
                                                    value: index = index + 1,
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: Text(
                                                        DateFormat("MMMM")
                                                            .format(DateTime(
                                                                selectedDate
                                                                    .year,
                                                                index)),
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ))))),
                                    Card(
                                        elevation: 15,
                                        child: DropdownButton<int>(
                                            value: selectedDate.year,
                                            iconSize: 0,
                                            icon: Container(),
                                            underline: Container(),
                                            onChanged: (int newValue) {
                                              changeFromSelector(
                                                  year: newValue);
                                            },
                                            items: List<
                                                    DropdownMenuItem<
                                                        int>>.generate(
                                                DateUtilities.yearRange,
                                                (index) =>
                                                    DropdownMenuItem<int>(
                                                      value: index = index +
                                                          DateUtilities
                                                              .min.year,
                                                      child: SizedBox(
                                                          width: 60,
                                                          child: Text(
                                                            index.toString(),
                                                            textAlign: TextAlign
                                                                .center,
                                                          )),
                                                    ))))
                                  ])),
                          IconButton(
                            icon: Icon(Icons.arrow_right_rounded),
                            color: Theme.of(context).primaryColor,
                            splashColor: Theme.of(context).accentColor,
                            splashRadius: 25.0,
                            iconSize: 50,
                            padding: EdgeInsets.symmetric(horizontal: 30),
                            onPressed: () {
                              changeFromSelector(month: selectedDate.month + 1);
                            },
                          ),
                        ]);
                  },
                  valueListenable: monthIndex,
                )),
            Expanded(
              child: PageView.custom(
                  key: GlobalKey(),
                  onPageChanged: changeFromPageView,
                  controller: pageController = PageController(
                      initialPage: selectedDate.monthIndex, keepPage: false),
                  childrenDelegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                    return Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 350),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: List<Widget>.generate(
                                    7,
                                    (index) => Flexible(
                                          child: Center(
                                              child: Text(const [
                                            "Sun",
                                            "Mon",
                                            "Tue",
                                            "Wed",
                                            "Thu",
                                            "Fri",
                                            "Sat"
                                          ][index])),
                                        )),
                              ),
                              ...List<Widget>.generate(
                                  6,
                                  (rowIdx) => Flexible(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: List<Widget>.generate(
                                                7,
                                                (colIdx) => Flexible(
                                                      child: AspectRatio(
                                                        aspectRatio: 1,
                                                        child: CalendarBox(
                                                            idx: rowIdx * 7 +
                                                                colIdx +
                                                                1,
                                                            date: DateUtilities
                                                                .monthIndexToDate(
                                                                    index)),
                                                      ),
                                                    ))),
                                      )),
                            ]),
                      ),
                    );

                    //     Align(
                    //   alignment: Alignment.topCenter,
                    //   child: ConstrainedBox(
                    //       constraints: BoxConstraints(maxWidth: 350),
                    //       child: Flexible(
                    //         child: Table(
                    //           //defaultColumnWidth: FixedColumnWidth(50),
                    //           children: [
                    //             TableRow(
                    //                 children: List<Widget>.generate(
                    //                     7,
                    //                     (index) => Center(
                    //                             child: Text(const [
                    //                           "Sun",
                    //                           "Mon",
                    //                           "Tue",
                    //                           "Wed",
                    //                           "Thu",
                    //                           "Fri",
                    //                           "Sat"
                    //                         ][index])))),
                    //             ...Iterable<TableRow>.generate(
                    //                 6,
                    //                 (rowIdx) => TableRow(
                    //                     children: List<Widget>.generate(
                    //                         7,
                    //                         (colIdx) => Flexible(
                    //                               child: AspectRatio(
                    //                                   aspectRatio: 1,
                    //                                   //height: 50,
                    //                                   child: CalendarBox(
                    //                                       idx: rowIdx * 7 +
                    //                                           colIdx +
                    //                                           1,
                    //                                       date: DateUtilities
                    //                                           .monthIndexToDate(
                    //                                               index))),
                    //                             ))))
                    //           ],
                    //         ),
                    //       )),
                    // );
                  }, childCount: DateUtilities.monthRange)),
            ),
          ],
        ),
      ),
    );
  }
}
