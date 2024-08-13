import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'speed_test.dart';
import 'package:http/http.dart' as http;


// class SpeedometerScreen extends StatelessWidget {
  // final SpeedTestScreen speedTestScreen = SpeedTestScreen();
  // double _signalStrength =passresult();
  class SpeedometerScreen extends StatefulWidget {
  @override
  _speedometerScreen createState() => _speedometerScreen();
  }
class _speedometerScreen extends State<SpeedometerScreen> {
  final NetworkSpeedService _networkSpeedService = NetworkSpeedService();
  // final networkSpeed = await _networkSpeedService.getMobileNetworkSpeed();

  double _downloadSpeed = 0.0;
  int _signalStrength = 0;
  @override
  void initState() {
    super.initState();
    // Start the speed test every 2 seconds
    Timer.periodic(Duration(seconds: 2), (Timer timer) {
      _runSpeedTest();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }
  Future<double> _runSpeedTest() async {
    try {
      const url = 'http://speedtest.ookla.com'; // Replace with a URL that represents your server or an external resource
      const numRequests = 5;

      final startTimes = List<DateTime>.filled(numRequests, DateTime.now());

      // Make a series of HTTP requests
      await Future.wait(List.generate(numRequests, (index) => http.get(Uri.parse(url))));

      final endTimes = List<DateTime>.generate(numRequests, (index) => DateTime.now());

      final totalDuration = endTimes.last.difference(startTimes.first);
      final totalSize = numRequests * (await http.get(Uri.parse(url))).contentLength!;

      final speedInBytesPerSecond = totalSize / totalDuration.inMicroseconds.toDouble();

      // Convert speed to kilobits per second (1 byte = 8 bits)
      final speedInKilobitsPerSecond = speedInBytesPerSecond * 8 / 1024;

      // final speed = 100*(fileSize / duration.inMilliseconds) * 8.0 / 1024.0;
      // final newSignalStrength = _calculateSignalStrength(speedInKilobitsPerSecond);

     setState(() {
        _downloadSpeed = speedInKilobitsPerSecond*10000;
        // _signalStrength = newSignalStrength;
      });
      return _downloadSpeed;
    } catch (e) {
      print('Error measuring network speed: $e');
      return -1; // Return a negative value to indicate an error
    }
  }
  contentBox(context) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: Offset(0, 10),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Speedometer',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 15),

          // Text('Download speed: ${speedTestScreen.passresult()} kbps'),
          SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 100,
                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: 33,
                    color: Colors.red,
                  ),
                  GaugeRange(
                    startValue: 34,
                    endValue: 66,
                    color: Colors.orange,
                  ),
                  GaugeRange(
                    startValue: 67,
                    endValue: 100,
                    color: Colors.green,
                  ),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: _downloadSpeed,
                    enableAnimation: true,
                  ),
                ],
                annotations: <GaugeAnnotation>[

                  GaugeAnnotation(
                    widget: Text('Signal Strength\n${_downloadSpeed.toStringAsFixed(3)} kbps'),
                    angle: 270,
                    positionFactor: 0.5,
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 22),
          Align(
            alignment: Alignment.bottomRight,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Close'),
            ),
          ),
        ],
      ),
    );
  }
}
