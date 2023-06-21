import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/components/button/gf_button.dart';
import 'package:go_router/go_router.dart';
import 'package:milton_relay/shared/services/auth_service.dart';
import 'package:milton_relay/shared/widgets/app_bar_widget.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../shared/models/collections.dart';
import '../../shared/utils/color_util.dart';
import '../../shared/utils/display_util.dart';
import '../../shared/utils/text_util.dart';

class LaudePointCalculatorScreen extends StatefulWidget {
  const LaudePointCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LaudePointCalculatorScreen> createState() =>
      _LaudePointCalculatorScreenState();
}

class _LaudePointCalculatorScreenState
    extends State<LaudePointCalculatorScreen> {
  // GPA & Tutoring text field.
  final TextEditingController _gPAController = TextEditingController(),
      _tutoringController = TextEditingController();
  // Stores the multi-selection fields for classes.
  final GroupController _aPCourseController =
          GroupController(isMultipleSelection: true),
      _honorCoursesController = GroupController(isMultipleSelection: true),
      _advancedClassesController = GroupController(isMultipleSelection: true),
      _fourCreditSubjectController = GroupController(isMultipleSelection: true),
      _halfPointClassesController = GroupController(isMultipleSelection: true),
      _activitiesController = GroupController(isMultipleSelection: true),
      _twoPointCoursesController = GroupController(isMultipleSelection: true);
  // List of all AP Courses.
  final List<String> _aPCourseDisplay = const [
        'AP 2-D Art and Design',
        'AP Biology',
        'AP Calculus',
        'AP Chemistry',
        'AP Computer Science A',
        'AP Computer Science Principles',
        'AP English Language and Composition',
        'AP English Literature and Composition',
        'AP Environmental Science',
        'AP French Language and Culture',
        'AP Music Theory',
        'AP Physics I',
        'AP Psychology (AS)',
        'AP Spanish Language and Culture',
        'AP Statistics',
        'AP U.S. Government and Politics',
        'AP U.S. History',
        'AP World History'
      ],
      // List of all honors courses.
      _honorCoursesDisplay = const [
        'Honors English 9',
        'Honors English 10',
        'Honors Geometry',
        'Honors Algebra II',
        'Honors Biology',
        'Honors Earth Science',
        'Honors Chemistry',
        'Honors Physics',
        'Honors French III'
      ],
      // List of all advanced classes.
      _advancedClassesDisplay = const [
        'Advanced Accounting',
        'Early Childhood Education',
        'Careers with Children',
        'Cybersecurity',
        'Precalculus',
        'Principles of Biomedical Science',
        'Human Body Systems',
        'Introduction to Engineering Design',
        'Principles of Engineering',
        'Advanced Spanish Foundations',
      ],
      // List of all subjects you can have 4.0 credits in.
      _fourCreditSubjectsDisplay = const [
        '4.0 Credits of Art',
        '4.0 Credits of Agriculture Science',
        '4.0 Credits of Business',
        '4.0 Credits of Digital Media and Computing',
        '4.0 Credits of Band',
        '4.0 Credits of Choir',
        '4.0 Credits of Technology Education',
        '4.0 Credits of a World Language'
      ],
      // List of classes which are worth half a laude point.
      _halfPointClassesDisplay = const [
        'Advanced Drawing',
        'Advanced Painting',
        'Shop Math I',
        'Shop Math II',
        'Honors Human Geography'
      ],
      // Activities which can count towards laude points.
      _activitiesDisplay = [
        'Youth Apprenticeship Level 2',
        'Early College Credit Program',
        'GSP Qualifier'
      ],
      // Two point courses.
      _twoPointCoursesDisplay = const [
        'Advanced Welding',
        'Constructions Trades II'
      ];
  // List of all selected courses & activities.
  List<String> _aPCourseSelected = [],
      _honorCoursesSelected = [],
      _advancedClassesSelected = [],
      _fourCreditSubjectsSelected = [],
      _halfPointClassesSelected = [],
      _activitiesSelected = [],
      _twoPointCoursesSelected = [];
  // Saves the current step in the stepper widget.
  int _currentStep = 0;

  /// Disposes text field widget.
  @override
  void dispose() {
    super.dispose();
    _gPAController.dispose();
  }

  /// Calculates the student's laude points based on the filled in information.
  void _calculate() async {
    // Makes sure the GPA field is filled out.
    if (_gPAController.text.isEmpty) {
      showSnackBar(context, 'Please enter your GPA.');
      return;
    }
    double points = 0;

    // Adds the length of the lists multiplied by their laude worth.
    points += _aPCourseSelected.length +
        _honorCoursesSelected.length +
        _advancedClassesSelected.length +
        _fourCreditSubjectsSelected.length +
        _activitiesSelected.length +
        (_twoPointCoursesSelected.length * 2);

    // Adds classes worth half a laude point.
    if (_halfPointClassesSelected.isNotEmpty) {
      points += _halfPointClassesSelected.length / 2;
    }

    // If filled in, this will add tutoring laude points.
    if (_tutoringController.text.isNotEmpty &&
        isNumeric(_tutoringController.text)) {
      points += double.parse(_tutoringController.text) * 0.5;
    }

    // Points are multiplied by the student's GPA.
    points *= double.parse(_gPAController.text);
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection(Collections.users.toPath);

    // Laude points of the student are updated in the user's collection.
    await userCollection
        .doc(AuthService().getUID())
        .update({'laudePoints': points});

    // If the screen is still mounted, it will display a success message and pop the screen.
    if (!mounted) return;
    showSnackBar(context, "Calculated Laude Points!");
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ChipGroupStyle groupStyle = ChipGroupStyle(
        itemTitleStyle: TextStyle(fontSize: 1.5.w),
        backgroundColorItem: ColorUtil.darkGray,
        selectedColorItem: ColorUtil.darkRed,
        textColor: Colors.white,
        selectedIcon: Icons.check,
        selectedTextColor: Colors.white);
    return Scaffold(
      appBar: const AppBarWidget(title: 'Laude Point Calculator'),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(1.w),
          child: Column(
            children: [
              Stepper(
                physics: const NeverScrollableScrollPhysics(),
                controlsBuilder: (context, _) {
                  return Row(
                    children: <Widget>[
                      TextButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => ColorUtil.red)),
                        onPressed: () => _currentStep < 8
                            ? setState(() => _currentStep++)
                            : null,
                        child: Text('Next',
                            style:
                                TextStyle(color: Colors.white, fontSize: 2.w)),
                      ),
                      TextButton(
                        onPressed: () => _currentStep > 0
                            ? setState(() => _currentStep--)
                            : null,
                        child: Text('Back', style: TextStyle(fontSize: 2.w)),
                      ),
                    ],
                  );
                },
                currentStep: _currentStep,
                onStepTapped: (index) => setState(() => _currentStep = index),
                steps: [
                  // GPA Input.
                  Step(
                    title: Text('GPA', style: TextStyle(fontSize: 3.w)),
                    isActive: _currentStep == 0,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: TextField(
                        controller: _gPAController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            icon: const Icon(Icons.grade),
                            labelStyle: TextStyle(fontSize: 2.w),
                            labelText: 'Enter your Grade Point Average.'),
                      ),
                    ),
                  ),
                  // AP Course selection.
                  Step(
                    title: Text('AP Courses', style: TextStyle(fontSize: 3.w)),
                    subtitle: _currentStep == 1
                        ? Text('Select the following that you have taken.',
                            style: TextStyle(fontSize: 2.w))
                        : null,
                    isActive: _currentStep == 1,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: SimpleGroupedChips(
                          controller: _aPCourseController,
                          values: _aPCourseDisplay,
                          itemTitle: _aPCourseDisplay,
                          chipGroupStyle: groupStyle,
                          onItemSelected: (list) => _aPCourseSelected = list),
                    ),
                  ),
                  // Honors course selection.
                  Step(
                    title:
                        Text('Honors Courses', style: TextStyle(fontSize: 3.w)),
                    subtitle: _currentStep == 2
                        ? Text('Select the following that you have taken.',
                            style: TextStyle(fontSize: 2.w))
                        : null,
                    isActive: _currentStep == 2,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: SimpleGroupedChips(
                          controller: _honorCoursesController,
                          values: _honorCoursesDisplay,
                          itemTitle: _honorCoursesDisplay,
                          chipGroupStyle: groupStyle,
                          onItemSelected: (list) =>
                              _honorCoursesSelected = list),
                    ),
                  ),
                  // Advanced class selection.
                  Step(
                    title: Text('Advanced Classes',
                        style: TextStyle(fontSize: 3.w)),
                    subtitle: _currentStep == 3
                        ? Text('Select the following that you have taken.',
                            style: TextStyle(fontSize: 2.w))
                        : null,
                    isActive: _currentStep == 3,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: SimpleGroupedChips(
                          controller: _advancedClassesController,
                          values: _advancedClassesDisplay,
                          itemTitle: _advancedClassesDisplay,
                          chipGroupStyle: groupStyle,
                          onItemSelected: (list) =>
                              _advancedClassesSelected = list),
                    ),
                  ),
                  // 4.0 Credits of a Subject selection.
                  Step(
                    title: Text('4 Credits of a Subject',
                        style: TextStyle(fontSize: 3.w)),
                    subtitle: _currentStep == 4
                        ? Text(
                            'Select the subjects which you have four credits of.',
                            style: TextStyle(fontSize: 2.w))
                        : null,
                    isActive: _currentStep == 4,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: SimpleGroupedChips(
                          controller: _fourCreditSubjectController,
                          values: _fourCreditSubjectsDisplay,
                          itemTitle: _fourCreditSubjectsDisplay,
                          chipGroupStyle: groupStyle,
                          onItemSelected: (list) =>
                              _fourCreditSubjectsSelected = list),
                    ),
                  ),
                  // Half point classes selection.
                  Step(
                    title: Text('One Trimester Classes',
                        style: TextStyle(fontSize: 3.w)),
                    subtitle: _currentStep == 5
                        ? Text('Select the following that you have taken.',
                            style: TextStyle(fontSize: 2.w))
                        : null,
                    isActive: _currentStep == 5,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: SimpleGroupedChips(
                          controller: _halfPointClassesController,
                          values: _halfPointClassesDisplay,
                          itemTitle: _halfPointClassesDisplay,
                          chipGroupStyle: groupStyle,
                          onItemSelected: (list) =>
                              _halfPointClassesSelected = list),
                    ),
                  ),
                  // Activites selection.
                  Step(
                    title: Text('Activities', style: TextStyle(fontSize: 3.w)),
                    subtitle: _currentStep == 6
                        ? Text('Select the following that you have taken.',
                            style: TextStyle(fontSize: 2.w))
                        : null,
                    isActive: _currentStep == 6,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: SimpleGroupedChips(
                          controller: _activitiesController,
                          values: _activitiesDisplay,
                          chipGroupStyle: groupStyle,
                          itemTitle: _activitiesDisplay,
                          onItemSelected: (list) => _activitiesSelected = list),
                    ),
                  ),
                  // Multiple-hour course (2 point) selection.
                  Step(
                    title: Text('Multiple-Hour Courses',
                        style: TextStyle(fontSize: 3.w)),
                    subtitle: _currentStep == 7
                        ? Text('Select the following that you have taken.',
                            style: TextStyle(fontSize: 2.w))
                        : null,
                    isActive: _currentStep == 7,
                    content: Padding(
                      padding: EdgeInsets.all(2.w),
                      child: SimpleGroupedChips(
                          controller: _twoPointCoursesController,
                          values: _twoPointCoursesDisplay,
                          chipGroupStyle: groupStyle,
                          itemTitle: _twoPointCoursesDisplay,
                          onItemSelected: (list) =>
                              _twoPointCoursesSelected = list),
                    ),
                  ),
                  // Tutoring input.
                  Step(
                    title: Text('Tutoring', style: TextStyle(fontSize: 3.w)),
                    isActive: _currentStep == 8,
                    content: Padding(
                      padding: EdgeInsets.all(1.5.w),
                      child: Padding(
                        padding: EdgeInsets.all(1.w),
                        child: TextField(
                          controller: _tutoringController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                              icon: const Icon(Icons.assistant),
                              labelStyle: TextStyle(fontSize: 2.w),
                              labelText:
                                  'Enter the number of trimesters which you have tutored.'),
                        ),
                      ),
                    ),
                  )
                ],
              ),
              SizedBox(height: 1.w),
              // Button which when pressed will calculate the number of laude points by calling [_calculate].
              GFButton(
                  onPressed: _calculate,
                  text: 'Calculate',
                  size: 7.w,
                  textStyle: TextStyle(fontSize: 4.w),
                  icon: Icon(Icons.calculate, color: Colors.white, size: 5.w),
                  color: ColorUtil.red),
            ],
          ),
        ),
      ),
    );
  }
}
