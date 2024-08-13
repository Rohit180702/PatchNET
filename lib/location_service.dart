import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_service.dart';

class LocationService {
  Future<Map<String, dynamic>> getCurrentLocation() async {
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final double latitude = position.latitude;
      final double longitude = position.longitude;

      // Use reverse geocoding to get the address details including pincode


      // Store user location in Firebase



      return {
        'latitude': latitude,
        'longitude': longitude
      };
    } catch (e) {
      print('Error getting user location: $e');
      return {
        'error': 'Error getting user location',
        'message': e.toString(),
      };
    }
  }
}
