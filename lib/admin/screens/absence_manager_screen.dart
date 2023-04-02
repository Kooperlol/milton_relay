import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/models/user_model.dart';
import 'package:milton_relay/shared/services/user_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/student/models/absence_model.dart';
import 'package:milton_relay/student/services/absence_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/models/collections.dart';
import '../../shared/utils/color_util.dart';
import '../../shared/utils/text_util.dart';

class AbsenceManagerScreen extends StatefulWidget {
  const AbsenceManagerScreen({Key? key}) : super(key: key);

  @override
  State<AbsenceManagerScreen> createState() => _AbsenceManagerScreenState();
}

class _AbsenceManagerScreenState extends State<AbsenceManagerScreen> {
  /// Stores the content to display in the listview.
  final List<Widget> _display = [];

  /// Whether the absence content is currently being fetched.
  bool _loading = false;

  /// The date to query for absences.
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Fetch the initial data.
    _setAbsencesOnDate();
  }

  @override
  Widget build(BuildContext context) {
    /// Displays a date picker.
    ///
    /// Will return if the input [date] is null. Otherwise, it will update [_display].
    /// Ranges from September of 2022 to June of 2050.
    IconButton selectDateButton = IconButton(
        icon: const Icon(Icons.calendar_month, color: Colors.white),
        tooltip: 'Select Date',
        onPressed: () async {
          DateTime? date = await showDatePicker(
              context: context,
              initialDate: _date,
              firstDate: DateTime(2022, 9),
              lastDate: DateTime(2050, 6));
          if (date == null) return;
          _date = date;
          _setAbsencesOnDate();
        });
    return Scaffold(
        appBar:
            AppBarWidget(title: 'Absence Manager', icons: [selectDateButton]),
        body: Column(
          children: [
            Text('Absences on ${DateFormat.yMMMd().format(_date)}',
                style: TextStyle(fontSize: 6.w)),
            SizedBox(height: 1.w),

            /// Shows [_display] in a listview to the user.
            ///
            /// If [_display] is populated, it will return the widget at [index].
            /// If [loading] is true, then a progress circle will display.
            /// If [_display] is empty, a text widget will be returned.
            Expanded(
              child: ListView.builder(
                itemBuilder: (context, index) {
                  if (_loading) {
                    return SizedBox(
                      width: double.infinity,
                      height: 10.w,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (_display.isEmpty) {
                    return Center(
                        child: Text('No Absences',
                            style: TextStyle(fontSize: 3.w)));
                  }
                  return _display[index];
                },
                itemCount: _display.isEmpty ? 1 : _display.length,
              ),
            ),
          ],
        ));
  }

  /// Populates the [_display] list to absence cards on [_date].
  Future<void> _setAbsencesOnDate() async {
    setState(() => _loading = true);
    List<Widget> absenceCards = [];
    // Query for absences where the field 'date' is equal to [_date] in epoch time.
    await FirebaseFirestore.instance
        .collection(Collections.absences.toPath)
        .where('date', isEqualTo: _date.toUtc().microsecondsSinceEpoch)
        .get()
        .then((value) async {
      // Traverses through the documents [each absence] found from the query.
      for (var doc in value.docs) {
        // Converts the absence from JSON to a Dart model.
        AbsenceModel absence =
            AbsenceService().getAbsenceFromJson(doc.id, doc.data());
        // Gets the User Model from the ID of the Student.
        UserModel user = await UserService().getUserFromID(absence.student);
        // Adds a card which will display information about the absence.
        absenceCards.add(Card(
            color: ColorUtil.snowWhite,
            shadowColor: Colors.black,
            elevation: 2,
            margin: EdgeInsets.all(1.w),
            child: Padding(
              padding: EdgeInsets.all(0.5.w),
              child: Padding(
                padding: EdgeInsets.all(2.w),
                child: Row(
                  children: [
                    // User's avatar from [user] displayed in a circle.
                    CircleAvatar(
                      radius: 10.w,
                      backgroundColor: ColorUtil.red,
                      backgroundImage: user.avatar.image,
                    ),
                    SizedBox.square(dimension: 2.w),
                    // Display information in a column.
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Student's name.
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: 'Student: ',
                              style: TextStyle(
                                  fontSize: 5.w, color: ColorUtil.blue)),
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Icon(Icons.person, size: 5.w),
                          )),
                          TextSpan(
                              text: user.fullName,
                              style:
                                  TextStyle(fontSize: 5.w, color: Colors.black))
                        ])),
                        SizedBox(height: 1.w),
                        // Time of absence which uses the function [timeOfDayToString()] to convert it to a readable string.
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: 'Time: ',
                              style: TextStyle(
                                  fontSize: 5.w, color: ColorUtil.blue)),
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Icon(Icons.access_time, size: 5.w),
                          )),
                          TextSpan(
                              text:
                                  '${timeOfDayToString(absence.startTime)} to ${timeOfDayToString(absence.endTime)}',
                              style:
                                  TextStyle(fontSize: 5.w, color: Colors.black))
                        ])),
                        SizedBox(height: 1.w),
                        // Reason for absence. Reasons are from the [AbsenceReasons] enum.
                        RichText(
                            text: TextSpan(children: [
                          TextSpan(
                              text: 'Reason: ',
                              style: TextStyle(
                                  fontSize: 5.w, color: ColorUtil.blue)),
                          WidgetSpan(
                              child: Padding(
                            padding: EdgeInsets.only(right: 1.w),
                            child: Icon(Icons.message, size: 5.w),
                          )),
                          TextSpan(
                              text: absence.reason.toName.capitalize(),
                              style:
                                  TextStyle(fontSize: 5.w, color: Colors.black))
                        ])),
                      ],
                    ),
                  ],
                ),
              ),
            )));
      }
    });

    // Since async, make sure the content is still mounted.
    if (!mounted) return;
    // Sets [_display] to the new list, [absenceCards].
    setState(() {
      _display.clear();
      _display.addAll(absenceCards);
      _loading = false;
    });
  }
}
