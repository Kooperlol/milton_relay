import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:getwidget/components/dropdown/gf_dropdown.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:milton_relay/student/models/absence_model.dart';
import 'package:milton_relay/student/models/student_model.dart';
import 'package:milton_relay/student/services/absence_service.dart';
import 'package:milton_relay/student/services/student_service.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/models/collections.dart';
import '../../shared/utils/color_util.dart';
import '../../shared/utils/display_util.dart';
import '../../shared/utils/text_util.dart';

/// Creates a form to report an absence for [student].
class ReportAbsenceScreen extends StatefulWidget {
  final StudentModel student;
  const ReportAbsenceScreen({Key? key, required this.student})
      : super(key: key);

  @override
  State<ReportAbsenceScreen> createState() => _ReportAbsenceScreenState();
}

class _ReportAbsenceScreenState extends State<ReportAbsenceScreen> {
  // Text field widgets for absence information.
  final TextEditingController _dateInput = TextEditingController(),
      _startTimeInput = TextEditingController(),
      _endTimeInput = TextEditingController();
  // Date of absence, which is now by default.
  DateTime _date = DateTime.now();
  // Time of day, which is the current time by default.
  TimeOfDay _startTime = TimeOfDay.now(), _endTime = TimeOfDay.now();
  // Reason for absence from [AbsenceReason] enum. Other by default.
  String _reason = AbsenceReasons.other.toName;

  /// Disposes text field widgets.
  @override
  void dispose() {
    super.dispose();
    _dateInput.dispose();
    _startTimeInput.dispose();
    _endTimeInput.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWidget(title: 'Report Absence'),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 3.h, horizontal: 5.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Card(
                  color: ColorUtil.snowWhite,
                  child: Padding(
                    padding: EdgeInsets.all(3.w),
                    child: Column(
                      children: [
                        // Creates dropdown of [AbsenceReasons] that can be selected.
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Reason:',
                              style: TextStyle(fontSize: 3.w),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: GFDropdown(
                                    dropdownButtonColor: ColorUtil.snowWhite,
                                    dropdownColor: ColorUtil.snowWhite,
                                    padding: EdgeInsets.all(1.5.w),
                                    itemHeight: 10.w,
                                    borderRadius: BorderRadius.circular(2.w),
                                    border: BorderSide(
                                        color: Colors.black12, width: 0.1.w),
                                    value: _reason,
                                    icon: const Icon(Icons.arrow_drop_down,
                                        color: Colors.black),
                                    items: AbsenceReasons.values
                                        .map((e) => DropdownMenuItem<dynamic>(
                                              value: e.toName,
                                              child:
                                                  Text(e.toName.capitalize()),
                                            ))
                                        .toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => _reason = value);
                                    }),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.w),
                        // Date input for absence.
                        TextField(
                          controller: _dateInput,
                          readOnly: true,
                          decoration: const InputDecoration(
                              icon: Icon(Icons.calendar_today),
                              labelText: 'Date'),
                          onTap: () async {
                            DateTime? date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(2021),
                                lastDate: DateTime(2100),
                                initialDate: _date);
                            if (date == null) return;
                            setState(() {
                              _dateInput.text =
                                  DateFormat('MM-dd-yy').format(date);
                              _date = date;
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
                                context: context, initialTime: _startTime);
                            if (time == null) return;
                            setState(() {
                              _startTimeInput.text = timeOfDayToString(time);
                              _startTime = time;
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
                                context: context, initialTime: _endTime);
                            if (time == null) return;
                            setState(() {
                              _endTimeInput.text = timeOfDayToString(time);
                              _endTime = time;
                            });
                          },
                        ),
                        SizedBox(height: 5.w),
                        // Option to set [_startTime] and [_endTime] to all day (7:35 AM to 2:55 PM).
                        GFButton(
                            onPressed: () => setState(() {
                                  _startTimeInput.text = '7:35 AM';
                                  _startTime =
                                      const TimeOfDay(hour: 7, minute: 35);
                                  _endTimeInput.text = '2:55 PM';
                                  _endTime =
                                      const TimeOfDay(hour: 14, minute: 55);
                                }),
                            text: 'All Day',
                            icon: const Icon(Icons.access_time_filled,
                                color: Colors.white),
                            color: ColorUtil.red)
                      ],
                    ),
                  )),
              SizedBox(height: 5.w),
              // Submit absence report, which calls [_addAbsence].
              GFButton(
                  onPressed: () => _addAbsence,
                  text: 'Submit',
                  icon: const Icon(Icons.add, color: Colors.white),
                  color: ColorUtil.red)
            ],
          ),
        ),
      ),
    );
  }

  /// Adds an absence to the [widget.student]'s data.
  void _addAbsence() async {
    // Checks to make sure that all input fields are filled out.
    if (_dateInput.text.isEmpty ||
        _startTimeInput.text.isEmpty ||
        _endTimeInput.text.isEmpty) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    // Gets an instance of the users and absences collection.
    CollectionReference userCollection =
            FirebaseFirestore.instance.collection(Collections.users.toPath),
        absenceCollection =
            FirebaseFirestore.instance.collection(Collections.absences.toPath);

    // Creates a document reference in the [absenceCollection].
    DocumentReference doc = absenceCollection.doc();

    // Creates an absence model from the input data.
    AbsenceModel absenceModel = AbsenceModel(doc.id, widget.student.id,
        DateTime.now(), _startTime, _endTime, absenceReasonFromString(_reason));

    // Attempts to save the absence to the user's absences and the absence model to the absence collection.
    try {
      doc.set(AbsenceService().absenceToJson(absenceModel));
      widget.student.absences.add(doc.id);
      await userCollection
          .doc(widget.student.id)
          .update(StudentService().studentToJson(widget.student));
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create an absence: ${error.toString()}");
    }

    // If the screen is still mounted, it will display a success message and pop the screen.
    if (!mounted) return;
    showSnackBar(context, "Absence submitted!");

    context.pop();
  }
}
