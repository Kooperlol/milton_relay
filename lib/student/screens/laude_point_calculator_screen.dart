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

class LaudePointCalculatorScreen extends StatefulWidget {
  const LaudePointCalculatorScreen({Key? key}) : super(key: key);

  @override
  State<LaudePointCalculatorScreen> createState() =>
      _LaudePointCalculatorScreenState();
}

class _LaudePointCalculatorScreenState
    extends State<LaudePointCalculatorScreen> {
  final TextEditingController _GPAController = TextEditingController(),
      _tutoringController = TextEditingController();
  final GroupController _APCourseController =
          GroupController(isMultipleSelection: true),
      _honorCoursesController = GroupController(isMultipleSelection: true),
      _advancedClassesController = GroupController(isMultipleSelection: true),
      _fourCreditSubjectController = GroupController(isMultipleSelection: true),
      _halfPointClassesController = GroupController(isMultipleSelection: true),
      _activitiesController = GroupController(isMultipleSelection: true),
      _twoPointCoursesController = GroupController(isMultipleSelection: true);
  final List<String> _APCourseDisplay = const [
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
      _halfPointClassesDisplay = const [
        'Advanced Drawing',
        'Advanced Painting',
        'Shop Math I',
        'Shop Math II',
        'Honors Human Geography'
      ],
      _activitiesDisplay = [
        'Youth Apprenticeship Level 2',
        'Early College Credit Program',
        'GSP Qualifier'
      ],
      _twoPointCoursesDisplay = const [
        'Advanced Welding',
        'Constructions Trades II'
      ];
  List<String> _APCourseSelected = [],
      _honorCoursesSelected = [],
      _advancedClassesSelected = [],
      _fourCreditSubjectsSelected = [],
      _halfPointClassesSelected = [],
      _activitiesSelected = [],
      _twoPointCoursesSelected = [];
  int _currentStep = 0;

  @override
  void dispose() {
    super.dispose();
    _GPAController.dispose();
  }

  void _calculate() async {
    if (_GPAController.text.isEmpty) {
      showSnackBar(context, 'Please enter your GPA.');
      return;
    }
    double points = 0;
    points += _APCourseSelected.length +
        _honorCoursesSelected.length +
        _advancedClassesSelected.length +
        _fourCreditSubjectsSelected.length +
        _activitiesSelected.length +
        (_twoPointCoursesSelected.length * 2);
    if (_halfPointClassesSelected.isNotEmpty) {
      points += _halfPointClassesSelected.length / 2;
    }
    if (_tutoringController.text.isNotEmpty) {
      points += double.parse(_tutoringController.text) * 0.5;
    }
    points *= double.parse(_GPAController.text);
    CollectionReference userCollection =
        FirebaseFirestore.instance.collection(Collections.users.toPath);
    await userCollection
        .doc(AuthService().getUID())
        .update({'laudePoints': points});
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
      body: Padding(
        padding: EdgeInsets.all(1.w),
        child: Column(
          children: [
            Stepper(
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
                          style: TextStyle(color: Colors.white, fontSize: 2.w)),
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
                Step(
                  title: Text('GPA', style: TextStyle(fontSize: 3.w)),
                  isActive: _currentStep == 0,
                  content: Padding(
                    padding: EdgeInsets.all(2.w),
                    child: TextField(
                      controller: _GPAController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          icon: const Icon(Icons.grade),
                          labelStyle: TextStyle(fontSize: 2.w),
                          labelText: 'Enter your Grade Point Average.'),
                    ),
                  ),
                ),
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
                        controller: _APCourseController,
                        values: _APCourseDisplay,
                        itemTitle: _APCourseDisplay,
                        chipGroupStyle: groupStyle,
                        onItemSelected: (list) => _APCourseSelected = list),
                  ),
                ),
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
                        onItemSelected: (list) => _honorCoursesSelected = list),
                  ),
                ),
                Step(
                  title:
                      Text('Advanced Classes', style: TextStyle(fontSize: 3.w)),
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
            GFButton(
                onPressed: () => _calculate(),
                text: 'Calculate',
                size: 5.w,
                textStyle: TextStyle(fontSize: 3.w),
                icon: Icon(Icons.calculate, color: Colors.white, size: 3.w),
                color: ColorUtil.red),
          ],
        ),
      ),
    );
  }
}
