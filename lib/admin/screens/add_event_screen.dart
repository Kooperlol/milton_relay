import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drop_shadow/drop_shadow.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/event.dart';
import 'package:milton_relay/shared/services/event_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:uuid/uuid.dart';

import '../../shared/utils/collections.dart';
import '../../shared/utils/color_util.dart';
import '../../shared/utils/display_util.dart';

class AddEventScreen extends StatefulWidget {
  const AddEventScreen({Key? key}) : super(key: key);

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final TextEditingController _eventInput = TextEditingController(),
      _dateInput = TextEditingController(),
      _timeInput = TextEditingController(),
      _descriptionInput = TextEditingController(),
      _locationInput = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  TimeOfDay _timeOfEvent = TimeOfDay.now();
  DateTime _dateOfEvent = DateTime.now();
  File? _image;

  @override
  void dispose() {
    super.dispose();
    _eventInput.dispose();
    _dateInput.dispose();
    _timeInput.dispose();
    _descriptionInput.dispose();
    _locationInput.dispose();
  }

  void pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final File imageTemp = File(image.path);
    setState(() => _image = imageTemp);
  }

  void createEvent() async {
    if (_eventInput.text.isEmpty ||
        _dateInput.text.isEmpty ||
        _timeInput.text.isEmpty ||
        _descriptionInput.text.isEmpty ||
        _locationInput.text.isEmpty) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    var uuid = const Uuid();
    var id = uuid.v1();

    try {
      TaskSnapshot? uploadTask;
      if (_image != null) {
        Reference storageRef =
            FirebaseStorage.instance.ref().child("events/$id");
        uploadTask = await storageRef.putFile(_image!);
      }

      CollectionReference eventsCollection =
          FirebaseFirestore.instance.collection(Collections.events.toPath);
      EventModel eventModel = EventModel(
          id,
          _eventInput.text,
          _descriptionInput.text,
          _locationInput.text,
          _timeOfEvent,
          _dateOfEvent,
          uploadTask != null
              ? await uploadTask.ref.getDownloadURL()
              : 'default');
      eventsCollection.doc(id).set(EventService().eventToJson(eventModel));
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create an event: ${error.toString()}");
    }

    if (!mounted) return;
    showSnackBar(context, "Created event!");

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: SingleChildScrollView(
          child: Column(children: [
            const SizedBox.square(dimension: 32),
            const Text(
              'Add an Event',
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox.square(dimension: 25),
            Card(
              shadowColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  children: [
                    TextField(
                        controller: _eventInput,
                        decoration: const InputDecoration(
                            icon: Icon(Icons.event_note), labelText: 'Event')),
                    const SizedBox.square(dimension: 25),
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
                    const SizedBox.square(dimension: 25),
                    TextField(
                      controller: _timeInput,
                      readOnly: true,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.access_time_outlined),
                          labelText: 'Time'),
                      onTap: () async {
                        TimeOfDay? time = await showTimePicker(
                            context: context, initialTime: _timeOfEvent);
                        if (time == null) return;
                        setState(() {
                          _timeInput.text =
                              '${time.hourOfPeriod}:${time.minute < 10 ? '0${time.minute}' : time.minute} ${time.period.name.toUpperCase()}';
                          _timeOfEvent = time;
                        });
                      },
                    ),
                    const SizedBox.square(dimension: 25),
                    TextField(
                      maxLines: null,
                      controller: _descriptionInput,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.description),
                          labelText: 'Description'),
                    ),
                    const SizedBox.square(dimension: 25),
                    TextField(
                      keyboardType: TextInputType.streetAddress,
                      controller: _locationInput,
                      decoration: const InputDecoration(
                          icon: Icon(Icons.location_on), labelText: 'Location'),
                    ),
                    const SizedBox.square(dimension: 25),
                    Container(
                        width: 250,
                        height: 100,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              alignment: Alignment.center,
                              image: _image != null
                                  ? Image.file(_image!).image
                                  : Image.asset(
                                          'assets/default-event-banner.png')
                                      .image),
                        )),
                    const SizedBox.square(dimension: 15),
                    DropShadow(
                      blurRadius: 5,
                      opacity: 0.5,
                      child: InkWell(
                        onTap: () => pickImage(),
                        customBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15)),
                        child: Container(
                            width: double.infinity,
                            alignment: Alignment.center,
                            color: Colors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_photo_alternate_rounded,
                                      color: Colors.white),
                                  SizedBox.square(dimension: 5),
                                  Text('Upload Banner',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.white))
                                ])),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            DropShadow(
              blurRadius: 5,
              opacity: 0.5,
              child: InkWell(
                onTap: () => createEvent(),
                customBorder:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                    width: 150,
                    margin:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                    alignment: Alignment.center,
                    color: ColorUtil.red,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: const Text('Add Event',
                        style: TextStyle(fontSize: 20, color: Colors.white))),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
