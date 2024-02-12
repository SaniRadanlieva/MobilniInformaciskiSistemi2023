import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExamSchedulingScreen extends StatefulWidget {
  const ExamSchedulingScreen({Key? key}) : super(key: key);

  @override
  _ExamSchedulingScreenState createState() => _ExamSchedulingScreenState();
}

class _ExamSchedulingScreenState extends State<ExamSchedulingScreen> {
  List<ExamSchedule> examSchedules = [];

  @override
  Widget build(BuildContext context) {
    // Sort the exam schedules based on date, time, and subject name
    examSchedules.sort((a, b) {
      // Compare dates
      int dateComparison = a.examDate.compareTo(b.examDate);
      if (dateComparison != 0) {
        return dateComparison;
      }

      // Compare times if dates are the same
      int timeComparison = a.examTime.compareTo(b.examTime);
      if (timeComparison != 0) {
        return timeComparison;
      }

      // Compare subject names if dates and times are the same
      return a.subjectName.compareTo(b.subjectName);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Scheduling'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddExamDialog(context);
            },
          ),
        ],
      ),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1, // Display one card in one row
          childAspectRatio: 4.0, // Control the aspect ratio
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: examSchedules.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildExamCard(examSchedules[index]);
        },
      ),
    );
  }

  // Function to show the Add Exam Dialog
  Future<void> _showAddExamDialog(BuildContext context) async {
    String subjectName = '';
    DateTime? examDate;
    String examTime = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Exam Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Subject Name'),
                onChanged: (value) {
                  subjectName = value;
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Exam Date'),
                onChanged: (value) {
                  // Format the date in 'dd.MM.yy' to 'yyyy-MM-dd' before parsing
                  examDate = DateFormat('dd.MM.yy').parseStrict(value);
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: InputDecoration(labelText: 'Exam Time'),
                onChanged: (value) {
                  examTime = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (examDate != null) {
                  // Handle the data entered by the user (subjectName, examDate, examTime)
                  ExamSchedule newExamSchedule = ExamSchedule(
                    subjectName: subjectName,
                    examDate: examDate!,
                    examTime: examTime,
                  );

                  // Update the UI with the new exam schedule
                  setState(() {
                    examSchedules.add(newExamSchedule);
                  });

                  Navigator.of(context).pop();
                } else {
                  // Handle error, invalid date format
                  print('Invalid date format');
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildExamCard(ExamSchedule examSchedule) {
    return Card(
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              examSchedule.subjectName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(examSchedule.examDate)}',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            Text(
              'Time: ${examSchedule.examTime}',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamSchedule {
  final String subjectName;
  final DateTime examDate;
  final String examTime;

  ExamSchedule({
    required this.subjectName,
    required this.examDate,
    required this.examTime,
  });
}
