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
  final List<Widget> _display = [];
  bool _loading = false;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _setAbsencesOnDate();
  }

  @override
  Widget build(BuildContext context) {
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

  Future<void> _setAbsencesOnDate() async {
    setState(() => _loading = true);
    List<Widget> absenceCards = [];
    await FirebaseFirestore.instance
        .collection(Collections.absences.toPath)
        .where('date', isEqualTo: _date.toUtc().microsecondsSinceEpoch)
        .get()
        .then((value) async {
      for (var doc in value.docs) {
        AbsenceModel absence =
            AbsenceService().getAbsenceFromJson(doc.id, doc.data());
        UserModel user = await UserService().getUserFromID(absence.student);
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
                    CircleAvatar(
                      radius: 10.w,
                      backgroundColor: ColorUtil.red,
                      backgroundImage: user.avatar.image,
                    ),
                    SizedBox.square(dimension: 2.w),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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

    if (!mounted) return;
    setState(() {
      _display.clear();
      _display.addAll(absenceCards);
      _loading = false;
    });
  }
}
