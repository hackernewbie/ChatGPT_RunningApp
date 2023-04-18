import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Running App',
      home: StopwatchPage(),
    );
  }
}

class StopwatchPage extends StatefulWidget {
  @override
  _StopwatchPageState createState() => _StopwatchPageState();
}

class _StopwatchPageState extends State<StopwatchPage> {
  Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;
  Duration _duration = Duration();

  void _startTimer() {
    setState(() {
      _stopwatch.start();
      _timer = Timer.periodic(Duration(milliseconds: 100), _updateTimer);
    });
  }

  void _stopTimer() {
    setState(() {
      _stopwatch.stop();
      _timer.cancel();
    });
  }

  void _resetTimer() {
    setState(() {
      _stopwatch.reset();
      _duration = Duration();
    });
  }

  void _updateTimer(Timer timer) {
    setState(() {
      _duration = _stopwatch.elapsed;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    String twoDigitMilliseconds =
        twoDigits(duration.inMilliseconds.remainder(100));
    return "$twoDigitMinutes:$twoDigitSeconds.$twoDigitMilliseconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Running App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Distance: 0 km',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Time: ${_formatDuration(_duration)}',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FloatingActionButton(
                  onPressed: _startTimer,
                  child: Icon(Icons.play_arrow),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _stopTimer,
                  child: Icon(Icons.stop),
                ),
                SizedBox(width: 20),
                FloatingActionButton(
                  onPressed: _resetTimer,
                  child: Icon(Icons.replay),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
