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

class ReportAbsenceScreen extends StatefulWidget {
  final StudentModel student;
  const ReportAbsenceScreen({Key? key, required this.student})
      : super(key: key);

  @override
  State<ReportAbsenceScreen> createState() => _ReportAbsenceScreenState();
}

class _ReportAbsenceScreenState extends State<ReportAbsenceScreen> {
  final TextEditingController _dateInput = TextEditingController(),
      _startTimeInput = TextEditingController(),
      _endTimeInput = TextEditingController();
  DateTime _date = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now(), _endTime = TimeOfDay.now();
  String _reason = AbsenceReasons.other.toName;

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Reason:',
                              style: TextStyle(fontSize: 2.5.w),
                            ),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: DropdownButtonHideUnderline(
                                child: GFDropdown(
                                    dropdownButtonColor: ColorUtil.snowWhite,
                                    dropdownColor: ColorUtil.snowWhite,
                                    padding: EdgeInsets.all(1.5.w),
                                    itemHeight: 6.w,
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
              GFButton(
                  onPressed: () => _addAbsence(widget.student),
                  text: 'Submit',
                  icon: const Icon(Icons.add, color: Colors.white),
                  color: ColorUtil.red)
            ],
          ),
        ),
      ),
    );
  }

  void _addAbsence(StudentModel student) async {
    if (_dateInput.text.isEmpty ||
        _startTimeInput.text.isEmpty ||
        _endTimeInput.text.isEmpty) {
      showSnackBar(context, "Please fill out all fields!");
      return;
    }

    CollectionReference userCollection =
            FirebaseFirestore.instance.collection(Collections.users.toPath),
        absenceCollection =
            FirebaseFirestore.instance.collection(Collections.absences.toPath);

    DocumentReference doc = absenceCollection.doc();

    AbsenceModel absenceModel = AbsenceModel(doc.id, student.id, DateTime.now(),
        _startTime, _endTime, absenceReasonFromString(_reason));

    try {
      doc.set(AbsenceService().absenceToJson(absenceModel));
      student.absences.add(doc.id);
      await userCollection
          .doc(student.id)
          .update(StudentService().studentToJson(student));
    } catch (error) {
      stderr.writeln(
          "An error has occurred while attempting to create an absence: ${error.toString()}");
    }

    if (!mounted) return;
    showSnackBar(context, "Absence submitted!");

    context.pop();
  }
}
