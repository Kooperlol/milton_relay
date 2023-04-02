import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/getwidget.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/event_model.dart';
import 'package:milton_relay/shared/services/event_service.dart';
import 'package:milton_relay/shared/utils/text_util.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/collections.dart';
import '../../shared/utils/color_util.dart';
import '../../shared/utils/display_util.dart';

class EventManagerScreen extends StatefulWidget {
  // Stores an EventModel if the user is editing an event.
  final EventModel? event;
  const EventManagerScreen({Key? key, this.event}) : super(key: key);

  @override
  State<EventManagerScreen> createState() => _EventManagerScreenState();
}

class _EventManagerScreenState extends State<EventManagerScreen> {
  // Text fields to store event information.
  final TextEditingController _eventInput = TextEditingController(),
      _dateInput = TextEditingController(),
      _startTimeInput = TextEditingController(),
      _endTimeInput = TextEditingController(),
      _descriptionInput = TextEditingController(),
      _locationInput = TextEditingController();
  // Start and end time of the event using TimeOfDay.
  TimeOfDay _startTimeOfEvent = TimeOfDay.now(),
      _endTimeOfEvent = TimeOfDay.now();
  // The date of the event which is now by default.
  DateTime _dateOfEvent = DateTime.now();
  // The banner of the event.
  File? _banner;

  @override
  void initState() {
    super.initState();
    // If an event is being edited, the variables above will be set to match [widget.event].
    if (widget.event != null) {
      _eventInput.text = widget.event!.event;
      _dateInput.text = DateFormat('MM-dd-yy').format(widget.event!.date);
      _dateOfEvent = widget.event!.date;
      _startTimeOfEvent = widget.event!.startTime;
      _startTimeInput.text = timeOfDayToString(widget.event!.startTime);
      _endTimeOfEvent = widget.event!.endTime;
      _endTimeInput.text = timeOfDayToString(widget.event!.endTime);
      _descriptionInput.text = widget.event!.description;
      _locationInput.text = widget.event!.location;
    }
  }

  /// Disposes text field widgets.
  @override
  void dispose() {
    super.dispose();
    _eventInput.dispose();
    _dateInput.dispose();
    _startTimeInput.dispose();
    _endTimeInput.dispose();
    _descriptionInput.dispose();
    _locationInput.dispose();
  }

