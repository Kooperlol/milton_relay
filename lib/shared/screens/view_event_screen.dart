import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/event.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/utils/collections.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ViewEventScreen extends StatelessWidget {
  final EventModel event;
  const ViewEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  height: 30.w,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: event.bannerURL != 'default'
                              ? Image.network(event.bannerURL).image
                              : Image.asset('assets/default-event-banner.png')
                                  .image,
                          fit: BoxFit.cover))),
              SizedBox(height: 5.w),
              Text(event.event,
                  style: TextStyle(
                      fontSize: 7.w, decoration: TextDecoration.underline),
                  overflow: TextOverflow.ellipsis),
              SizedBox(height: 3.w),
              Row(
                children: [
                  Text('Date: ', style: TextStyle(fontSize: 5.w)),
                  Icon(Icons.calendar_today, size: 5.w),
                  const SizedBox(width: 3),
                  Text(DateFormat('MM-dd-yy').format(event.date),
                      style: TextStyle(fontSize: 5.w))
                ],
              ),
              SizedBox(height: 3.w),
              Row(
                children: [
                  Text('Time: ', style: TextStyle(fontSize: 5.w)),
                  Icon(Icons.access_time, size: 5.w),
                  const SizedBox(width: 3),
                  Text(
                      '${timeOfDayToString(event.startTime)} to ${timeOfDayToString(event.endTime)}',
                      style: TextStyle(fontSize: 5.w))
                ],
              ),
              SizedBox(height: 3.w),
              Row(
                children: [
                  Text('Location: ', style: TextStyle(fontSize: 5.w)),
                  Icon(Icons.location_on, size: 5.w),
                  Expanded(
                      child:
                          Text(event.location, style: TextStyle(fontSize: 4.w)))
                ],
              ),
              SizedBox(height: 3.w),
              Row(
                children: [
                  Text('Description: ', style: TextStyle(fontSize: 5.w)),
                  Icon(Icons.description, size: 5.w),
                  const SizedBox(width: 3),
                  Expanded(
                      child: Text(event.description,
                          style: TextStyle(fontSize: 4.w)))
                ],
              ),
              if (AuthService().isAdmin())
                Column(
                  children: [
                    createButton('Delete Event', double.infinity,
                        () => _deleteEvent(context))
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }

  void _deleteEvent(BuildContext context) async {
    try {
      if (event.bannerURL != 'default') {
        Reference storageRef =
            FirebaseStorage.instance.ref().child("events/${event.id}");
        await storageRef.delete();
      }
      CollectionReference eventsCollection =
          FirebaseFirestore.instance.collection(Collections.events.toPath);
      await eventsCollection.doc(event.id).delete();
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to delete an event: ${error.toString()}");
    }

    if (!context.mounted) return;

    showSnackBar(context, 'Event Deleted');
    context.pop();
  }
}
