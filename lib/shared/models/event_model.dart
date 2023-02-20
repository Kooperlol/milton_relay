import 'package:flutter/material.dart';

class EventModel {
  final String id, event, description, location, bannerURL;
  final TimeOfDay startTime, endTime;
  final DateTime date;

  EventModel(this.id, this.event, this.description, this.location,
      this.startTime, this.endTime, this.date, this.bannerURL);
}
