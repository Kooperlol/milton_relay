import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/event_model.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/event_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../routing/routes.dart';
import '../models/collections.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  // Events database collection.
  final eventsCollection =
      FirebaseFirestore.instance.collection(Collections.events.toPath);
  // Sets the focused and selected day to now by default.
  DateTime _focusedDay = DateTime.now(),
      _selectedDay = DateTime.utc(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // Whether the events on [_selectedDay] is loading.
  bool _loading = false;
  // Stores a list of the events on [_selectedDay] to display.
  List<Widget> _eventList = [];

  @override
  void initState() {
    super.initState();
    // Initializes the events on today's date.
    _setEventsOnDate();
  }

  @override
  Widget build(BuildContext context) {
    // Button that will be displayed in the App Bar to view events that are coming up.
    IconButton upcomingButton = IconButton(
        tooltip: 'Upcoming Events',
        onPressed: () => context.push(Routes.viewUpcomingEvents.toPath),
        icon: const Icon(Icons.next_week, color: Colors.white));
    // Button that will be displayed if the user is an Admin.
    // Used to create events.
    IconButton addEventButton = IconButton(
        tooltip: 'Add Event',
        onPressed: () => context.push(Routes.addEvent.toPath),
        icon: const Icon(Icons.add_box, color: Colors.white));
    return Scaffold(
      appBar: AuthService().isAdmin()
          ? AppBarWidget(
              title: 'Calendar', icons: [upcomingButton, addEventButton])
          : AppBarWidget(title: 'Calendar', icons: [upcomingButton]),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            shadowColor: Colors.black,
            color: ColorUtil.snowWhite,
            margin: EdgeInsets.all(1.5.w),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            // Displays a calendar with the values of [_focusedDay] and [_selectedDay].
            child: TableCalendar(
                rowHeight: 8.w,
                daysOfWeekHeight: 5.w,
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2010),
                lastDay: DateTime.utc(2030),
                calendarFormat: CalendarFormat.month,
                availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                daysOfWeekStyle: DaysOfWeekStyle(
                  weekdayStyle:
                      TextStyle(color: const Color(0xFF4F4F4F), fontSize: 2.w),
                  weekendStyle:
                      TextStyle(color: const Color(0xFF6A6A6A), fontSize: 2.w),
                ),
                headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle:
                        TextStyle(fontSize: 4.w, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, size: 4.w),
                    rightChevronIcon: Icon(Icons.chevron_right, size: 4.w),
                    formatButtonTextStyle: TextStyle(fontSize: 2.w)),
                calendarStyle: CalendarStyle(
                    weekNumberTextStyle: TextStyle(
                        fontSize: 3.w, color: const Color(0xFFBFBFBF)),
                    defaultTextStyle: TextStyle(fontSize: 3.w),
                    selectedTextStyle: TextStyle(
                      color: const Color(0xFFFAFAFA),
                      fontSize: 3.w,
                    ),
                    todayTextStyle: TextStyle(
                      color: const Color(0xFFFAFAFA),
                      fontSize: 3.w,
                    ),
                    weekendTextStyle: TextStyle(
                        color: const Color(0xFF5A5A5A), fontSize: 3.w),
                    outsideTextStyle: TextStyle(
                        color: const Color(0xFFAEAEAE), fontSize: 3.w),
                    selectedDecoration: BoxDecoration(
                        shape: BoxShape.circle, color: ColorUtil.red),
                    todayDecoration: BoxDecoration(
                        shape: BoxShape.circle, color: ColorUtil.darkRed)),
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                // When a day is selected, [_setEventsOnDate] is called to update the events display.
                // The selected and focused day on the calendar is updated.
                onDaySelected: (selectedDay, focusedDay) {
                  if (_loading) return;
                  setState(() {
                    _focusedDay = focusedDay;
                    _selectedDay = selectedDay;
                  });
                  _setEventsOnDate();
                }),
          ),
          SizedBox(
              width: double.infinity,
              height: 12.w,
              child: Center(
                child: Text(
                    'Events on ${DateFormat.yMMMEd().format(_selectedDay)}',
                    style: TextStyle(fontSize: 6.w)),
              )),
          if (_loading) const CircularProgressIndicator(),
          // Displays events on [_selectedDay] in a ListView.
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (_loading) return const SizedBox.square();
                if (_eventList.isEmpty) {
                  return Center(
                      child:
                          Text('No Events', style: TextStyle(fontSize: 3.w)));
                }
                return _eventList[index];
              },
              itemCount: _eventList.isEmpty ? 1 : _eventList.length,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns a Card which displays information about [event].
  Widget _getCardFromEvent(EventModel event) => Card(
        shadowColor: Colors.black,
        margin: const EdgeInsets.all(10),
        // Displays the banner of the event.
        child: Container(
          height: 20.w,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: event.bannerURL != 'default'
                      ? Image.network(event.bannerURL).image
                      : Image.asset('assets/default-event-banner.png').image,
                  fit: BoxFit.cover)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                height: 9.w,
                color: const Color.fromRGBO(255, 255, 255, 0.8),
                child: Padding(
                  padding: EdgeInsets.only(left: 1.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Time of event.
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(event.event, style: TextStyle(fontSize: 4.w)),
                          Text(
                              '${timeOfDayToString(event.startTime)} to ${timeOfDayToString(event.endTime)}',
                              style: TextStyle(fontSize: 2.w))
                        ],
                      ),
                      Expanded(child: Container()),
                      // Button to view event.
                      IconButton(
                          tooltip: 'View Event',
                          iconSize: 6.w,
                          icon: const Icon(Icons.keyboard_arrow_right),
                          onPressed: () {
                            context.push(Routes.viewEvent.toPath, extra: event);
                            GoRouter.of(context)
                                .addListener(_refreshEventsOnPop);
                          }),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );

  /// Sets [_eventList] to a list of widgets which displays the events on [_selectedDay].
  ///
  /// Orders the dates by the start-time-hour and start-time-minute.
  /// Calls the [_getCardFromEvent] when adding to the list.
  void _setEventsOnDate() async {
    setState(() => _loading = true);
    QuerySnapshot eventsQuery = await eventsCollection
        .where('date', isEqualTo: _selectedDay.microsecondsSinceEpoch)
        .orderBy('start-time-hour')
        .orderBy('start-time-minute')
        .get();
    List<Widget> events = [];
    for (QueryDocumentSnapshot doc in eventsQuery.docs) {
      EventModel event =
          EventService().getEventFromJson(doc.data() as Map<String, dynamic>);
      events.add(_getCardFromEvent(event));
    }
    setState(() {
      if (!mounted) return;
      _eventList = events;
      _loading = false;
    });
  }

  /// Listener to check for the view event screen being exited.
  ///
  /// Once exited, the [_setEventsOnDate] is called and the listener is removed.
  void _refreshEventsOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location.contains('/calendar')) {
      _setEventsOnDate();
      GoRouter.of(context).removeListener(_refreshEventsOnPop);
    }
  }
}
