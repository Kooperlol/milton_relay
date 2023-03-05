import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../models/event_model.dart';
import '../routing/routes.dart';
import '../services/event_service.dart';
import '../models/collections.dart';
import '../utils/text_util.dart';

class ViewUpcomingEventsScreen extends StatefulWidget {
  const ViewUpcomingEventsScreen({Key? key}) : super(key: key);

  @override
  State<ViewUpcomingEventsScreen> createState() =>
      _ViewUpcomingEventsScreenState();
}

class _ViewUpcomingEventsScreenState extends State<ViewUpcomingEventsScreen> {
  List<Widget> _upcomingEventList = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _setUpcomingEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: getAppBar('Upcoming Events'),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemBuilder: (context, index) {
                  if (_upcomingEventList.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Center(
                        child: Text('No Upcoming Events',
                            style: TextStyle(fontSize: 7.w)),
                      ),
                    );
                  }
                  return _upcomingEventList[index];
                },
                itemCount: _upcomingEventList.isEmpty
                    ? 1
                    : _upcomingEventList.length));
  }

  void _refreshEventsOnPop() {
    if (!mounted) return;
    if (GoRouter.of(context).location == Routes.viewUpcomingEvents.toPath) {
      _setUpcomingEvents();
      GoRouter.of(context).removeListener(_refreshEventsOnPop);
    }
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
                fit: BoxFit.fitWidth)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              height: 9.w,
              color: const Color.fromRGBO(255, 255, 255, 0.8),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                            '${event.event} (${DateFormat('MM-dd-yy').format(event.date)})',
                            style: TextStyle(fontSize: 4.w)),
                        Text(
                            '${timeOfDayToString(event.startTime)} to ${timeOfDayToString(event.endTime)}',
                            style: TextStyle(fontSize: 2.w))
                      ],
                    ),
                    const Expanded(child: SizedBox()),
                    IconButton(
                        icon: const Icon(Icons.keyboard_arrow_right),
                        iconSize: 3.w,
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

  void _setUpcomingEvents() async {
    setState(() => _loading = true);
    CollectionReference eventsCollection =
        FirebaseFirestore.instance.collection(Collections.events.toPath);
    QuerySnapshot eventsQuery = await eventsCollection
        .where('date',
            isLessThanOrEqualTo: DateTime.now()
                .add(DateTime.now().timeZoneOffset)
                .add(const Duration(days: 7))
                .microsecondsSinceEpoch)
        .where('date',
            isGreaterThanOrEqualTo: DateTime.now()
                .add(DateTime.now().timeZoneOffset)
                .microsecondsSinceEpoch)
        .orderBy('date')
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
      _upcomingEventList = events;
      _loading = false;
    });
  }
}
