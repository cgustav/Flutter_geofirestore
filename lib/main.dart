import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
//
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
//
import 'dart:async';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(),
    );
  }
}

///----------------------------------------
class FireMap extends StatefulWidget {
  State createState() => FireMapState();
}

class FireMapState extends State<FireMap> {
  GoogleMapController mapController;
  Location location =  Location();

  Firestore firestore =  Firestore.instance;
  Geoflutterfire geo =  Geoflutterfire();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          initialCameraPosition:
              CameraPosition(target: LatLng(24.142, -110.321), zoom: 15),
          onMapCreated: _onMapCreated,
          myLocationEnabled: true,
          mapType: MapType.hybrid,
        ),
        Positioned(
          bottom: 50,
          right: 10,
          child: FlatButton(
            child: Icon(Icons.pin_drop),
            color: Colors.green,
            onPressed: _addGeoPoint,
          ),
        )
      ],
    );
  }

  _onMapCreated(GoogleMapController controller) {
    setState(() {
      mapController = controller;
    });
  }

  _addMarker() {
    var marker = MarkerOptions(
        position: mapController.cameraPosition.target,
        icon: BitmapDescriptor.defaultMarker,
        infoWindowText: InfoWindowText('Magic Market', ':mushroom:'));
    mapController.addMarker(marker);
  }

  _animateToUser() async {
    LocationData pos = await location.getLocation();
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(pos.latitude, pos.longitude),
        zoom: 17.0
      )
    ));
  }

  Future<DocumentReference> _addGeoPoint() async {
    var pos = await location.getLocation();
    //calculate geohash and calculate distance between points 
    GeoFirePoint point =  geo.point(latitude: pos.latitude, longitude: pos.longitude);
    return firestore.collection('locations').add({
      'position': point.data,
      'name': 'Yay this works just fine!'
    });

  }
}
