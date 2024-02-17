import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher'); // Ensure you have an icon with this name
  var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  flutterLocalNotificationsPlugin.initialize(initializationSettings);
  setupTimeZone();
  runApp(MyApp());
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void setupTimeZone() {
  tzdata.initializeTimeZones();
  final String timeZoneName = tz.local.name;
  tz.setLocalLocation(tz.getLocation(timeZoneName));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exam Scheduling',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ExamSchedulingScreen(),
    );
  }
}

class ExamSchedulingScreen extends StatefulWidget {
  const ExamSchedulingScreen({Key? key}) : super(key: key);

  @override
  _ExamSchedulingScreenState createState() => _ExamSchedulingScreenState();
}

class _ExamSchedulingScreenState extends State<ExamSchedulingScreen> {
  List<ExamSchedule> examSchedules = [];
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(alert: true, badge: true, sound: true);
  }

  @override
  Widget build(BuildContext context) {
    examSchedules.sort((a, b) => a.examDate.compareTo(b.examDate));
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Scheduling'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () => _showAddExamDialog(context)),
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: _openCalendarView),
        ],
      ),
      body: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1, childAspectRatio: 4.0, crossAxisSpacing: 8.0, mainAxisSpacing: 8.0),
        itemCount: examSchedules.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildExamCard(examSchedules[index]);
        },
      ),
    );
  }

  Future<void> _showAddExamDialog(BuildContext context) async {
    String subjectName = '';
    DateTime? examDate;
    String examTime = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Exam Schedule'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Subject Name'),
                onChanged: (value) {
                  subjectName = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Exam Date (YYYY-MM-DD)'),
                onChanged: (value) {
                  try {
                    examDate = DateFormat('yyyy-MM-dd').parseStrict(value);
                  } catch (e) {
                    // Handle error or notify user
                  }
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Exam Time (HH:mm)'),
                onChanged: (value) {
                  examTime = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (subjectName.isNotEmpty && examDate != null && examTime.isNotEmpty) {
                  setState(() {
                    final examSchedule = ExamSchedule(
                      subjectName: subjectName,
                      examDate: examDate!,
                      examTime: examTime,
                    );
                    examSchedules.add(examSchedule);
                    // Optionally trigger a summary notification here
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> scheduleDailyExamsSummaryNotification() async {
    String summary = "Upcoming Exams for Tomorrow:\n";
    // Calculate tomorrow's date
    final tomorrow = DateTime.now().add(Duration(days: 1));
    // Use DateFormat to ensure comparison only considers the date part
    final dateFormat = DateFormat('yyyy-MM-dd');

    final tomorrowsExams = examSchedules.where((exam) =>
    dateFormat.format(exam.examDate) == dateFormat.format(tomorrow)).toList();

    for (var exam in tomorrowsExams) {
      summary += "${exam.subjectName} at ${exam.examTime}\n";
    }

    // Ensure there are exams tomorrow before scheduling a notification
    if(tomorrowsExams.isNotEmpty) {
      var androidDetails = const AndroidNotificationDetails(
        'daily_exam_summary',
        'Daily Exam Summary',
        channelDescription: 'Shows daily summary of exams for tomorrow',
        importance: Importance.high,
        priority: Priority.high,
      );
      var platformDetails = NotificationDetails(android: androidDetails);

      await flutterLocalNotificationsPlugin.show(
        0, // Unique Notification ID
        'Exams for Tomorrow',
        summary,
        platformDetails,
      );
    }
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
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Text(
              'Date: ${DateFormat('yyyy-MM-dd').format(examSchedule.examDate)}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            Text(
              'Time: ${examSchedule.examTime}',
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCalendarView() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar<ExamSchedule>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                return examSchedules.where((exam) => isSameDay(exam.examDate, day)).toList();
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
                final examsOnSelectedDay = examSchedules.where((exam) => isSameDay(exam.examDate, selectedDay)).toList();
                if (examsOnSelectedDay.isNotEmpty) {
                  _showExamsDialog(examsOnSelectedDay);
                }
              },
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  if (events.isNotEmpty) {
                    return Positioned(
                      right: 1,
                      bottom: 1,
                      child: _buildEventsMarker(date, events),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEventsMarker(DateTime date, List<dynamic> events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  void _showExamsDialog(List<ExamSchedule> examsOnSelectedDay) {
    examsOnSelectedDay.sort((a, b) => a.examTime.compareTo(b.examTime));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Exams on selected date"),
          content: SingleChildScrollView(
            child: ListBody(
              children: examsOnSelectedDay
                  .map((exam) => Text("${exam.subjectName} at ${exam.examTime}"))
                  .toList(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
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
