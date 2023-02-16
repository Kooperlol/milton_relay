import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/event.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/event_service.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:table_calendar/table_calendar.dart';

import '../routing/routes.dart';
import '../utils/collections.dart';
import '../utils/color_util.dart';
import '../utils/text_util.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now(), _selectedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  bool _loading = false;
  List<Widget> _eventList = [];

  @override
  void initState() {
    super.initState();
    _setEventsOnDate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthService().isAdmin()
          ? getAppBarWithIconRight(IconButton(
              onPressed: () => context.push(Routes.addEvent.toPath),
              icon: const Icon(Icons.add_box, size: 45, color: Colors.white)))
          : getAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          createButton('View Upcoming Events', double.infinity,
              () => context.push(Routes.viewUpcomingEvents.toPath)),
          Card(
            shadowColor: Colors.black,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: TableCalendar(
              rowHeight: 8.w,
              daysOfWeekHeight: 5.w,
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010),
              lastDay: DateTime.utc(2030),
              calendarFormat: _calendarFormat,
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle:
                    TextStyle(color: const Color(0xFF4F4F4F), fontSize: 2.w),
                weekendStyle:
                    TextStyle(color: const Color(0xFF6A6A6A), fontSize: 2.w),
              ),
              headerStyle: HeaderStyle(
                  titleTextStyle: TextStyle(fontSize: 2.w),
                  leftChevronIcon: Icon(Icons.chevron_left, size: 2.5.w),
                  rightChevronIcon: Icon(Icons.chevron_right, size: 2.5.w),
                  formatButtonTextStyle: TextStyle(fontSize: 2.w)),
              calendarStyle: CalendarStyle(
                  weekNumberTextStyle:
                      TextStyle(fontSize: 2.w, color: const Color(0xFFBFBFBF)),
                  defaultTextStyle: TextStyle(fontSize: 2.w),
                  selectedTextStyle: TextStyle(
                    color: const Color(0xFFFAFAFA),
                    fontSize: 2.w,
                  ),
                  todayTextStyle: TextStyle(
                    color: const Color(0xFFFAFAFA),
                    fontSize: 2.w,
                  ),
                  weekendTextStyle:
                      TextStyle(color: const Color(0xFF5A5A5A), fontSize: 2.w),
                  outsideTextStyle:
                      TextStyle(color: const Color(0xFFAEAEAE), fontSize: 2.w),
                  selectedDecoration: BoxDecoration(
                      shape: BoxShape.circle, color: ColorUtil.red),
                  todayDecoration: BoxDecoration(
                      shape: BoxShape.circle, color: ColorUtil.darkRed)),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (_loading) return;
                setState(() {
                  _focusedDay = focusedDay;
                  _selectedDay = selectedDay;
                });
                _setEventsOnDate();
              },
              onFormatChanged: (format) =>
                  setState(() => _calendarFormat = format),
            ),
          ),
          Text('Events on ${DateFormat('MM-dd-yy').format(_selectedDay)}',
              style: TextStyle(fontSize: 5.w)),
          if (_loading) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (_loading) return const SizedBox.square();
                if (_eventList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10, 0, 0),
                    child: Center(
                        child:
                            Text('No Events', style: TextStyle(fontSize: 3.w))),
                  );
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

  Widget _getCardFromEvent(EventModel event) {
    return Card(
      shadowColor: Colors.black,
      margin: const EdgeInsets.all(10),
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
              height: 8.w,
              color: const Color.fromRGBO(255, 255, 255, 0.8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                    Expanded(
                        child: Container(
                      color: Colors.grey,
                    )),
                    Container(
                      color: Colors.blueGrey,
                      child: IconButton(
                          icon: Icon(Icons.keyboard_arrow_right, size: 8.w),
                          onPressed: () {
                            context.push(Routes.viewEvent.toPath, extra: event);
                            GoRouter.of(context)
                                .addListener(_refreshEventsOnPop);
                          }),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _setEventsOnDate() async {
    setState(() => _loading = true);
    CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection(Collections.events.toPath);
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
      _eventList = events;
      _loading = false;
    });
  }

  void _refreshEventsOnPop() {
    if (GoRouter.of(context).location.contains('/calendar')) {
      _setEventsOnDate();
      GoRouter.of(context).removeListener(_refreshEventsOnPop);
    }
  }
}
