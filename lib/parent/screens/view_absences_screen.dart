import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/student/models/absence_model.dart';
import 'package:milton_relay/student/models/student_model.dart';
import 'package:milton_relay/student/services/absence_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/utils/color_util.dart';
import '../../shared/utils/text_util.dart';
import '../../shared/widgets/app_bar_widget.dart';

/// Views the absence of [student]
class ViewAbsencesScreen extends StatefulWidget {
  final StudentModel student;
  const ViewAbsencesScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<ViewAbsencesScreen> createState() => _ViewAbsencesScreenState();
}

class _ViewAbsencesScreenState extends State<ViewAbsencesScreen> {
  // Stores the absence widgets.
  final List<Widget> _data = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Absences'),
      body: ListView.builder(
          itemBuilder: (context, index) {
            if (widget.student.absences.isEmpty) {
              return Center(
                  child: Text('No Absences', style: TextStyle(fontSize: 3.w)));
            }
            if (_data.isEmpty) {
              return SizedBox(
                width: double.infinity,
                height: 10.w,
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return _data[index];
          },
          itemCount: _data.isEmpty ? 1 : _data.length),
    );
  }

  /// Gets the absences of [widget.student] from the absence database and sets it to [_data].
  void _initData() async {
    List<Widget> absences = [];
    // Copies the user's current absences and sorts them based on date in descending order.
    List<AbsenceModel> sortedAbsences =
        await AbsenceService().getAbsencesFromIDs(widget.student.absences);
    sortedAbsences.sort((a, b) => b.date.compareTo(a.date));
    // Traverses through the sorted absences and creates a card for each.
    for (AbsenceModel absence in sortedAbsences) {
      absences.add(Card(
          color: ColorUtil.snowWhite,
          shadowColor: Colors.black,
          elevation: 2,
          margin: EdgeInsets.all(1.w),
          child: Padding(
            padding: EdgeInsets.all(2.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Displays date.
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
                      text: DateFormat.yMMMMd().format(absence.date),
                      style: TextStyle(fontSize: 5.w, color: Colors.black))
                ])),
                SizedBox(height: 1.w),
                // Displays time.
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
                          '${timeOfDayToString(absence.startTime)} to ${timeOfDayToString(absence.endTime)}',
                      style: TextStyle(fontSize: 5.w, color: Colors.black))
                ])),
                SizedBox(height: 1.w),
                // Displays reason.
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Reason: ',
                      style: TextStyle(fontSize: 5.w, color: ColorUtil.blue)),
                  WidgetSpan(
                      child: Padding(
                    padding: EdgeInsets.only(right: 1.w),
                    child: Icon(Icons.message, size: 5.w),
                  )),
                  TextSpan(
                      text: absence.reason.toName.capitalize(),
                      style: TextStyle(fontSize: 5.w, color: Colors.black))
                ]))
              ],
            ),
          )));
    }
    // Sets the [_data] to the list of absences as widgets.
    setState(() => _data.addAll(absences));
  }
}
