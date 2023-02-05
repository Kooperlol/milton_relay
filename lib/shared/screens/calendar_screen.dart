import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/models/event.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/services/event_service.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import '../routing/routes.dart';
import '../utils/collections.dart';

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
              onPressed: () => context.push(Routes.addEventScreen.toPath),
              icon: const Icon(Icons.add_box, size: 45, color: Colors.white)))
          : getAppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            shadowColor: Colors.black,
            margin: const EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)),
            child: TableCalendar(
              focusedDay: _focusedDay,
              firstDay: DateTime.utc(2010),
              lastDay: DateTime.utc(2030),
              calendarFormat: _calendarFormat,
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
          if (_loading) const CircularProgressIndicator(),
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) {
                if (_eventList.isEmpty) {
                  return const Center(child: Text('No Events'));
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
      events.add(_getCardFromEvent(
          EventService().getEventFromJson(doc.data() as Map<String, dynamic>)));
    }
    setState(() {
      _eventList = events;
      _loading = false;
    });
  }

  Widget _getCardFromEvent(EventModel event) {
    return Card(
      shadowColor: Colors.black,
      margin: const EdgeInsets.all(10),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
            image: DecorationImage(
                image: event.bannerURL != 'default'
                    ? Image.network(event.bannerURL).image
                    : Image.asset('assets/default-event-banner.png').image,
                fit: BoxFit.fill)),
        child: Column(
          children: [
            const SizedBox(height: 100),
            Container(
              width: double.infinity,
              height: 50,
              color: const Color.fromRGBO(255, 255, 255, 0.8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(event.event, style: const TextStyle(fontSize: 20)),
                        Text(
                            '${timeOfDayToString(event.startTime)} to ${timeOfDayToString(event.endTime)}',
                            style: const TextStyle(fontSize: 16))
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    const Icon(Icons.keyboard_arrow_right, size: 35),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
