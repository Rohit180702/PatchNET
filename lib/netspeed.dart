import 'dart:async';
import 'package:http/http.dart' as http;

class NetworkSpeedMonitor {
  double downloadSpeed=0.0;

  Future<double> getMobileNetworkSpeed() async {

    final url = 'https://www.youtube.com';
    final startTime = DateTime.now();

    try {
      final response = await http.get(Uri.parse(url));
      final endTime = DateTime.now();

      final downloadTimeInSeconds = endTime.difference(startTime).inMilliseconds / 1000;
      final downloadSpeedKbpsValue = (response.contentLength! / downloadTimeInSeconds) / 1024;


      downloadSpeed = downloadSpeedKbpsValue;
      return downloadSpeed;
      // onUpdateSpeed(downloadSpeed);
    } catch (e) {
      print('Error: $e');
      return  -1;
    }
  }
}



//
// import 'dart:async';
// import 'package:http/http.dart' as http;
//
// class NetworkSpeedMonitor {
//   double downloadSpeed = 0.0;
//   Function(double) onUpdateSpeed;
//
//   NetworkSpeedMonitor({required this.onUpdateSpeed});
//
//   void startMonitoring() {
//     Timer.periodic(Duration(seconds: 2), (Timer timer) {
//       _updateDownloadSpeed();
//     });
//   }
//
//   Future<void> _updateDownloadSpeed() async {
//     final url = 'https://www.youtube.com';
//     final startTime = DateTime.now();
//
//     try {
//       final response = await http.get(Uri.parse(url));
//       final endTime = DateTime.now();
//
//       final downloadTimeInSeconds = endTime.difference(startTime).inMilliseconds / 1000;
//       final downloadSpeedKbpsValue = (response.contentLength! / downloadTimeInSeconds) / 1024;
//
//
//         downloadSpeed  = downloadSpeedKbpsValue;
//
//       onUpdateSpeed(downloadSpeed);
//     } catch (e) {
//       print('Error: $e');
//       downloadSpeed = -1;
//     }
//   }
// }

