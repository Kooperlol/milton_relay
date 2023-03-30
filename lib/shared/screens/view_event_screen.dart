import 'dart:io';

import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/event_model.dart';
import 'package:milton_relay/shared/routing/routes.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/models/collections.dart';
import 'package:milton_relay/shared/utils/display_util.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:social_share/social_share.dart';

import '../utils/color_util.dart';

class ViewEventScreen extends StatelessWidget {
  final EventModel event;
  const ViewEventScreen({Key? key, required this.event}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: event.event),
      body: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.all(3.w),
          elevation: 2,
          color: ColorUtil.snowWhite,
          child: Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Date: ',
                      style: TextStyle(fontSize: 5.w, color: ColorUtil.blue)),
                  WidgetSpan(
                      child: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: Icon(Icons.calendar_today, size: 5.w),
                  )),
                  TextSpan(
                      text: DateFormat.yMMMMd().format(event.date),
                      style: TextStyle(fontSize: 5.w, color: Colors.black))
                ])),
                SizedBox(height: 3.w),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Time: ',
                      style: TextStyle(fontSize: 5.w, color: ColorUtil.blue)),
                  WidgetSpan(
                      child: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: Icon(Icons.access_time, size: 5.w),
                  )),
                  TextSpan(
                      text:
                          '${timeOfDayToString(event.startTime)} to ${timeOfDayToString(event.endTime)}',
                      style: TextStyle(fontSize: 5.w, color: Colors.black))
                ])),
                SizedBox(height: 3.w),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Location: ',
                      style: TextStyle(fontSize: 5.w, color: ColorUtil.blue)),
                  WidgetSpan(
                      child: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: Icon(Icons.access_time, size: 5.w),
                  )),
                  TextSpan(
                      text: event.location,
                      style: TextStyle(fontSize: 5.w, color: Colors.black))
                ])),
                SizedBox(height: 3.w),
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Description: ',
                      style: TextStyle(fontSize: 5.w, color: ColorUtil.blue)),
                  WidgetSpan(
                      child: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: Icon(Icons.description_outlined, size: 5.w),
                  )),
                  TextSpan(
                      text: event.description,
                      style: TextStyle(fontSize: 5.w, color: Colors.black))
                ])),
                SizedBox(height: 3.w),
                Center(
                  child: GFButton(
                      onPressed: _exportEvent,
                      color: ColorUtil.red,
                      text: 'Copy to Calendar',
                      size: GFSize.LARGE,
                      icon: const Icon(Icons.calendar_month,
                          color: Colors.white)),
                ),
                SizedBox(height: 1.w),
                Center(
                  child: GFButton(
                      onPressed: () {
                        SocialShare.copyToClipboard(
                            text:
                                'Event: ${event.event} Date: ${DateFormat.yMMMMd().format(event.date)} Time: ${timeOfDayToString(event.startTime)} to ${timeOfDayToString(event.endTime)} Location: ${event.location} Description: ${event.description}');
                      },
                      color: ColorUtil.red,
                      text: 'Copy Details',
                      size: GFSize.LARGE,
                      icon: const Icon(Icons.copy, color: Colors.white)),
                ),
                SizedBox(height: 1.w),
                Center(
                  child: GFButton(
                      onPressed: () {
                        SocialShare.shareTwitter(
                            'Hey Everyone! I\'m looking forward to the ${event.event} happening at ${event.location} hosted by the Milton School District! It will be happening from ${timeOfDayToString(event.startTime)} to ${timeOfDayToString(event.endTime)}. Hope to see you there!',
                            hashtags: ['milton']);
                      },
                      color: ColorUtil.red,
                      text: 'Share on Twitter',
                      size: GFSize.LARGE,
                      icon: SvgPicture.asset(
                        'assets/twitter-icon.svg',
                        width: 6.w,
                        height: 6.w,
                        colorFilter: const ColorFilter.mode(
                            Colors.white, BlendMode.srcIn),
                      )),
                ),
                if (AuthService().isAdmin())
                  Center(
                    child: Column(
                      children: [
                        SizedBox(height: 1.w),
                        GFButton(
                            onPressed: () => _deleteEvent(context),
                            color: ColorUtil.red,
                            text: 'Delete Event',
                            icon:
                                const Icon(Icons.delete, color: Colors.white)),
                        SizedBox(height: 1.w),
                        GFButton(
                            onPressed: () => GoRouter.of(context)
                                .push(Routes.editEvent.toPath, extra: event),
                            color: ColorUtil.red,
                            text: 'Edit Event',
                            icon: const Icon(Icons.edit, color: Colors.white))
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _exportEvent() => Add2Calendar.addEvent2Cal(Event(
        title: event.event,
        description: event.description,
        location: event.location,
        startDate: DateTime(event.date.year, event.date.month, event.date.day,
            event.startTime.hour, event.startTime.minute),
        endDate: DateTime(event.date.year, event.date.month, event.date.day,
            event.endTime.hour, event.endTime.minute),
      ));

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
