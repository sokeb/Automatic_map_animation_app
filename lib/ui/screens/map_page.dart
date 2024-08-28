import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key, required this.title});

  final String title;

  @override
  MapPageState createState() => MapPageState();
}

class MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  final Set<Polyline> _polyLines = {};
  final Set<Marker> _markers = {};
  final List<LatLng> _route = [];

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return;
    }
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition();

    LatLng initialPosition = LatLng(position.latitude, position.longitude);

    _markers.add(Marker(
      markerId: const MarkerId('current_location'),
      position: initialPosition,
      infoWindow: InfoWindow(
        title: 'My current location',
        snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
      ),
    ));

    _controller?.animateCamera(CameraUpdate.newLatLngZoom(initialPosition, 15));
    _getLocationUpdates();
  }

  void _getLocationUpdates() {
    Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 10,
    )).listen((Position position) {
      _updateLocation(position);
    });
  }

  void _updateLocation(Position position) {
    LatLng newLatLng = LatLng(position.latitude, position.longitude);

    if (_route.isNotEmpty) {
      _route.add(newLatLng);
      _polyLines.add(
        Polyline(
          polylineId: PolylineId(_route.length.toString()),
          visible: true,
          points: _route,
          width: 4,
          color: Colors.blue,
        ),
      );
    } else {
      _route.add(newLatLng);
    }

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: newLatLng,
          infoWindow: InfoWindow(
            title: 'My current location',
            snippet: 'Lat: ${position.latitude}, Lng: ${position.longitude}',
          ),
        ),
      );
      _controller?.animateCamera(CameraUpdate.newLatLng(newLatLng));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white12,
        title: Text(widget.title),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 15,
        ),
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _getCurrentLocation();
          setState(() {});
        },
        markers: _markers,
        polylines: _polyLines,
        myLocationEnabled: true,
      ),
    );
  }
}
