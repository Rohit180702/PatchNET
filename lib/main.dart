import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'MAP.dart';
import 'cell_info_service.dart'; // Import your Dart class
import 'location_service.dart'; // Import LocationService
import 'dart:math';
import 'package:flogger/flogger.dart';
import 'firebase_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'netspeed.dart';
import 'netspeed.dart';
import 'netspeed.dart'; // Import your Dart class




Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // final netspeed = NetworkSpeedMonitor(onUpdateSpeed: (speed) {
  //   print(speed);




  // Assuming you have the list populated




  // Create an instance of FirebaseService




  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final CellInfoService _cellInfoService = CellInfoService();
  final LocationService _locationService = LocationService();

  final FirebaseService _firebaseService = FirebaseService();
  final NetworkSpeedMonitor _networkSpeedService = NetworkSpeedMonitor();









  List<String> closeUserIds=[];

  Map<String, dynamic> towerLocation = {};
  Map<String, dynamic> cellInfo = {};

  double userLat = 0.0;
  double userLng = 0.0;
  String userpincode = "";
  double nearbylat=0.0;
  double nearbylng=0.0;
  double netspeed=0.0;
  String Simname = "";

  static  String name = "";
  static  String Email = "";
  bool emailError = false;

  // String get userId => null;

  // TextEditingController emailController = TextEditingController();
  @override
  void initState() {
    super.initState();
    // clearSharedPreferences();
    getMobileNetworkSpeed();
    userLocation();
    getinfo();
    // Timer.periodic(Duration(seconds: 2), (Timer timer) {
    //   getMobileNetworkSpeed();
    //   loadmap();
    // });
    // Timer.periodic(Duration(seconds: 1), (Timer timer) {
    //   userLocation();
    //   getinfo();
    // });
    // getinfo();

    checkFirstTime();
    loadmap();
  }


  Future<double> getMobileNetworkSpeed() async {

    final url = 'https://www.youtube.com';
    final startTime = DateTime.now();

    try {
      final response = await http.get(Uri.parse(url));
      final endTime = DateTime.now();

      final downloadTimeInSeconds = endTime.difference(startTime).inMilliseconds / 1000;
      final downloadSpeedKbpsValue = (response.contentLength! / downloadTimeInSeconds) / 1024;


      // netspeed = downloadSpeedKbpsValue;

      setState(() {
        netspeed = downloadSpeedKbpsValue;
        // _signalStrength = newSignalStrength;
      });
      print(netspeed);
      return netspeed;
      // onUpdateSpeed(downloadSpeed);
    } catch (e) {
      print('Error: $e');
      return  -1;
    }
  }

  Future<void> calculateDistance() async {
    // Ensure you have valid userLat, userLng, towerLocation['latitude'], and towerLocation['longitude'] values
    double userLatRadians = degreesToRadians(userLat);
    double userLngRadians = degreesToRadians(userLng);
    double towerLatRadians = degreesToRadians(towerLocation['latitude']);
    double towerLngRadians = degreesToRadians(towerLocation['longitude']);


    double earthRadius = 6371.0; // Earth's radius in kilometers

    double dLat = towerLatRadians - userLatRadians;
    double dLng = towerLngRadians - userLngRadians;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(userLatRadians) * cos(towerLatRadians) * sin(dLng / 2) * sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c; // Distance in kilometers

    setState(() {
      // Update the distance in the UI
      towerLocation['distance'] = distance;
    });
    // String userEmail = emailController.text;
    // print('User Email: $userEmail');
    // String modifiedEmail = userEmail.replaceAll('.com', '');
    // print('Modified Email: $modifiedEmail');
    // final networkSpeed = await _networkSpeedService.getMobileNetworkSpeed();
    // print('Mobile network speed: $networkSpeed kilobits per second');

    String userEmail = Email;
    print('User Email: $userEmail');
    String modifiedEmail = userEmail.replaceAll('.com', '');
    print('Modified Email: $modifiedEmail');
    // final networkSpeed = await _networkSpeedService.getMobileNetworkSpeed();
    final networkSpeed =  netspeed;

    print(networkSpeed);
    print('Mobile network speed: $netspeed kilobits per second');
    print('calculateDistance: $Simname .');

    // print('hiiii');


    await _firebaseService.storeUserLocation(userLat, userLng,modifiedEmail,netspeed , Simname );


  }
  Future<void> mapNearbyUser(String newuserId) async {
    List<String> newlistuser=['$newuserId'];
    try {
      Map<String, Map<String, double>> newuserLocations = await _firebaseService.extractLocations(newlistuser);

      // Print user locations
      newuserLocations.forEach((userId, location) {
        print('User ID: $userId, Latitude: ${location['latitude']}, Longitude: ${location['longitude'] }, optimalnetworkspeed ${location['usernetworkSpeed']}');

        setState(() {
          nearbylat=location['latitude']!;
          nearbylng=location['longitude']!;
        });

      });


    } catch (e) {
      print('Error extracting and printing locations: $e');
    }

  }
    Future<void> extractAndPrintLocations(List<String> userIds) async {
      try {
        Map<String, Map<String, double>> userLocations = await _firebaseService.extractLocations(userIds);

        // Print user locations
        userLocations.forEach((userId, location) {
          print('User ID: $userId, Latitude: ${location['latitude']}, Longitude: ${location['longitude'] }, optimalnetworkspeed ${location['usernetworkSpeed']}');
        });

      } catch (e) {
        print('Error extracting and printing locations: $e');
      }

    }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
    // ... (Your existing code for calculating distance)
  }
