import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B1464),
            foregroundColor: Colors.white,
          )),
      home: Scaffold(
        backgroundColor: const Color(0xFFecf0f1),
        appBar: AppBar(
          title: const Text("Slow down, sound down"),
        ),
        body: const SdSd(),
      ),
    );
  }
}

abstract class SdSdConfig {
  // Volume when not moving
  static const int idleVolume = 20; // volume %

  // At what speed should 100% volume be used
  static const int fullVolumeSpeed = 40; // volume %

  // Below what speed should the volume start going down
  static const int slowDownThreshold = 15; // kmph
}

abstract class Messages {
  static const String permissionErrorSnackbar =
      "We cannot track your speed without location persmission.";
}

enum MovementStates { idle, acceleration, deceleration }

class SdSdController extends GetxController {
  var speed = 0.obs;
  var vol = 0.obs;
  var curMovementState = MovementStates.idle;
  var isLocationServiceDisabled = false.obs;
  var isPermissionGranted = false.obs;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 50,
  );

  final AndroidSettings androidLocationSettings = AndroidSettings(
    intervalDuration: const Duration(seconds: 3),
    distanceFilter: 2,

    forceLocationManager: true,
  );

  @override
  void onInit() {
    super.onInit();
    startPolling();
  }


  int _mPerSecondToKmh(double speedInMps) {
      // Perform the conversion using the correct factor for meters per second to kilometers per hour
      double speedInKmh = speedInMps * 3.6;

      // Round the result to the nearest integer using a more precise method
      return (speedInKmh + 0.5).toInt();
  }


  void startPolling() async {
    log("StartPolling");
    var isPermissionGranted = await getPermission();

    if (!isPermissionGranted) {
      log("Permisssion Denied :(");
    }

    Geolocator
        .getPositionStream(locationSettings: androidLocationSettings)
        .listen((Position? position) {
          if (position != null) {
            log("Found a new position $position going at ${position.speed}");
            var speedInMetersPerSec = position.speed;
            var speedInKmPerHr = _mPerSecondToKmh(speedInMetersPerSec);

            log("Current speed: $speedInKmPerHr km/h");
            speed.value = speedInKmPerHr;
          }
        });
  }

  Future<bool> getPermission() async {
    bool serviceEnabled;
    LocationPermission locationPermission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      log("Location service is disabled");
      isLocationServiceDisabled.value = true;
    }

    locationPermission = await Geolocator.checkPermission();
    log("Got location permission, $locationPermission");

    if (locationPermission == LocationPermission.denied) {
      locationPermission = await Geolocator.requestPermission();
      if (locationPermission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        log('Location permissions are denied');
        return false;
      }
    }

    if (locationPermission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      log('Location permissions are permanently denied, we cannot request permissions.');
      return false;
    }

    // switch (locationPermission) {
    //   case LocationPermission.always:
    //   case LocationPermission.whileInUse:
    //     log("Permission is granted");
    //     isPermissionGranted.value = true;
    //     isLocationServiceDisabled.value = false;
    //     return true;
    //   case LocationPermission.denied:
    //     return
    //   default:
    //     log("Permission is not granted");
    //     return false;
    // }
    return true;
  }
}

class SdSd extends StatelessWidget {
  const SdSd({super.key});

  @override
  Widget build(BuildContext context) {
    final SdSdController c = Get.put(SdSdController());

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        children: [
          Obx(() => Text("Current Speed: ${c.speed} km/h")),
          Obx(() => Text("Current Volume: ${c.vol}%")),
        ],
      ),
    );
  }
}
