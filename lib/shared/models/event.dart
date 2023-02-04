import 'package:flutter/material.dart';

class EventModel {
  final String id, event, description, location, bannerURL;
  final TimeOfDay time;
  final DateTime date;

  EventModel(this.id, this.event, this.description, this.location, this.time,
      this.date, this.bannerURL);
}
