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
          ? getAppBar('Calendar',
              rightIcon: IconButton(
                  onPressed: () => context.push(Routes.addEvent.toPath),
                  iconSize: 6.w,
                  icon: const Icon(Icons.add_box, color: Colors.white)))
          : getAppBar('Calendar'),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //createButton('View Upcoming Events', 100.w,
          //   () => context.push(Routes.viewUpcomingEvents.toPath)),
          Container(
            color: ColorUtil.blue,
            child: Card(
              shadowColor: Colors.black,
              margin: EdgeInsets.all(1.5.w),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0)),
              child: TableCalendar(
                rowHeight: 8.w,
                daysOfWeekHeight: 5.w,
                focusedDay: _focusedDay,
                firstDay: DateTime.utc(2010),
                lastDay: DateTime.utc(2030),
                calendarFormat: _calendarFormat,
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
          ),
          Container(
            height: 2.w,
            color: ColorUtil.blue,
          ),
          Container(
            color: ColorUtil.blue,
            child: Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50))),
              child: SizedBox(
                  width: double.infinity,
                  height: 12.w,
                  child: Center(
                    child: Text('Events', style: TextStyle(fontSize: 6.w)),
                  )),
            ),
          ),
          SizedBox(height: 4.w),
          if (_loading) const CircularProgressIndicator(),
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
              height: 9.w,
              color: const Color.fromRGBO(255, 255, 255, 0.8),
              child: Padding(
                padding: EdgeInsets.only(left: 1.w),
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
                    Expanded(child: Container()),
                    IconButton(
                        iconSize: 6.w,
                        icon: const Icon(Icons.keyboard_arrow_right),
                        onPressed: () {
                          context.push(Routes.viewEvent.toPath, extra: event);
                          GoRouter.of(context).addListener(_refreshEventsOnPop);
                        }),
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