  /// Creates an event based on the input fields.
  void _createEvent() async {
    // Checks to make sure that all fields have been filled out.
    if (_eventInput.text.isEmpty ||
        _dateInput.text.isEmpty ||
        _startTimeInput.text.isEmpty ||
        _endTimeInput.text.isEmpty ||
        _descriptionInput.text.isEmpty ||
        _locationInput.text.isEmpty) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    // Displays a message if the description is greater than 250 characters.
    if (_descriptionInput.text.characters.length > 250) {
      showSnackBar(
          context, "The description can't be greater than 250 characters!");
      return;
    }

    // If new, it generates a UUID for the event, otherwise it uses the UUID of the event being edited.
    var uuid = const Uuid();
    var id = widget.event != null ? widget.event!.id : uuid.v1();

    try {
      // Delete the current banner from Firestore if the user is editing an event and a banner is uploaded.
      if (widget.event != null && _banner != null) {
        Reference storageRef =
            FirebaseStorage.instance.ref().child("events/$id");
        storageRef.delete();
      }

      // If [_banner] is specified, it uploads the banner to Firestore.
      TaskSnapshot? uploadTask;
      if (_banner != null) {
        Reference storageRef =
            FirebaseStorage.instance.ref().child("events/$id");
        uploadTask = await storageRef.putFile(_banner!);
      }

      // Creates event model from data and stores it in the Event's collection.
      CollectionReference eventsCollection =
          FirebaseFirestore.instance.collection(Collections.events.toPath);
      EventModel eventModel = EventModel(
          id,
          _eventInput.text,
          _descriptionInput.text,
          _locationInput.text,
          _startTimeOfEvent,
          _endTimeOfEvent,
          _dateOfEvent.add(_dateOfEvent.timeZoneOffset),
          uploadTask != null
              ? await uploadTask.ref.getDownloadURL()
              : widget.event != null
                  ? widget.event!.bannerURL
                  : 'default');
      await eventsCollection
          .doc(id)
          .set(EventService().eventToJson(eventModel));
    } catch (error) {
      stderr.writeln(
          'An error has occurred while attempting to create an event: ${error.toString()}');
    }

    // If the screen is still mounted, the screen is popped and a success message is displayed.
    if (!mounted) return;
    showSnackBar(
        context, widget.event != null ? 'Edited Event' : 'Created event!');

    if (widget.event != null) {
      context.pop();
      context.pop();
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(
          title: widget.event != null ? 'Edit Event' : 'Add Event'),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
        child: SingleChildScrollView(
          child: Column(children: [
            Card(
              color: ColorUtil.snowWhite,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    // Event name input.
                    TextField(
                        controller: _eventInput,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.event_note), labelText: 'Event')),
                    SizedBox(height: 5.w),
                    // Date input.
                    TextField(
                      controller: _dateInput,
                      readOnly: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.calendar_today), labelText: 'Date'),
                      onTap: () async {
                        DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: _dateOfEvent,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100));
                        if (date == null) return;
                        setState(() {
                          _dateInput.text = DateFormat('MM-dd-yy').format(date);
                          _dateOfEvent = date;
                        });
                      },
                    ),
                    SizedBox(height: 5.w),
                    // Start time input.
                    TextField(
                      controller: _startTimeInput,
                      readOnly: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.access_time_outlined),
                          labelText: 'Start Time'),
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                            context: context, initialTime: _startTimeOfEvent);
                        if (time == null) return;
                        setState(() {
                          _startTimeInput.text = timeOfDayToString(time);
                          _startTimeOfEvent = time;
                        });
                      },
                    ),
                    SizedBox(height: 5.w),
                    // End time input.
                    TextField(
                      controller: _endTimeInput,
                      readOnly: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.access_time_outlined),
                          labelText: 'End Time'),
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                            context: context, initialTime: _endTimeOfEvent);
                        if (time == null) return;
                        setState(() {
                          _endTimeInput.text = timeOfDayToString(time);
                          _endTimeOfEvent = time;
                        });
                      },
                    ),
                    SizedBox.square(dimension: 5.w),
                    // Description Input
                    TextField(
                      maxLines: null,
                      controller: _descriptionInput,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.description),
                          labelText: 'Description'),
                    ),
                    SizedBox(height: 5.w),
                    // Address Input.
                    TextField(
                      keyboardType: TextInputType.streetAddress,
                      controller: _locationInput,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.location_on), labelText: 'Location'),
                    ),
                    SizedBox(height: 5.w),
                    // Shows the current banner or the default banner. On tap, it opens an image selector.
                    GestureDetector(
                      onTap: () async {
                        File? image = await pickImage();
                        setState(() => _banner = image);
                      },
                      child: Container(
                          width: 250,
                          height: 100,
                          alignment: Alignment.bottomCenter,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                image: _banner != null
                                    ? Image.file(_banner!).image
                                    : widget.event != null
                                        ? Image.network(widget.event!.bannerURL)
                                            .image
                                        : Image.asset(
                                                'assets/default-event-banner.png')
                                            .image),
                          ),
                          child: Container(
                            color: const Color.fromRGBO(255, 255, 255, 0.8),
                            height: 6.w,
                            alignment: Alignment.center,
                            width: double.infinity,
                            child: Text('Tap to Replace Image',
                                style: TextStyle(fontSize: 4.w)),
                          )),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(height: 5.w),
            // On tap, this calls the [_createEvent] function.
            GFButton(
                onPressed: _createEvent,
                text: widget.event != null ? 'Edit Event' : 'Add Event',
                icon: const Icon(Icons.add, color: Colors.white),
                color: ColorUtil.red)
          ]),
        ),
      ),
    );
  }
}
