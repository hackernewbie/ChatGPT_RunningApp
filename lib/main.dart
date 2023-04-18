import 'dart:async';
import 'dart:math' show sin, cos, sqrt, atan2, pi;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Running App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Running App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Completer<GoogleMapController> _controller = Completer();
  Location _location = Location();
  Set<Polyline> _polylines = {};
  List<LatLng> _points = [];
  Timer? _timer;
  Duration _duration = Duration.zero;

  static final CameraPosition _kInitialPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 16.0,
  );

  @override
  void initState() {
    super.initState();
    _location.onLocationChanged.listen((LocationData currentLocation) {
      if (_points.isNotEmpty) {
        LatLng previousPoint = _points.last;
        LatLng currentPoint = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        if (_getDistanceBetweenPoints(previousPoint, currentPoint) > 10) {
          _points.add(currentPoint);
          _updatePolyline();
        }
      } else {
        _points.add(LatLng(currentLocation.latitude!, currentLocation.longitude!));
        _updatePolyline();
      }
    });
  }

  void _updatePolyline() {
    Polyline polyline = Polyline(
      polylineId: PolylineId('running_path'),
      color: Colors.blue,
      points: _points,
    );
    setState(() {
      _polylines.add(polyline);
    });
  }

  void _startTimer() {
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
        setState(() {
          _duration = _duration + Duration(seconds: 1);
        });
      });
    }
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }

  void _resetTimer() {
    setState(() {
      _duration = Duration.zero;
      _stopTimer();
      _points.clear();
      _polylines.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kInitialPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        polylines: _polylines,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              _startTimer();
            },
            child: Icon(Icons.play_arrow),
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: (){},
            child: Icon(Icons.stop),
            backgroundColor: Colors.red,
          ),
          SizedBox(height: 16.0),
          FloatingActionButton(
            onPressed: () {
              _resetTimer();
            },
            child: Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        child: Container(
          height: 48.0,
          child: Center(
            child: Text(
              '${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 24.0),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  double _getDistanceBetweenPoints(LatLng p1, LatLng p2) {
    const double radius = 6371; // Earth's radius in km
    double lat1 = p1.latitude * pi / 180;
    double lon1 = p1.longitude * pi / 180;
    double lat2 = p2.latitude * pi / 180;
    double lon2 = p2.longitude * pi / 180;
    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;
    double a = sin(dLat / 2) * sin(dLat / 2) + cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = radius * c * 1000; // Convert to meters
    return distance;
  }
}
