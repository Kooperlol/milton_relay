import 'package:flutter/material.dart';
import 'package:milton_relay/shared/models/event.dart';

class EventService {
  EventModel getEventFromJson(Map<String, dynamic> json) => EventModel(
      json['id'] as String,
      json['event'] as String,
      json['description'] as String,
      json['location'] as String,
      TimeOfDay(
          hour: json['time-hour'] as int, minute: json['time-minute'] as int),
      DateTime.fromMicrosecondsSinceEpoch(json['date'] as int),
      json['banner-URL'] as String);

  Map<String, dynamic> eventToJson(EventModel event) => <String, dynamic>{
        'id': event.id,
        'event': event.event,
        'description': event.description,
        'location': event.location,
        'time-hour': event.time.hour,
        'time-minute': event.time.minute,
        'date': event.date.microsecondsSinceEpoch,
        'banner-URL': event.bannerURL
      };
}
