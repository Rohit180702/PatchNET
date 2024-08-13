import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'cell_info_service.dart';
import 'location_service.dart';

class MapView extends StatefulWidget {
  final double userLat; // User's latitude
  final double userLng; // User's longitude
  final double towerLat; // Tower's latitude
  final double towerLng; // Tower's longitude
  final double nearbylat; // Tower's latitude
  final double nearbylng;

  MapView({
    required this.userLat,
    required this.userLng,
    required this.towerLat,
    required this.towerLng,
    required this.nearbylat,
    required this.nearbylng,
  });

  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController _mapController;
  String tappedLocation = '';

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void zoomToUserLocation() {
    _mapController.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(widget.userLat, widget.userLng),
        15.0, // You can adjust the zoom level as needed
      ),
    );
  }

  void displayLocationInfo(LatLng latLng) {
    setState(() {
      tappedLocation = 'Latitude: ${latLng.latitude}\nLongitude: ${latLng.longitude}';
    });
  }

  void clearTappedLocation() {
    setState(() {
      tappedLocation = '';
    });
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(widget.userLat, widget.userLng),
            zoom: 9.0,
          ),
          markers: {
            Marker(
              markerId: MarkerId('userMarker'),
              position: LatLng(widget.userLat, widget.userLng),
              onTap: () {
                displayLocationInfo(LatLng(widget.userLat, widget.userLng));
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            ),
            Marker(
              markerId: MarkerId('towerMarker'),
              position: LatLng(widget.towerLat, widget.towerLng),
              onTap: () {
                displayLocationInfo(LatLng(widget.towerLat, widget.towerLng));
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
            Marker(
              markerId: MarkerId('nearbyuser'),
              position: LatLng(widget.nearbylat, widget.nearbylng),
              onTap: () {
                displayLocationInfo(LatLng(widget.nearbylat, widget.nearbylng));
              },
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
            ),
          },
          circles: {
            Circle(
              circleId: CircleId('userCircle'),
              center: LatLng(widget.userLat, widget.userLng),
              radius: 150, // Adjust the radius as needed (in meters)
              strokeWidth: 2,
              strokeColor: Colors.blue.withOpacity(0.5),
              fillColor: Colors.blue.withOpacity(0.1),
            ),
            Circle(
              circleId: CircleId('towerCircle'),
              center: LatLng(widget.towerLat, widget.towerLng),
              radius:400 , // Adjust the radius as needed (in meters)
              strokeWidth: 2,
              strokeColor: Colors.red.withOpacity(0.5),
              fillColor: Colors.red.withOpacity(0.1),
            ),
          },
          onTap: (LatLng latLng) {
            clearTappedLocation();
          },
        ),
        Positioned(
          top: 20.0,
          left: 20.0,
          child:
          ElevatedButton(
                onPressed: zoomToUserLocation,
                child: Text('Zoom to User Location'),
              ),
        ),
        // Positioned(
        //   bottom: 20.0,
        //   right: 20.0,
        //   child: YourOverlayWidget2(),
        // ),


      ],
    );

    // Additional UI components go her
  }
}
//
// void main() async {
//   final locationService = LocationService();
//   final CellInfoService _cellInfoService = CellInfoService();
//   final cellInfo = await _cellInfoService.getCellInfo();
//
//   final towerLocation = await _cellInfoService.getTowerLocation(cellInfo);
//
//   final userLocation = await locationService.getCurrentLocation();
//   final double userLat = userLocation['latitude'];
//   final double userLng = userLocation['longitude'];
//
//   // Simulate getting the tower's location (you should replace this with your actual logic)
//   final double towerLat = towerLocation['latitude'];
//   final double towerLng = towerLocation['longitude'];
//   final double nearbylay
//
//   // var nearbylat;
//   runApp(MaterialApp(
//     home: MapView(
//       userLat: userLat,
//       userLng: userLng,
//       towerLat: towerLat,
//       towerLng: towerLng,
//       nearbylat:  nearbylat,
//     ),
//   ));
// }
