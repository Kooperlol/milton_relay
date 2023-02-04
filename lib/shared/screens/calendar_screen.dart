import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:table_calendar/table_calendar.dart';

import '../routing/routes.dart';
import '../utils/color_util.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AuthService().isAdmin()
          ? getAppBarWithIconRight(IconButton(
              onPressed: () => context.push(Routes.addEventScreen.toPath),
              icon: const Icon(Icons.add_box, size: 45, color: Colors.white)))
          : getAppBar(),
      body: TableCalendar(
        focusedDay: _focusedDay,
        calendarStyle: CalendarStyle(
            todayDecoration:
                BoxDecoration(color: ColorUtil.red, shape: BoxShape.circle)),
        firstDay: DateTime.utc(2010),
        lastDay: DateTime.utc(2030),
        calendarFormat: _calendarFormat,
        onDaySelected: (selectedDay, focusedDay) =>
            setState(() => _focusedDay = selectedDay),
        onFormatChanged: (format) => setState(() => _calendarFormat = format),
      ),
    );
  }
}
