import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lab3/screens/exam_schedule_screen.dart';

class ExamMapScreen extends StatefulWidget {
  final List<ExamSchedule> examSchedules;

  const ExamMapScreen({Key? key, required this.examSchedules}) : super(key: key);

  @override
  _ExamMapScreenState createState() => _ExamMapScreenState();
}

class _ExamMapScreenState extends State<ExamMapScreen> {
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _createMarkers();
  }

  void _createMarkers() {
    widget.examSchedules.forEach((exam) {
      // Assuming examLocation is a String in the format "latitude,longitude"
      var latLng = exam.examLocation.split(',');
      if (latLng.length == 2) {
        var latitude = double.parse(latLng[0]);
        var longitude = double.parse(latLng[1]);

        setState(() {
          _markers.add(
            Marker(
              markerId: MarkerId(exam.subjectName),
              position: LatLng(latitude, longitude),
              infoWindow: InfoWindow(
                title: exam.subjectName,
                snippet: 'Date: ${DateFormat('yyyy-MM-dd').format(exam.examDate)}, Time: ${exam.examTime}',
              ),
            ),
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Exam Locations Map"),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(42.00422338110352, 21.409641728954885), // Default position, update accordingly
          zoom: 13,
        ),
        markers: _markers,
      ),
    );
  }
}
