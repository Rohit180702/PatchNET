import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';

import 'location_service.dart';

class FirebaseService {
  late DatabaseReference _databaseReference;
  late String userId; // User ID to identify individual users
  final LocationService _locationService = LocationService();
   late double userLat = 0.0;
  late double userLng = 0.0;
  late double usernetworkSpeed = 0.0;
  late String usersimname = "";
  late String  userPincode ="";
  List<String> closeUserIds = [];


  FirebaseService() {


    // Initialize the database reference in the constructor
    _databaseReference = FirebaseDatabase.instance.reference();

  }




  Future<void> storeUserLocation(double latitude, double longitude, String userId, double networkSpeed , String Simname) async {
    try {
      // Ensure userId is initialized before proceeding
      while (userId.isEmpty) {
        await Future.delayed(Duration(milliseconds: 100)); // Adjust delay as needed
      }

      await _databaseReference.child("user_location").child(userId as String).set({
        'latitude': latitude,
        'longitude': longitude,
        'networkSpeed':networkSpeed,
        'SimName': Simname,

      });
      print('User location stored successfully for user $userId.');

      // Update class-level variables with the new values
      userLat = latitude;
      userLng = longitude;
      usernetworkSpeed = networkSpeed;
      usersimname = Simname;



    } catch (e) {
      print('Error storing user location in Firebase: $e');
    }
  }
  Future<Map<String, Map<String, double>>> extractLocations(List<String> userIds) async {
    try {
      Map<String, Map<String, double>> userLocations = {};

      for (String userId in userIds) {
        DataSnapshot userLocationSnapshot =
            (await _databaseReference.child("user_location").child(userId).once()).snapshot;

        Map<String, dynamic>? locationData = _extractLocationData(userLocationSnapshot);

        if (locationData != null) {
          print(locationData );
          double latitude = locationData['latitude']?.toDouble() ?? 0.0;
          double longitude = locationData['longitude']?.toDouble() ?? 0.0;
          double  networkSpeed = locationData['networkSpeed']?.toDouble() ?? 0.0;
          String simname = locationData['SimName'].toString();
          // Add null check

          print("idnt$networkSpeed");
          print(usernetworkSpeed);
          print(locationData['networkSpeed '] );
          print("ysgd$networkSpeed");
          print("simme $simname");


          // Check if the user's network speed is not null and greater than their stored speed
          if (networkSpeed != null && networkSpeed > usernetworkSpeed ) {
            print("fvnfv");
            userLocations[userId] = {'latitude': latitude, 'longitude': longitude, 'usernetworkSpeed': networkSpeed};
          }
          else{
            print(" no nearby device found");
          }
        }
      }

      return userLocations;
    } catch (e) {
      print('Error extracting locations: $e');
      return {};
    }
  }


  Future<List<String>> getAllUserIds() async {
    try {
      DataSnapshot dataSnapshot = (await _databaseReference.child("user_location").once()).snapshot;

      print('Data Snapshot: ${dataSnapshot.value}');

      if (dataSnapshot.value is Map<Object?, dynamic>?) {
        Map<Object?, dynamic>? userLocations = dataSnapshot.value as Map<Object?, dynamic>?;

        if (userLocations != null) {
          List<String> userIds = userLocations.keys
              .whereType<String>() // Filter out non-string keys
              .toList();
          print('All User IDs: $userIds');
          return userIds;
        } else {
          return [];
        }
      } else {
        print('Error: Unexpected data format for user locations');
        return [];
      }
    } catch (e) {
      print('Error getting user IDs: $e');
      return [];
    }
  }