Future<void> userLocation() async{
  final userLocation = await _locationService.getCurrentLocation();

  if (userLocation.isNotEmpty) {
    userLat = userLocation['latitude']??0;
    userLng = userLocation['longitude']??0;



    print('User Location Latitude: $userLat');
    print('User Location Longitude: $userLng');


    // calculateDistance();

  } else {
    print('User location not available.');
  }

}
  Future<void> getinfo() async {



    //GETINFO-------------------------------------
    try {

      cellInfo = await _cellInfoService.getCellInfo(); // Store cellInfo here
      if (cellInfo is Map<String, dynamic>) {
        // Now you have MNC, MCC, LAC, and Cell ID values in cellInfo
        print('MNC: ${cellInfo['mnc']}');
        print('MCC: ${cellInfo['mcc']}');
        print('LAC: ${cellInfo['tac'] ?? "Unknown"}'); // Use null check for LAC
        print('CID: ${cellInfo['cid'] ?? "Unknown"}');
        print('sim_operator_name: ${cellInfo['sim_operator_name'] ?? "Unknown"}');
        print('signal_strength: ${cellInfo['signal_strength'] ?? "Unknown"}');
         // Use null check for CID
        Simname = cellInfo['sim_operator_name'] ?? "Unknown" ;

        } else {
        print('Error: Unexpected response format');
      }
    } catch (e) {
      print('Error: $e');
    }



  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  Future<void> checkFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('first_time') ?? true;

    if (isFirstTime) {
      // Show the sign-in dialog
      // ignore: use_build_context_synchronously
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sign In"),
            content: Container(
              width: 150,
              height: 150,
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: "Name"),
                    onChanged: (value) {
                      setState(() {
                        name = value; // Update the 'name' variable
                      });
                    },
                  ),
                  TextField(
                    decoration: InputDecoration(labelText: "Email"),
                    onChanged: (value) {
                      setState(() {
                        Email = value; // Update the 'userEmail' variable
                        emailError = !Email.toLowerCase().endsWith("@gmail.com");
                        // Set the email error flag based on the condition
                      });
                    },
                  ),
                  if (emailError)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Please enter a valid Gmail address",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  if (!emailError) {
                    // Save the fact that the user has signed in
                    prefs.setBool('first_time', false);
                    // You can use 'name' and 'userEmail' variables as needed
                    // Store the email permanently
                    prefs.setString('user_email', Email);
                    prefs.setString('user_name', name);
                    // You can use 'name' and 'userEmail' variables as needed
                    print("Name: $name, Email: $Email");
                    // print("Name: $name, Email: $Email");
                    Navigator.of(context).pop();
                  } else {
                    // Show an error message if there's an issue
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Please fix the errors before signing in.",style: TextStyle(color: Colors.red),),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text("Sign In"),
              ),
              ElevatedButton(
                onPressed: () {
                  // User clicked cancel
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),
            ],
          );
        },
      );
    } else {
      // Retrieve the stored email
      String storedEmail = prefs.getString('user_email') ?? "";
      String storedName = prefs.getString('user_name') ?? "";
      setState(() {
        Email = storedEmail;
        name = storedName;
      });
    }
  }
  Future<void> loadmap() async{
      print('nearby======================='+'$nearbylat'+'$nearbylng');
    Expanded(
      child: MapView(
        userLat: userLat,
        userLng: userLng,
        towerLat: towerLocation['latitude'],
        towerLng: towerLocation['longitude'],

        nearbylng: nearbylat,
        nearbylat: nearbylng,
      ),
    );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PatchNet  '+ '         ${Simname}:'+'${netspeed.toStringAsFixed(2)}kbps'),
      ),
      drawer: buildDrawer(),
      body: Center(
        child: Stack(
              // child:
                // mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Center(
                  child: (userLat == null || userLng == null || towerLocation['latitude'] == null || towerLocation['longitude'] == null)
                      ? CircularProgressIndicator()
                      :
                          Expanded(
                    child: MapView(
                          userLat: userLat,
                          userLng: userLng,
                          towerLat: towerLocation['latitude'] ,
                          towerLng: towerLocation['longitude'],
                          nearbylat: nearbylat,
                          nearbylng: nearbylng,
                    ),
        ),
      ),


                  SizedBox(
                      height: 400,
                      width: 180),
                  Positioned(
                    bottom: 20.0,
                    left: 20.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        try {
                          towerLocation = await _cellInfoService.getTowerLocation(cellInfo);
                          if (towerLocation.isNotEmpty) {
                            print('Latitude: ${towerLocation['latitude']}');
                            print('Longitude: ${towerLocation['longitude']}');
                            calculateDistance();

                          } else {
                            print('Tower location not available.');
                          }
                        } catch (e) {
                          print('Error retrieving tower location: $e');
                        }
                      },
                      child: Text('Get Tower Location'),
                    ),

                  ),
                  Positioned(
                    bottom: 20.0,
                    left: 180.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        // Call calculateDistancesBetweenUsers() when the button is pressed
                        await _firebaseService.calculateDistancesWithCondition();

                        // Assuming you have the list populated
                         closeUserIds = _firebaseService.closeUserIds;

                        // Call extractAndPrintLocations with the list of close user IDs
                        await extractAndPrintLocations(closeUserIds);
                        loadmap();
                        },
                      child: Text('Calculate Dist'),
                    ),
                  ),
                ],

        ),
      ),
    );
  }


  Widget getUserlocation() {
    List<String> additionalInfoList = closeUserIds; // Replace this with your list

    List<Widget> options = additionalInfoList.map((info) {
      return SimpleDialogOption(
        onPressed: () {
          // Handle the option press as needed
          mapNearbyUser(info);
          print('Selected: $info==========================================================================================');
          loadmap();
          Navigator.of(context).pop(); // Close the dialog
        },
        child: Text(info),
      );
    }).toList();

    return AlertDialog(
      title: Text('Cell Info Details'),
      content: Container(
        width: 100, // Adjust the width as needed
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: options,
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }

  Widget buildCellInfoDialog() {
    return AlertDialog(
      title: Text('Cell Info Details'),
      content: Container(
        width: 100, // Adjust the width as needed
        height: 210,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildInfoRow('MNC', cellInfo['mnc']),
            buildInfoRow('MCC', cellInfo['mcc']),
            buildInfoRow('LAC', cellInfo['tac'] ?? 'Unknown'),
            buildInfoRow('CID', cellInfo['cid'] ?? 'Unknown'),
            buildInfoRow('SIM', cellInfo['sim_operator_name'].toString() ?? 'Unknown'),
            buildInfoRow('Signal Strength', cellInfo['signal_strength'].toString() ?? 'Unknown'),
          // print('sim_operator_name: ${cellInfo['sim_operator_name'] ?? "Unknown"}');
          // print('signal_strength: ${cellInfo['signal_strength'] ?? "Unknown"}');
            // Add more Text widgets for additional cell info details
          ],
        ),
      ),
      contentPadding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Close'),
        ),
      ],
    );
  }
  Widget buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Cell Info Details',
                //   style: TextStyle(
                //     color: Colors.white,
                //     fontSize: 24,
                //   ),
                // ),
                SizedBox(height: 25),
                Row(
                  children: [
                    Icon(
                      Icons.account_circle, // Add your user icon here
                      size: 40, // Adjust the size as needed
                      color: Colors.white,
                    ),
                    Row(
                      children: [
                        Text(
                          '$name',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // SizedBox(height: 10),
                Row(
                  children: [
                    Icon(
                      Icons.email, // Use Icons.email for the email icon
                      size: 40, // Adjust the size as needed
                      color: Colors.white,
                    ),
                    Text(
                      '$Email',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ],
            ),

          ),

          ListTile(
            title: Text('Cell Info'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return buildCellInfoDialog();
                },
              );
            },
          ),
          ListTile(
            title: Text('Speedometer'),
            onTap: () {
              // Handle CID tap
              // showDialog(
              //   context: context,
              //   builder: (BuildContext context) {
              //     // return SpeedometerScreen();
              //   },
              // );
            },
          ),
          ListTile(
            title: Text('UserID'),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return getUserlocation();
                },
              );
            },
          ),
          // Add more ListTile widgets for additional cell info details
        ],
      ),
    );
  }

  Widget buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}
