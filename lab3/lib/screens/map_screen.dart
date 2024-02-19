import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  LatLng? _pickedLocation;

  void _selectLocation(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
  }

  Future<void> _confirmSelection() async {
    if (_pickedLocation == null) {
      Navigator.of(context).pop("No location selected"); // Optionally provide feedback for no selection
      return;
    }

    // Directly returning the latitude and longitude as a string
    String locationString = "${_pickedLocation!.latitude}, ${_pickedLocation!.longitude}";
    Navigator.of(context).pop(locationString); // Pass back the location string
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _confirmSelection,
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _pickedLocation ?? LatLng(42.00444330495908, 21.409681189873837),
          zoom: 14,
        ),
        onTap: _selectLocation,
        markers: _pickedLocation != null ? {
          Marker(
            markerId: MarkerId('m1'),
            position: _pickedLocation!,
          ),
        } : {},
      ),
    );
  }
}
