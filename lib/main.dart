import 'dart:developer';
import 'dart:ffi';

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
        appBarTheme:const AppBarTheme(
            backgroundColor: Color(0xFF1B1464),
            foregroundColor: Colors.white,
        )
      ),
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
    
    static const String permissionErrorSnackbar = "We cannot track your speed without location persmission.";
}

enum MovementStates {
    idle,
    acceleration,
    deceleration
}

class SdSdController extends GetxController {
    var speed = 0.obs;
    var vol = 0.obs;
    var curMovementState = MovementStates.idle;
    var isLocationServiceDisabled = false.obs;
    var isPermissionGranted = false.obs;

    @override
    void onInit() {
        super.onInit();
        startPolling();
    }

    void startPolling() async {
        log("StartPolling");
        var isPermissionGranted = await getPermission();

        if (!isPermissionGranted) {
            Get.snackbar("Oops!", Messages.permissionErrorSnackbar).show();
        }

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
        switch(locationPermission) {
            case LocationPermission.always:
            case LocationPermission.whileInUse:
                log("Permission is granted");
                 isPermissionGranted.value = true;
                 isLocationServiceDisabled.value = false;
                 return true;
            default:
                log("Permission is not granted");
                return false;
        }
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

