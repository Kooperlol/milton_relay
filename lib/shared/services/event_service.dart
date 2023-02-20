import 'package:flutter/material.dart';
import 'package:milton_relay/shared/models/event_model.dart';

class EventService {
  EventModel getEventFromJson(Map<String, dynamic> json) => EventModel(
      json['id'] as String,
      json['event'] as String,
      json['description'] as String,
      json['location'] as String,
      TimeOfDay(
          hour: json['start-time-hour'] as int,
          minute: json['start-time-minute'] as int),
      TimeOfDay(
          hour: json['end-time-hour'] as int,
          minute: json['end-time-minute'] as int),
      DateTime.fromMicrosecondsSinceEpoch(json['date'] as int),
      json['banner-URL'] as String);

  Map<String, dynamic> eventToJson(EventModel event) => <String, dynamic>{
        'id': event.id,
        'event': event.event,
        'description': event.description,
        'location': event.location,
        'start-time-hour': event.startTime.hour,
        'start-time-minute': event.startTime.minute,
        'end-time-hour': event.endTime.hour,
        'end-time-minute': event.endTime.minute,
        'date': event.date.microsecondsSinceEpoch,
        'banner-URL': event.bannerURL
      };
}