  Future<List<String>> calculateDistancesWithCondition() async {
    try {
      List<String> userIds = await getAllUserIds();
      closeUserIds.clear();

      for (int i = 0; i <= userIds.length - 1; i++) {
        String otherUser = userIds[i];

        // Fetch the user's location data
        DataSnapshot userLocationSnapshot =
            (await _databaseReference.child("user_location").child(otherUser).once()).snapshot;

        Map<String, dynamic>? locationData = _extractLocationData(userLocationSnapshot);

        if (locationData != null) {
          double networkSpeed = locationData['networkSpeed']?.toDouble() ?? 0.0;

          String Simname  =  locationData['SimName'];

           print("calculateDistancesWithCondition${networkSpeed}");
          print("calculateDistancesWithCondition${Simname}");
          print("calculateDistancesWithCondition${usersimname}");

          // Check if the network speed is greater than the user's network speed
          if (networkSpeed > usernetworkSpeed && Simname ==usersimname ) {
            print(otherUser);
            double distance = await calculateDistance(otherUser);

            if (distance >= 0 && distance <= 0.5) {
              print('Distance between $otherUser: $distance km');

              // Check for duplicates before adding to the list
              if (!closeUserIds.contains(otherUser)) {
                closeUserIds.add(otherUser);
              }
            } else {
              print('Distance between $otherUser exceeds 100 meters');
            }
          } else {
            print('Network speed of $otherUser is not greater than user network speed.');
          }
        }
      }

      print(closeUserIds);
      return closeUserIds;
    } catch (e) {
      print('Error calculating distances: $e');
      return [];
    }
  }

  Future<double> calculateDistance(String userId2) async {
    try {
      // Get the other user's location
      DataSnapshot userLocationSnapshot2 =
          (await _databaseReference.child("user_location").child(userId2).once()).snapshot;

      // Extract latitude and longitude values
      Map<String, dynamic>? userLocationData2 = _extractLocationData(userLocationSnapshot2);

      if (userLat == null || userLng == null || userLocationData2 == null) {
        throw Exception('Unexpected data format for user locations');
      }

      // Extract latitude and longitude from multiple entries
      double userLat1 = userLat.toDouble();
      double userLng1 = userLng.toDouble();
      double userLat2 = userLocationData2['latitude']!.toDouble();
      double userLng2 = userLocationData2['longitude']!.toDouble();
      print("userLat1$userLat1");
      print(" userLng1 $userLng1");
      print(" userLat2 $userLat2");
      print("userLng2$userLng2");


      // Calculate the distance between the two locations
      double distance = _calculateDistance(userLat1, userLng1, userLat2, userLng2);

      return distance;
    } catch (e) {
      print('Error calculating distance: $e');
      return -1; // Return a negative value to indicate an error
    }
  }

  Map<String, double> extractLatLong(Map<String, dynamic> userLocationData) {
    try {
      if (userLocationData.isNotEmpty) {
        String firstKey = userLocationData.keys.first;
        dynamic userData = userLocationData[firstKey];


        if (userData is Map<String, dynamic> || userData is Map<Object?, Object?>) {

          double latitude = userData['userlatitude']?.toDouble() ?? 0.0;

          double longitude = userData['userlongitude']?.toDouble() ?? 0.0;


          return {'userlatitude': latitude, 'userlongitude': longitude};
        } else {
          throw Exception('Unexpected data format for user location');
        }
      } else {
        throw Exception('No user location data found');
      }
    } catch (e) {
      throw Exception('Error extracting user location data: $e');
    }
  }







  Map<String, dynamic>? _extractLocationData(DataSnapshot snapshot) {
    try {
      dynamic snapshotValue = snapshot.value;

      if (snapshotValue is Map<String, dynamic>) {
        // Check if the snapshot value is a Map
        return snapshotValue;
      } else if (snapshotValue is Map<Object?, Object?>) {
        // Handle cases where the snapshot value is a Map<Object?, Object?>
        Map<String, dynamic>? convertedMap = {};
        for (var entry in snapshotValue.entries) {
          if (entry.key is String) {
            convertedMap[entry.key as String] = entry.value;
          }
        }
        return convertedMap;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    double earthRadius = 6371.0; // Earth's radius in kilometers

    double dLat = degreesToRadians(lat2 - lat1);
    double dLng = degreesToRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c; // Distance in kilometers

    return distance;
  }

  double degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
}








