import 'dart:convert';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart' as audio;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

// import http as http;
import 'package:http/http.dart' as http;

Future<bool> _handleLocationPermission(BuildContext context) async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location services are disabled. Please enable the services')));
    return false;
  }
  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')));
      return false;
    }
  }
  if (permission == LocationPermission.deniedForever) {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
            'Location permissions are permanently denied, we cannot request permissions.')));
    return false;
  }
  return true;
}

void getCurrentLocation(BuildContext context) async {
  bool permission = await _handleLocationPermission(context);

  Position? currentPosition;

  if (permission) {
    currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    // Create new document in the 'hackers' collection.
    // The data in the document: 'location', 'mail', 'time'

    log('Current location: ${currentPosition.latitude}, ${currentPosition.longitude}');

    await FirebaseFirestore.instance
        .collection('hackers')
        .doc(FirebaseAuth.instance.currentUser?.displayName)
        .set({
      'location': {
        'latitude': currentPosition.latitude,
        'longitude': currentPosition.longitude
      },
      'mail': FirebaseAuth.instance.currentUser?.email,
      'time': DateTime.now()
    });
  } else {
    // If permission is not granted, get approximate location from IP address
    final response =
        await http.get(Uri.parse('https://api.ipregistry.co?key=tryout'));
    String location;

    if (response.statusCode == 200) {
      location = json.decode(response.body)['location']['country']['name'];
    } else {
      location = 'Failed to get user country from IP address';
    }

    // Upload data to database
    await FirebaseFirestore.instance
        .collection('hackers')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .set({
      'location': location,
      'mail': FirebaseAuth.instance.currentUser?.email,
      'time': DateTime.now()
    });
  }
}

class LocationFinder extends StatefulWidget {
  const LocationFinder({super.key});

  @override
  State<LocationFinder> createState() => _LocationFinderState();
}

class _LocationFinderState extends State<LocationFinder> {
  @override
  Widget build(BuildContext context) {
    // Play the 'enter_stranger' sound
    audio.AudioPlayer player = audio.AudioPlayer();
    audio.Source source =
        audio.DeviceFileSource('assets/audio/enter_stranger.mp3');
    player.play(source);

    return Container(
      child: const Text(
          """Enter, stranger, but take heedOf what awaits the sin of greed,
For those who take, but do not earn,
Must pay most dearly in their turn,
So if you seek beneath our floors
A treasure that was never yours,
Thief, you have been warned, beware
Of finding more than treasure there."""),
    );
  }
}
